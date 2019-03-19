//
//  VideoFilter.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/14.
//  Copyright © 2019 QH. All rights reserved.
//  https://www.cnblogs.com/Biaoac/p/5317012.html

#import "VideoFilter.h"
#import "GPUImage.h"

@implementation VideoFilter


+ (void)lookupFilter
{
  // CIFilter 接口文件 找到第120行-140行全部都是 效果分类
  NSLog(@"filter Array %@",[CIFilter filterNamesInCategory:kCICategoryDistortionEffect]);
}

+(CVPixelBufferRef)addFilterForPixelbuffer:(CVPixelBufferRef)pixelbuffer
{
  // 1.获取原视频画面
  CIImage *inputImage = [CIImage imageWithCVPixelBuffer:pixelbuffer];
  // 2.创建一个滤镜
  static CIFilter *filter = nil;
  if (!filter) {
    filter = [CIFilter filterWithName:@"CIBumpDistortion"];
  }
  // 3. 设置滤镜属性值
  [filter setValue:inputImage forKey:kCIInputImageKey];
  [filter setValue:@(100) forKey:kCIInputRadiusKey];
  [filter setValue:[CIVector vectorWithX:200 Y:200] forKey:kCIInputCenterKey];
  // 4.获取原图和滤镜效果合并后的图像
  CIImage *outputImage = filter.outputImage;
  outputImage = [self addfilterLinkerWithImage:outputImage];
  static CVPixelBufferRef buffer = NULL;
  static OSStatus status;
  if (buffer == NULL) {
    CGFloat h = CVPixelBufferGetHeight(pixelbuffer);
    CGFloat w = CVPixelBufferGetWidth(pixelbuffer);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:w], kCVPixelBufferWidthKey, [NSNumber numberWithInt:h], kCVPixelBufferHeightKey, nil];
    status = CVPixelBufferCreate(kCFAllocatorSystemDefault, w, h, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, (__bridge CFDictionaryRef)options, &buffer);
    if (status != noErr) {
      NSLog(@"Crop CVPixelBufferCreate error %d",(int)status);
      return NULL;
    }
  }
  static CIContext *context = nil;
  if (!context) {
    EAGLContext *eaContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    context = [CIContext contextWithEAGLContext:eaContext];
  }
  [context render:outputImage toCVPixelBuffer:buffer];
  
  return buffer;
}

//再次添加滤镜 形成滤镜链
+ (CIImage *)addfilterLinkerWithImage:(CIImage *)image{
  CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
  [filter setValue:image forKey:kCIInputImageKey];
  
  [filter setValue:@0.5 forKey:kCIInputIntensityKey];
//  CIContext *context = [CIContext contextWithOptions:nil];
//  CGImageRef imageRef = [context createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
//  static CIContext *context = nil;
//  if (!context) {
//    EAGLContext *eaContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
//    context = [CIContext contextWithEAGLContext:eaContext];
//  }
  return filter.outputImage;
}

- (UIImage *)imageAddFiler:(UIImage *)image
{
  GPUImageOutput<GPUImageInput>* filter = [[GPUImageFilter alloc] init];
  GPUImagePicture* pic =
  [[GPUImagePicture alloc]
   initWithImage:image];
  [pic addTarget:filter];
  
  [pic processImage];
  [filter useNextFrameForImageCapture];
  // 最终的 image
  UIImage* colorBlendFilterImage =
  [filter imageFromCurrentFramebuffer];
  return colorBlendFilterImage;
}

@end
