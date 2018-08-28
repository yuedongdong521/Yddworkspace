//
//  ISListVideoOperation.m
//  iShow
//
//  Created by ispeak on 2018/1/5.
//

#import "ISListVideoOperation.h"

@implementation ISListVideoOperation

- (void)videoPlayTask:(NSString*)videoFilePath {
  NSURL* url = [NSURL fileURLWithPath:videoFilePath];
  AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];

  NSError* error;
  AVAssetReader* assetReader =
      [[AVAssetReader alloc] initWithAsset:asset error:&error];

  NSArray* videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
  if (!videoTracks.count) {
    return;
  }

  AVAssetTrack* videoTrack = [videoTracks objectAtIndex:0];
  UIImageOrientation orientation =
      [self orientationFromAVAssetTrack:videoTrack];

  int m_pixelFormatType = kCVPixelFormatType_32BGRA;
  NSDictionary* options = [NSDictionary
      dictionaryWithObject:[NSNumber numberWithInt:(int)m_pixelFormatType]
                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];

  AVAssetReaderTrackOutput* videoReaderTrackOptput =
      [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack
                                       outputSettings:options];

  [assetReader addOutput:videoReaderTrackOptput];
  [assetReader startReading];

  // 确保nominalFrameRate帧速率 > 0
  // 同时确保当前Operation操作没有取消
  while (assetReader.status == AVAssetReaderStatusReading &&
         videoTrack.nominalFrameRate > 0 && !self.isCancelled) {
    // 依次获取每一帧视频
    CMSampleBufferRef sampleBufferRef =
        [videoReaderTrackOptput copyNextSampleBuffer];
    if (!sampleBufferRef) {
      return;
    }
    // 根据视频图像方向将CMSampleBufferRef每一帧转换成CGImageRef
    CGImageRef imageRef =
        [ISListVideoOperation imageFromSampleBuffer:sampleBufferRef
                                           rotation:orientation];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.videoDecodeBlock) {
        self.videoDecodeBlock(imageRef, videoFilePath);
      }
      // 释放内存
      if (sampleBufferRef) {
        CFRelease(sampleBufferRef);
      }
      if (imageRef) {
        CGImageRelease(imageRef);
      }
    });
    // [NSThread
    // sleepForTimeInterval:CMTimeGetSeconds(videoTrack.minFrameDuration)];
    [NSThread sleepForTimeInterval:0.035];
  }
  // 结束阅读器
  [assetReader cancelReading];
}

- (UIImageOrientation)orientationFromAVAssetTrack:(AVAssetTrack*)videoTrack {
  UIImageOrientation orientation = UIImageOrientationUp;
  CGAffineTransform t = videoTrack.preferredTransform;
  if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
    orientation = UIImageOrientationRight;
  } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
    orientation = UIImageOrientationLeft;
  } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
    orientation = UIImageOrientationUp;
  } else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
    orientation = UIImageOrientationDown;
  }
  return orientation;
}

// 捕捉视频帧，转换成CGImageRef，不用UIImage的原因是因为创建CGImageRef不会做图片数据的内存拷贝，它只会当
// Core Animation执行 Transaction::commit() 触发 layer
// -display时，才把图片数据拷贝到 layer
// buffer里。简单点的意思就是说不会消耗太多的内存！
+ (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
                           rotation:(UIImageOrientation)orientation {
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  // Lock the base address of the pixel buffer
  CVPixelBufferLockBaseAddress(imageBuffer, 0);
  // Get the number of bytes per row for the pixel buffer
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  // Get the pixel buffer width and height
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);
  // Generate image to edit
  unsigned char* pixel =
      (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(
      pixel, width, height, 8, bytesPerRow, colorSpace,
      kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
  CGImageRef image = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
  UIGraphicsEndImageContext();

  return image;
}

@end
