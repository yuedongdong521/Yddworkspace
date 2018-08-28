//
//  UIImage+ScallGif.m
//  iShow
//
//  Created by ydd on 2018/8/22.
//

#import "UIImage+ScallGif.h"
#import <CoreGraphics/CoreGraphics.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation UIImage (ScallGif)

+ (NSData *)scallGIFWithData:(NSData *)data scallSize:(CGSize)scallSize scallPath:(NSString *)scallPath {
  if (!data) {
    return nil;
  }
  CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  size_t count = CGImageSourceGetCount(source);
  
  // 读取 gif 循环次数
  int loopCount = [self getGifLoopCountWidthGiftSource:source];
  // 设置 gif 文件属性
  NSDictionary *fileProperties = [self filePropertiesWithLoopCount:loopCount];
  
  NSURL *fileUrl = [NSURL fileURLWithPath:scallPath];
  CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileUrl, kUTTypeGIF , count, NULL);
  NSTimeInterval duration = 0.0f;
  
  for (size_t i = 0; i < count; i++) {
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    UIImage *scallImage = [image scallImageWidthScallSize:scallSize];
    
    NSTimeInterval delayTime = [self frameDurationAtIndex:i source:source];
    duration += delayTime;
    // 设置 gif 每针画面属性
    NSDictionary *frameProperties = [self framePropertiesWithDelayTime:delayTime];
    CGImageDestinationAddImage(destination, scallImage.CGImage, (CFDictionaryRef)frameProperties);
    CGImageRelease(imageRef);
  }
  CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);
  // Finalize the GIF
  if (!CGImageDestinationFinalize(destination)) {
    NSLog(@"Failed to finalize GIF destination");
    if (destination != nil) {
      CFRelease(destination);
    }
    return nil;
  }
  CFRelease(destination);
  CFRelease(source);
  return [NSData dataWithContentsOfFile:scallPath];
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
  frameDuration += 0.1;
  return frameDuration;
}

- (UIImage *)scallImageWidthScallSize:(CGSize)scallSize{
  CGFloat width = self.size.width;
  CGFloat height = self.size.height;
  
  CGFloat scaleFactor = 0.0;
  CGFloat scaledWidth = scallSize.width;
  CGFloat scaledHeight = scallSize.height;
  CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
  
  if (!CGSizeEqualToSize(self.size, scallSize))
  {
    CGFloat widthFactor = scaledWidth / width;
    CGFloat heightFactor = scaledHeight / height;
    
    scaleFactor = MAX(widthFactor, heightFactor);
    
    scaledWidth= width * scaleFactor;
    scaledHeight = height * scaleFactor;
    
    // center the image
    if (widthFactor > heightFactor)
    {
      thumbnailPoint.y = (scallSize.height - scaledHeight) * 0.5;
    }
    else if (widthFactor < heightFactor)
    {
      thumbnailPoint.x = (scallSize.width - scaledWidth) * 0.5;
    }
  }
  CGRect rect;
  rect.origin = thumbnailPoint;
  rect.size = CGSizeMake(scaledWidth, scaledHeight);
  UIGraphicsBeginImageContext(rect.size);
  [self drawInRect:rect];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return  image;
}

+ (NSDictionary *)filePropertiesWithLoopCount:(int)loopCount {
  return @{(NSString *)kCGImagePropertyGIFDictionary:
             @{(NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)}
           };
}

+ (NSDictionary *)framePropertiesWithDelayTime:(NSTimeInterval)delayTime {
  
  return @{(NSString *)kCGImagePropertyGIFDictionary:
             @{(NSString *)kCGImagePropertyGIFDelayTime: @(delayTime)},
           (NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB
           };
}

//获取GIF图片每帧的时长
+ (NSTimeInterval)gifImageDeleyTime:(CGImageSourceRef)imageSource index:(NSInteger)index {
  NSTimeInterval duration = 0;
  CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL);
  if (imageProperties) {
    CFDictionaryRef gifProperties;
    BOOL result = CFDictionaryGetValueIfPresent(imageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties);
    if (result) {
      const void *durationValue;
      if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &durationValue)) {
        duration = [(__bridge NSNumber *)durationValue doubleValue];
        if (duration < 0) {
          if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &durationValue)) {
            duration = [(__bridge NSNumber *)durationValue doubleValue];
          }
        }
      }
    }
  }
  return duration;
}

