//
//  WBH264Play.m
//  wenba_rtc
//
//  Created by zhouweiwei on 16/11/20.
//  Copyright © 2016年 zhouweiwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBH264Play.h"
#import <VideoToolbox/VideoToolbox.h>
#define kH264outputWidth  1280
#define kH264outputHeight 720

static const uint8_t *avc_find_startcode_internal(const uint8_t *p, const uint8_t *end)
{
    const uint8_t *a = p + 4 - ((intptr_t)p & 3);

    for (end -= 3; p < a && p < end; p++) {
        if (p[0] == 0 && p[1] == 0 && p[2] == 1)
            return p;
    }

    for (end -= 3; p < end; p += 4) {
        uint32_t x = *(const uint32_t*)p;
        //      if ((x - 0x01000100) & (~x) & 0x80008000) // little endian
        //      if ((x - 0x00010001) & (~x) & 0x00800080) // big endian
        if ((x - 0x01010101) & (~x) & 0x80808080) { // generic
            if (p[1] == 0) {
                if (p[0] == 0 && p[2] == 1)
                    return p;
                if (p[2] == 0 && p[3] == 1)
                    return p+1;
            }
            if (p[3] == 0) {
                if (p[2] == 0 && p[4] == 1)
                    return p+2;
                if (p[4] == 0 && p[5] == 1)
                    return p+3;
            }
        }
    }

    for (end += 3; p < end; p++) {
        if (p[0] == 0 && p[1] == 0 && p[2] == 1)
            return p;
    }

    return end + 3;
}

const uint8_t *avc_find_startcode(const uint8_t *p, const uint8_t *end)
{
    const uint8_t *ret= avc_find_startcode_internal(p, end);
    if(p<ret && ret<end && !ret[-1]) ret--;
    return ret;
}

@interface H264HwDecoder()
{
    NSThread *thread;
    uint8_t* _vdata;
    size_t _vsize;

    uint8_t *_buf_out; // 原始接收的重组数据包

    uint8_t *_sps;
    size_t _spsSize;
    uint8_t *_pps;
    size_t _ppsSize;
    VTDecompressionSessionRef _deocderSession;
    CMVideoFormatDescriptionRef _decoderFormatDescription;


    CGFloat _out_width,_out_height;
}
@property (nonatomic,assign)uint uid;

@end

@implementation H264HwDecoder

//解码回调函数
static void didDecompress(void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef imageBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ) {

    if (status != noErr || imageBuffer == nil) {
        NSLog(@"Error decompresssing frame at time: %.3f error: %d infoFlags: %u",
             presentationTimeStamp.value/presentationTimeStamp.timescale, status, infoFlags);
        return;
    }

    if (kVTDecodeInfo_FrameDropped & infoFlags) {
        NSLog(@"video frame droped");
        return;
    }

    //    int i,j;
    //    if (CVPixelBufferIsPlanar(imageBuffer)) {
    //        i  = (int)CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    //        j = (int)CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    //    } else {
    //        i  = (int)CVPixelBufferGetWidth(imageBuffer);
    //        j = (int)CVPixelBufferGetHeight(imageBuffer);
    //    }

    __weak H264HwDecoder *decoder = (__bridge H264HwDecoder *)decompressionOutputRefCon;
    if (decoder.delegate != nil) {
        CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
        *outputPixelBuffer = CVPixelBufferRetain(imageBuffer);
        [decoder.delegate displayDecodedFrame:decoder.uid imageBuffer:imageBuffer];
    }
}

- (BOOL)open:(id<IWBH264HwDecoderDelegate>)displayDelegate width:(uint16_t)width height:(uint16_t)height  {

    [self close];

    if (width == 0 || height == 0) {
        _out_width = kH264outputWidth;
        _out_height = kH264outputHeight;
    }
    else {
        _out_width = width;
        _out_height = height;
    }
//    _vsize = _out_width * _out_height * 3;
//    _vdata = (uint8_t*)malloc(_vsize * sizeof(uint8_t));

    _buf_out = (uint8_t*)malloc(_out_width * _out_height * sizeof(uint8_t));

    self.delegate = displayDelegate;

    return YES;
}

- (void)setH264DecoderInterface:(id<IWBH264HwDecoderDelegate>)displayDelegate {
    self.delegate = displayDelegate;
}



- (void)stop {
    NSLog(@"uid:%u decoder stop", _uid);



    NSLog(@"uid:%u decoder stoped", _uid);

    if (_decoderFormatDescription != nil) {
        CFRelease(_decoderFormatDescription);
        _decoderFormatDescription = nil;
    }

    if (_deocderSession != nil) {
        VTDecompressionSessionWaitForAsynchronousFrames(_deocderSession);
        VTDecompressionSessionInvalidate(_deocderSession);
        CFRelease(_deocderSession);
        _deocderSession = nil;
    }

    _uid = 0;

    _out_width = kH264outputWidth;
    _out_height = kH264outputHeight;

    if (_vdata != NULL) {
        free(_vdata);
        _vdata = NULL;
        _vsize = 0;
    }

    if (_sps != NULL) {
        free(_sps);
        _sps = NULL;
        _spsSize = 0;
    }

    if (_pps != NULL) {
        free(_pps);
        _pps = NULL;
        _ppsSize = 0;
    }

    if (_buf_out != NULL) {
        free(_buf_out);
        _buf_out = NULL;
    }

    self.delegate = nil;
}

- (void)close {
    [self stop];


    NSLog(@"uid:%u decoder close", _uid);
}

