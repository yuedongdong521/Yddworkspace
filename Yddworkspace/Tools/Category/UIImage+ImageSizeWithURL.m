//
//  UIImage+ImageSizeWithURL.m
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "UIImage+ImageSizeWithURL.h"
#import "JSONKit.h"

@implementation UIImage (ImageSizeWithURL)

/**
 *  根据图片url获取图片尺寸
 */
+ (CGSize)getImageSizeWithURL:(id)URL{
  NSURL * url = nil;
  if ([URL isKindOfClass:[NSURL class]]) {
    url = URL;
  }
  if ([URL isKindOfClass:[NSString class]]) {
    url = [NSURL URLWithString:URL];
  }
  if (!URL) {
    return CGSizeZero;
  }
  
  CGSize cacheImageSize = [self getCacheImageSizeWidthImageURL:url.absoluteString];
  if (!CGSizeEqualToSize(cacheImageSize, CGSizeZero)) {
    return cacheImageSize;
  }
  CGImageSourceRef imageSourceRef =     CGImageSourceCreateWithURL((CFURLRef)url, NULL);
  CGFloat width = 0, height = 0;
  if (imageSourceRef) {
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
    if (imageProperties != NULL) {
      CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
      CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
#if defined(__LP64__) && __LP64__
      if (widthNumberRef != NULL) {
        CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
      }
      if (heightNumberRef != NULL) {
        CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
      }
#else
      if (widthNumberRef != NULL) {
        CFNumberGetValue(widthNumberRef, kCFNumberFloat32Type, &width);
      }
      if (heightNumberRef != NULL) {
        CFNumberGetValue(heightNumberRef, kCFNumberFloat32Type, &height);
      }
#endif
      CFRelease(imageProperties);
    }
    CFRelease(imageSourceRef);
  }
  CGSize imageSize = CGSizeMake(width, height);
  [self cacheImageSizeWidthImageURL:url.absoluteString imageSize:imageSize];
  return imageSize;
}

+ (NSString *)getImageSizeCacheDirPath
{
  NSString *directory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
  NSString *dirPath = [directory stringByAppendingPathComponent:@"imageSize"];
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  BOOL isDir;
  BOOL isEX = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
  if (!isDir || !isEX) {
   [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
  }
  return dirPath;
}

+ (CGSize)getCacheImageSizeWidthImageURL:(NSString *)imageURL
{
  NSString *fileName = [NSString stringWithFormat:@"%lu.size", [imageURL hash]];
  NSString *dirPath = [self getImageSizeCacheDirPath];
  NSString *cachePath = [dirPath stringByAppendingPathComponent:fileName];
  NSData *data = [NSData dataWithContentsOfFile:cachePath];
 
  CGSize imageSize = CGSizeZero;
  if (data) {
    NSString *sizeStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (sizeStr && sizeStr.length > 0) {
      imageSize = CGSizeFromString(sizeStr);
    }
  }
  return imageSize;
}

+ (BOOL)cacheImageSizeWidthImageURL:(NSString *)imageURL imageSize:(CGSize)imageSize
{
  NSString *fileName = [NSString stringWithFormat:@"%lu.size", [imageURL hash]];
  NSString *dirPath = [self getImageSizeCacheDirPath];
  NSString *cachePath = [dirPath stringByAppendingPathComponent:fileName];
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  if ([fileManager fileExistsAtPath:cachePath]) {
    [fileManager removeItemAtPath:cachePath error:nil];
  }
  NSString *sizeStr = NSStringFromCGSize(imageSize);
  NSData *data = [sizeStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  if (data) {
    return [data writeToFile:cachePath atomically:YES];
  }
  return NO;
}

+ (void)deleteCacheImageSize
{
  NSString *cachePath = [self getImageSizeCacheDirPath];
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  [fileManager removeItemAtPath:cachePath error:nil];
}



@end