//获取gif图片的总时长和循环次数
+ (NSTimeInterval)durationForGifData:(NSData *)data{
  //将GIF图片转换成对应的图片源
  CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  //获取其中图片源个数，即由多少帧图片组成
  size_t frameCout = CGImageSourceGetCount(gifSource);
  //定义数组存储拆分出来的图片
  NSMutableArray* frames = [[NSMutableArray alloc] init];
  NSTimeInterval totalDuration = 0;
  for (size_t i=0; i<frameCout; i++) {
    //从GIF图片中取出源图片
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
    //将图片源转换成UIimageView能使用的图片源
    UIImage* imageName = [UIImage imageWithCGImage:imageRef];
    //将图片加入数组中
    [frames addObject:imageName];
    NSTimeInterval duration = [self gifImageDeleyTime:gifSource index:i];
    totalDuration += duration;
    CGImageRelease(imageRef);
  }
  
  //获取循环次数
  NSInteger loopCount;//循环次数
  CFDictionaryRef properties = CGImageSourceCopyProperties(gifSource, NULL);
  if (properties) {
    CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
    if (gif) {
      CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
      if (loop) {
        //如果loop == NULL，表示不循环播放，当loopCount  == 0时，表示无限循环；
        CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
      }
    }
  }
  CFRelease(gifSource);
  return totalDuration;
}


+ (int)getGifLoopCountWidthGiftSource:(CGImageSourceRef)gifSource
{
  //获取循环次数
  int loopCount = 0;//循环次数
  CFDictionaryRef properties = CGImageSourceCopyProperties(gifSource, NULL);
  if (properties) {
    CFDictionaryRef gif = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
    if (gif) {
      CFTypeRef loop = CFDictionaryGetValue(gif, kCGImagePropertyGIFLoopCount);
      if (loop) {
        //如果loop == NULL，表示不循环播放，当loopCount  == 0时，表示无限循环；
        CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
      }
    }
  }
  return loopCount;
}

/**
 合成gif
 
 @param imagePathArray 图片路径数组
 */
+ (void)composeGIF:(NSMutableArray *)imagePathArray savePath:(NSString *)savePath {
  //图像目标
  CGImageDestinationRef destination;
  
  CFURLRef url=CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)savePath, kCFURLPOSIXPathStyle, false);
  
  //通过一个url返回图像目标
  destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imagePathArray.count, NULL);
  
  //设置gif的信息,播放间隔时间,基本数据,和delay时间,可以自己设置
  NSDictionary *frameProperties = [NSDictionary
                                   dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.1], (NSString *)kCGImagePropertyGIFDelayTime, nil]
                                   forKey:(NSString *)kCGImagePropertyGIFDictionary];
  NSDictionary * gifproperty = [self getGifpropertyWithLoopCount:0];
  
  //合成gif
  for (NSString * imagepath in imagePathArray)
  {
    UIImage *image=[UIImage imageWithContentsOfFile:imagepath];
    
    CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
  }
  
  CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifproperty);
  CGImageDestinationFinalize(destination);
  
  CFRelease(destination);
}


+ (NSDictionary *)getGifpropertyWithLoopCount:(int)loopCount
{
  //设置gif信息
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
  
  //颜色
  [dict setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
  
  //颜色类型
  [dict setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
  
  //颜色深度
  [dict setObject:[NSNumber numberWithInt:8] forKey:(NSString*)kCGImagePropertyDepth];
  
  //是否重复
  [dict setObject:[NSNumber numberWithInt:loopCount] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
  
  NSDictionary * gifproperty = [NSDictionary dictionaryWithObject:dict forKey:(NSString *)kCGImagePropertyGIFDictionary];
  return gifproperty;
  
}


+ (NSData *)scallGIFWithData:(NSData *)data scallSize:(CGSize)scallSize {
  if (!data) {
    return nil;
  }
  CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  size_t count = CGImageSourceGetCount(source);
  
  // 设置 gif 文件属性 (0:无限次循环)
  NSDictionary *fileProperties = [self filePropertiesWithLoopCount:0];
  
  NSString *tempFile = [NSTemporaryDirectory() stringByAppendingString:@"scallTemp.gif"];
  NSFileManager *manager = [NSFileManager defaultManager];
  if ([manager fileExistsAtPath:tempFile]) {
    [manager removeItemAtPath:tempFile error:nil];
  }
  NSURL *fileUrl = [NSURL fileURLWithPath:tempFile];
  CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileUrl, kUTTypeGIF , count, NULL);
  
  NSTimeInterval duration = 0.0f;
  for (size_t i = 0; i < count; i++) {
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    UIImage *scallImage = [image scallImageWidthScallSize:scallSize];
    
    NSTimeInterval delayTime = [self frameDurationAtIndex:i source:source];
    duration += delayTime;
    // 设置 gif 每针画面属性
    NSDictionary *frameProperties = [self framePropertiesWithDelayTime:delayTime];
    CGImageDestinationAddImage(destination, scallImage.CGImage, (CFDictionaryRef)frameProperties);
    CGImageRelease(imageRef);
  }
  CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);
  // Finalize the GIF
  if (!CGImageDestinationFinalize(destination)) {
    NSLog(@"Failed to finalize GIF destination");
    if (destination != nil) {
      CFRelease(destination);
    }
    return nil;
  }
  CFRelease(destination);
  CFRelease(source);
  return [NSData dataWithContentsOfFile:tempFile];
}

@end