-(BOOL)initH264Decoder {
    if (_deocderSession) {
        return YES;
    }

    if (!_sps || !_pps || _spsSize == 0 || _ppsSize == 0) {
        return NO;
    }

    const uint8_t* const parameterSetPointers[2] = { _sps, _pps };
    const size_t parameterSetSizes[2] = { _spsSize, _ppsSize };
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2, //param count
                                                                          parameterSetPointers,
                                                                          parameterSetSizes,
                                                                          4, //nal start code size
                                                                          &_decoderFormatDescription);
    if (status == noErr) {
        NSDictionary* destinationPixelBufferAttributes = @{
                                                           (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
                                                           //硬解必须是 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange 或者是kCVPixelFormatType_420YpCbCr8Planar
                                                           //因为iOS是nv12  其他是nv21
                                                           , (id)kCVPixelBufferWidthKey  : [NSNumber numberWithInt:kH264outputWidth]
                                                           , (id)kCVPixelBufferHeightKey : [NSNumber numberWithInt:kH264outputHeight]
                                                           //, (id)kCVPixelBufferBytesPerRowAlignmentKey : [NSNumber numberWithInt:kH264outputWidth*2]
                                                           , (id)kCVPixelBufferOpenGLCompatibilityKey : [NSNumber numberWithBool:NO]
                                                           , (id)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]
                                                           };

        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = didDecompress;
        callBackRecord.decompressionOutputRefCon = (__bridge void *)self;

        status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                              _decoderFormatDescription,
                                              NULL,
                                              (__bridge CFDictionaryRef)destinationPixelBufferAttributes,
                                              &callBackRecord,
                                              &_deocderSession);
        VTSessionSetProperty(_deocderSession, kVTDecompressionPropertyKey_ThreadCount, (__bridge CFTypeRef)[NSNumber numberWithInt:1]);
        VTSessionSetProperty(_deocderSession, kVTDecompressionPropertyKey_RealTime, kCFBooleanTrue);
    } else {
        NSLog(@"reset decoder session failed status=%d", status);
        return NO;
    }

    return YES;
}

- (BOOL)resetH264Decoder {
    if(_deocderSession) {
        VTDecompressionSessionWaitForAsynchronousFrames(_deocderSession);
        VTDecompressionSessionInvalidate(_deocderSession);
        CFRelease(_deocderSession);
        _deocderSession = NULL;
    }
    return [self initH264Decoder];
}

- (CVPixelBufferRef)decode:(uint8_t *)frame withSize:(uint32_t)frameSize {
    if (frame == NULL || _deocderSession == nil)
        return NULL;

    CVPixelBufferRef outputPixelBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;

    OSStatus status  = CMBlockBufferCreateWithMemoryBlock(NULL,
                                                          (void *)frame,
                                                          frameSize,
                                                          kCFAllocatorNull,
                                                          NULL,
                                                          0,
                                                          frameSize,
                                                          FALSE,
                                                          &blockBuffer);
    if(status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {frameSize};
        //        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
        //                                           blockBuffer,
        //                                           _decoderFormatDescription ,
        //                                           1, 0, NULL, 1, sampleSizeArray,
        //                                           &sampleBuffer);
        status = CMSampleBufferCreate(NULL, blockBuffer, TRUE, 0, 0, _decoderFormatDescription, 1, 0, NULL, 0, NULL, &sampleBuffer);

        if (status == kCMBlockBufferNoErr && sampleBuffer) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            status = VTDecompressionSessionDecodeFrame(_deocderSession,
                                                       sampleBuffer,
                                                       flags,
                                                       &outputPixelBuffer,
                                                       &flagOut);

            if (status == kVTInvalidSessionErr) {
                NSLog(@"Invalid session, reset decoder session");
                [self resetH264Decoder];
            } else if(status == kVTVideoDecoderBadDataErr) {
                NSLog(@"decode failed status=%d(Bad data)", status);
            } else if(status != noErr) {
                NSLog(@"decode failed status=%d", status);
            }
        }

        if (sampleBuffer != NULL)
            CFRelease(sampleBuffer);
    }
    if (blockBuffer != NULL)
        CFRelease(blockBuffer);

    return outputPixelBuffer;
}

- (BOOL)decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize {
    // LOGD(@">>>>>>>>>>开始解码");

    if (frame == NULL || frameSize == 0)
        return NO;

    int size = frameSize;
    const uint8_t *p = frame;
    const uint8_t *end = p + size;
    const uint8_t *nal_start, *nal_end;
    int nal_len, nalu_type;

    size = 0;
    nal_start = avc_find_startcode(p, end);
    while (![[NSThread currentThread] isCancelled]) {
        while (![[NSThread currentThread] isCancelled] && nal_start < end && !*(nal_start++));
        if (nal_start == end)
            break;

        nal_end = avc_find_startcode(nal_start, end);
        nal_len = nal_end - nal_start;

        nalu_type = nal_start[0] & 0x1f;
        if (nalu_type == 0x07) {
            if (_sps == NULL) {
                _spsSize = nal_len;
                _sps = (uint8_t*)malloc(_spsSize);
                memcpy(_sps, nal_start, _spsSize);
            }
        }
        else if (nalu_type == 0x08) {
            if (_pps == NULL) {
                _ppsSize = nal_len;
                _pps = (uint8_t*)malloc(_ppsSize);
                memcpy(_pps, nal_start, _ppsSize);
            }
        }
        else {
            _buf_out[size + 0] = (uint8_t)(nal_len >> 24);
            _buf_out[size + 1] = (uint8_t)(nal_len >> 16);
            _buf_out[size + 2] = (uint8_t)(nal_len >> 8 );
            _buf_out[size + 3] = (uint8_t)(nal_len);

            memcpy(_buf_out + 4 + size, nal_start, nal_len);
            size += 4 + nal_len;
        }

        nal_start = nal_end;
    }

    if ([self initH264Decoder]) {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [self decode:_buf_out withSize:size];
    }

    return size > 0 ? YES : NO;
}

@end



