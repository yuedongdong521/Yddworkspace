//
//  VideoDataManager.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/9.
//  Copyright © 2019 QH. All rights reserved.
//

#import "VideoDataManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoDataManager

//调整媒体数据的时间
+ (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset{
  CMItemCount count;
  CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
  CMSampleTimingInfo * pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
  CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
  for (CMItemCount i = 0; i < count; i++) {
    pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
    pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
  }
  CMSampleBufferRef sout;
  CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
  free(pInfo);
  return sout;
}

+ (CMSampleBufferRef)useGPUCupSampleBuffer:(CMSampleBufferRef)buffer cupRect:(CGRect)rect
{
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buffer);
  static CVPixelBufferRef pixbuffer = NULL;
  static CMVideoFormatDescriptionRef videoInfo = NULL;
  static OSStatus status;
  /*
  如果要进行页面渲染，需要一个和OpenGL缓冲兼容的图像。用相机API创建的图像已经兼容，您可以马上映射他们进行输入。假设你从已有画面中截取一个新的画面，用作其他处理，你必须创建一种特殊的属性用来创建图像。对于图像的属性必须有kCVPixelBufferIOSurfacePropertiesKey 作为字典的Key.因此以下步骤不可省略
  */
  if (pixbuffer == NULL) {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:rect.size.width], kCVPixelBufferWidthKey, [NSNumber numberWithInt:rect.size.height], kCVPixelBufferHeightKey, nil];
    status = CVPixelBufferCreate(kCFAllocatorSystemDefault, rect.size.width, rect.size.height, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, (__bridge CFDictionaryRef)options, &pixbuffer);
    if (status != noErr) {
      NSLog(@"Crop CVPixelBufferCreate error %d",(int)status);
      return NULL;
    }
  }
  CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
  ciImage = [ciImage imageByCroppingToRect:rect];
  // ciimage get real image不在执行裁剪后的原始点中。所以我们需要平移。
  ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y)];
  static CIContext *ciContext = nil;
  if (ciContext == nil) {
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    ciContext = [CIContext contextWithEAGLContext:eaglContext options:nil];
  }
  [ciContext render:ciImage toCVPixelBuffer:pixbuffer];
  CMSampleTimingInfo sampleTime = {
    .duration = CMSampleBufferGetDuration(buffer),
    .presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(buffer),
    .decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(buffer)
  };
  if (videoInfo == NULL) {
    status = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixbuffer, &videoInfo);
    if (status != 0) {
      NSLog(@"Crop CMVideoFormatDescriptionCreateForImageBuffer error %d",(int)status);
    }
  }
  CMSampleBufferRef cupBuffer;
  status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixbuffer, true, NULL, NULL, videoInfo, &sampleTime, &cupBuffer);
  if (status != 0) {
    NSLog(@"Crop CMSampleBufferCreateForImageBuffer error %d",(int)status);
  }
  return cupBuffer;
}


+ (CMSampleBufferRef)useCPUCupSampleBuffer:(CMSampleBufferRef)sampleBuffer cupRect:(CGRect)rect {
  static OSStatus status;
  NSInteger cupX = ceilf(rect.origin.x);
  NSInteger cupY = ceilf(rect.origin.y);
  NSInteger cupW = ceilf(rect.size.width);
  NSInteger cupH = ceilf(rect.size.height);
  
  //    CVPixelBufferRef pixelBuffer = [self modifyImage:buffer];
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  // Lock the image buffer
  CVPixelBufferLockBaseAddress(imageBuffer,0);
  // Get information about the image
  uint8_t *baseAddress     = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
  size_t  bytesPerRow      = CVPixelBufferGetBytesPerRow(imageBuffer);
  size_t  width            = CVPixelBufferGetWidth(imageBuffer);
  // size_t  height           = CVPixelBufferGetHeight(imageBuffer);
  NSInteger bytesPerPixel  =  bytesPerRow/width;
  
  // YUV 420 Rule
  if (cupX % 2 != 0) cupX += 1;
  NSInteger baseAddressStart = cupY * bytesPerRow + bytesPerPixel * cupX;
  static NSInteger lastAddressStart = 0;
  lastAddressStart = baseAddressStart;
  
  // pixbuffer 与 videoInfo 只有位置变换或者切换分辨率或者相机重启时需要更新，其余情况不需要，Demo里只写了位置更新，其余情况自行添加
  // NSLog(@"demon pix first : %zu - %zu - %@ - %d - %d - %d -%d",width, height, self.currentResolution,_cropX,_cropY,self.currentResolutionW,self.currentResolutionH);
  static CVPixelBufferRef            pixbuffer = NULL;
  static CMVideoFormatDescriptionRef videoInfo = NULL;
  
  // x,y changed need to reset pixbuffer and videoinfo
  if (lastAddressStart != baseAddressStart) {
    if (pixbuffer != NULL) {
      CVPixelBufferRelease(pixbuffer);
      pixbuffer = NULL;
    }
    
    if (videoInfo != NULL) {
      CFRelease(videoInfo);
      videoInfo = NULL;
    }
  }
  
  if (pixbuffer == NULL) {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @(YES), kCVPixelBufferCGImageCompatibilityKey,
                             @(YES),           kCVPixelBufferCGBitmapContextCompatibilityKey,
                             @(cupW),  kCVPixelBufferWidthKey,
                             @(cupH), kCVPixelBufferHeightKey,
                             nil];
    
    status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, cupW, cupH, kCVPixelFormatType_32BGRA, &baseAddress[baseAddressStart], bytesPerRow, NULL, NULL, (__bridge CFDictionaryRef)options, &pixbuffer);
    if (status != 0) {
      NSLog(@"Crop CVPixelBufferCreateWithBytes error %d",(int)status);
      return NULL;
    }
  }
  
  CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  
  CMSampleTimingInfo sampleTime = {
    .duration               = CMSampleBufferGetDuration(sampleBuffer),
    .presentationTimeStamp  = CMSampleBufferGetPresentationTimeStamp(sampleBuffer),
    .decodeTimeStamp        = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
  };
  
  if (videoInfo == NULL) {
    status = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixbuffer, &videoInfo);
    if (status != 0) NSLog(@"Crop CMVideoFormatDescriptionCreateForImageBuffer error %d",(int)status);
  }
  
  CMSampleBufferRef cropBuffer = NULL;
  status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixbuffer, true, NULL, NULL, videoInfo, &sampleTime, &cropBuffer);
  if (status != 0) NSLog(@"Crop CMSampleBufferCreateForImageBuffer error %d",(int)status);
  lastAddressStart = baseAddressStart;
  return cropBuffer;
}


@end
