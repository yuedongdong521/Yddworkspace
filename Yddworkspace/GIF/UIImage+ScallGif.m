//
//  UIImage+ScallGif.m
//  iShow
//
//  Created by ydd on 2018/8/22.
//

#import "UIImage+ScallGif.h"
#import "UIImage+GIF.h"

@implementation UIImage (ScallGif)


+ (NSData *)scallGIFWithData:(NSData *)data scallSize:(CGSize)scallSize {
  if (!data) {
    return nil;
  }
  CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  size_t count = CGImageSourceGetCount(source);
  UIImage *animatedImage = nil;
  NSMutableArray *images = [NSMutableArray array];
  NSTimeInterval duration = 0.0f;
  for (size_t i = 0; i < count; i++) {
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
    duration += [self frameDurationAtIndex:i source:source];
    UIImage *ima = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    ima = [ima scallImageWidthSize:scallSize];
    [images addObject:ima];
    CGImageRelease(image);
    if (!duration) {
      duration = (1.0f / 10.0f) * count;
    }
    animatedImage = [UIImage animatedImageWithImages:images duration:duration];
  }
  CFRelease(source);
  return UIImagePNGRepresentation(animatedImage);
}

+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
  float frameDuration = 0.1f;
  CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
  NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
  NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
  
  NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
  if (delayTimeUnclampedProp) {
    frameDuration = [delayTimeUnclampedProp floatValue];
  }
  else {
    
    NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
    if (delayTimeProp) {
      frameDuration = [delayTimeProp floatValue];
    }
  }

  if (frameDuration < 0.011f) {
    frameDuration = 0.100f;
  }
  
  CFRelease(cfFrameProperties);
  return frameDuration;
}

- (UIImage *)scallSize:(CGSize)size{
  if (self.size.width < 200) {
    return self;
  }
  UIGraphicsBeginImageContext(size);
  [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return  image;
}

- (UIImage *)scallImageWidthSize:(CGSize)size{
  UIImage *image = [self compressToByte:2*1024*1024 scallSize:size];
  return  [image scallSize:size];
}

- (UIImage *)compressToByte:(NSUInteger)maxLength scallSize:(CGSize)scallSize {
  // Compress by quality
  CGFloat compression = 1;
  NSData *data = UIImageJPEGRepresentation(self, compression);
  if (data.length < maxLength) return self;
  
  CGFloat max = 1;
  CGFloat min = 0;
  for (int i = 0; i < 6; ++i) {
    compression = (max + min) / 2;
    data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength * 0.9) {
      min = compression;
    } else if (data.length > maxLength) {
      max = compression;
    } else {
      break;
    }
  }
  UIImage *resultImage = [UIImage imageWithData:data];
  if (data.length < maxLength) return resultImage;
  
  // Compress by size
  NSUInteger lastDataLength = 0;
  while (data.length > maxLength && data.length != lastDataLength) {
    lastDataLength = data.length;
    
    CGSize size = CGSizeMake(200, 200);
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    data = UIImageJPEGRepresentation(resultImage, compression);
  }
  resultImage = [UIImage imageWithData:data];
  return resultImage;
}


@end
