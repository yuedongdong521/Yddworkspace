//
//  UIImage+ydd.m
//  Yddworkspace
//
//  Created by ydd on 2018/12/7.
//  Copyright © 2018 QH. All rights reserved.
//

#import "UIImage+ydd.h"

static NSString* const kQRCodeFilterName = @"CIQRCodeGenerator";
static NSString* const kFilterKeyPath = @"inputMessage";
static NSString* const kInputCorrectionLevel = @"inputCorrectionLevel";

@implementation UIImage (ydd)
/**
  截取视频、动画等view 时用 layer渲染会导致画面布局异常，建议不用 layer 渲染。
  截取静态图片建议使用 layer 渲染。
 */
+ (UIImage*)screenShotView:(UIView*)view shotLayer:(BOOL)isShotLayer {
  UIGraphicsBeginImageContextWithOptions(view.frame.size, NO,
                                         [UIScreen mainScreen].scale);
  [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
  if (isShotLayer) {
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  }
  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

+ (UIImage*)mergeImageWithImages:(NSArray<UIImage*>*)images {
  CGFloat locationX = 0;
  CGFloat locationY = 0;
  CGSize mergedSize = CGSizeZero;

  for (int i = 0; i < images.count; i++) {
    UIImage* image = images[i];
    mergedSize = CGSizeMake(MAX(mergedSize.width, image.size.width),
                            mergedSize.height + image.size.height);
  }
  UIGraphicsBeginImageContext(mergedSize);
  for (int i = 0; i < images.count; i++) {
    UIImage* image = images[i];
    [image drawInRect:CGRectMake(locationX, locationY, image.size.width,
                                 image.size.height)];
    locationY += image.size.height;
  }
  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

+ (UIImage*)createQrCodeImageWithQrContent:(NSString*)qrContent
                                    qrSize:(CGFloat)qrSize
                                   qrLevel:(NSString*)qrLevel
                                 logoImage:(UIImage*)logoImage
                             logoSizeScale:(CGFloat)logoSizeScale {
  // 创建过滤器
  CIFilter* filter = [CIFilter filterWithName:kQRCodeFilterName];

  // 过滤器恢复默认
  [filter setDefaults];

  // 将NSString格式转化成NSData格式
  NSData* data = [qrContent dataUsingEncoding:NSUTF8StringEncoding];
  [filter setValue:data forKeyPath:kFilterKeyPath];
  /*
   设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
   L　: 7%
   M　: 15%
   Q　: 25%
   H　: 30%
   */
  NSString* level = qrLevel ? qrLevel : @"H";
  [filter setValue:level forKey:kInputCorrectionLevel];
  // 获取二维码过滤器生成的二维码
  CIImage* outputImage = [filter outputImage];
  // 将获取到的二维码添加到imageview上
  if (!outputImage) {
    return nil;
  }
  UIImage* qrImage = [self createNonInterpolatedUIImageFormCIImage:outputImage
                                                          withSize:qrSize];
  if (!logoImage) {
    return qrImage;
  }
  UIImage* mergedImage =
      [self mergedImage:qrImage subImage:logoImage subLevel:logoSizeScale];
  return mergedImage;
}

+ (UIImage*)mergedImage:(UIImage*)image
               subImage:(UIImage*)subImage
               subLevel:(CGFloat)subLevel {
  CGSize mergedSize = image.size;
  UIGraphicsBeginImageContext(mergedSize);

  [image drawInRect:CGRectMake(0, 0, mergedSize.width, mergedSize.height)];
  CGFloat size = MIN(mergedSize.width * subLevel, mergedSize.height * subLevel);
  CGFloat scale = MIN(size / subImage.size.width, size / subImage.size.height);
  CGFloat logoWidth = scale * subImage.size.width;
  CGFloat logoHeight = scale * subImage.size.height;
  CGRect logoRect =
      CGRectMake((mergedSize.width - logoWidth) * 0.5,
                 (mergedSize.height - logoHeight) * 0.5, logoWidth, logoHeight);
  [subImage drawInRect:logoRect];
  UIImage* mergedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return mergedImage;
}

+ (UIImage*)createNonInterpolatedUIImageFormCIImage:(CIImage*)image
                                           withSize:(CGFloat)size {
  CGRect extent = CGRectIntegral(image.extent);
  CGFloat scale =
      MIN(size / CGRectGetWidth(extent), size / CGRectGetHeight(extent));

  // 创建bitmap;
  size_t width = CGRectGetWidth(extent) * scale;
  size_t height = CGRectGetHeight(extent) * scale;
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
  CGContextRef bitmapRef = CGBitmapContextCreate(
      nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);

  CIContext* context = [CIContext contextWithOptions:nil];
  CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
  CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
  CGContextScaleCTM(bitmapRef, scale, scale);
  CGContextDrawImage(bitmapRef, extent, bitmapImage);

  // 保存bitmap到图片
  CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
  UIImage* finalmage = [UIImage imageWithCGImage:scaledImage];

  CGColorSpaceRelease(colorSpace);
  CGImageRelease(scaledImage);
  CGContextRelease(bitmapRef);
  CGImageRelease(bitmapImage);

  return finalmage;
}

+ (NSString*)scanCodeImage:(UIImage*)image {
  //
  if (!image) {
    return @"";
  }
  CIContext* context = [CIContext
      contextWithOptions:
          [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                      forKey:kCIContextUseSoftwareRenderer]];
  if (!context) {
    return @"";
  }
  CIDetector* detector = [CIDetector
      detectorOfType:CIDetectorTypeQRCode
             context:context
             options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
  CIImage* ciImage = [CIImage imageWithCGImage:image.CGImage];
  if (!ciImage) {
    return @"";
  }
  NSArray* features = [detector featuresInImage:ciImage];
  CIQRCodeFeature* feature = [features firstObject];
  if (!feature) {
    return @"";
  }
  NSString* message = feature.messageString;
  return message ? message : @"";
}

@end
