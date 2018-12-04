//
//  ISCutOutPictures.m
//  iShow
//
//  Created by admin on 2017/5/31.
//
//

#import "ISCutOutPictures.h"

@implementation ISCutOutPictures

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
                             withSourceImage:(UIImage*)sourceImage {
  CGSize imageSize = sourceImage.size;
  CGFloat scaledWidth = imageSize.width;
  CGFloat scaledHeight = imageSize.height;
  if (imageSize.width <= 80 && imageSize.height <= 80) {
    scaledWidth = 80;
    scaledHeight = 80;
  } else if (imageSize.width > targetSize.width ||
             imageSize.height > targetSize.height) {
    scaledWidth = targetSize.width;
    scaledHeight = targetSize.height;
  }
  if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
    CGFloat scale =
        scaledWidth / imageSize.width < scaledHeight / imageSize.height
            ? scaledWidth / imageSize.width
            : scaledHeight / imageSize.height;

    scaledWidth = imageSize.width * scale;
    scaledHeight = imageSize.height * scale;
  }

  CGSize thumbnailSize = CGSizeMake(scaledWidth, scaledHeight);
  if (imageSize.width > targetSize.width ||
      imageSize.height > targetSize.height) {
    UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0);
  } else {
    UIGraphicsBeginImageContext(thumbnailSize);
  }

  CGRect thumbnailRect = CGRectZero;
  thumbnailRect.size.width = scaledWidth;
  thumbnailRect.size.height = scaledHeight;

  [sourceImage drawInRect:thumbnailRect];

  UIImage* tempImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return tempImage;
}

+ (UIImage*)imageByScalingAndCroppingSourceImage:(UIImage*)sourceImage {
  CGSize imageSize = sourceImage.size;
  CGSize thumbnailSize =
      [ISCutOutPictures getSizeByScalingAndCroppingForImageSize:imageSize];

  UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0);
  CGRect thumbnailRect = CGRectZero;
  thumbnailRect.size.width = thumbnailSize.width;
  thumbnailRect.size.height = thumbnailSize.height;

  [sourceImage drawInRect:thumbnailRect];

  UIImage* tempImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return tempImage;
}

+ (UIImage*)imageByScalingAndCroppingForDataSize:(CGSize)targetSize
                                 withSourceImage:(UIImage*)sourceImage {
  CGSize imageSize = sourceImage.size;
  CGFloat scaledWidth = targetSize.width;
  CGFloat scaledHeight = targetSize.height;
  if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
    CGFloat scale = (float)targetSize.width / imageSize.width <
                            (float)targetSize.height / imageSize.height
                        ? (float)targetSize.width / imageSize.width
                        : (float)targetSize.height / imageSize.height;

    scaledWidth = imageSize.width * scale;
    scaledHeight = imageSize.height * scale;
  }

  CGSize thumbnailSize = CGSizeMake(scaledWidth, scaledHeight);
  UIGraphicsBeginImageContext(thumbnailSize);
  CGRect thumbnailRect = CGRectZero;
  thumbnailRect.size.width = scaledWidth;
  thumbnailRect.size.height = scaledHeight;

  [sourceImage drawInRect:thumbnailRect];

  UIImage* tempImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return tempImage;
}

+ (CGSize)getImageSizeByScalingAndCroppingForSize:(CGSize)targetSize
                                  withSourceImage:(UIImage*)sourceImage {
  CGSize imageSize = sourceImage.size;
  CGFloat scaledWidth = targetSize.width;
  CGFloat scaledHeight = targetSize.height;
  if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
    CGFloat scale = (float)targetSize.width / imageSize.width <
                            (float)targetSize.height / imageSize.height
                        ? (float)targetSize.width / imageSize.width
                        : (float)targetSize.height / imageSize.height;

    scaledWidth = imageSize.width * scale;
    scaledHeight = imageSize.height * scale;
  }

  CGSize thumbnailSize = CGSizeMake(scaledWidth, scaledHeight);
  return thumbnailSize;
}

+ (CGSize)getImageSizeByScalingAndCroppingForSize:(CGSize)imageSize {
  CGFloat maxWidth = 140;
  CGFloat maxHeight = 140;

  CGSize size =
      [ISCutOutPictures getSizeByScalingAndCroppingForImageSize:imageSize];
  size.width = size.width > maxWidth ? maxWidth : size.width;
  size.height = size.height > maxHeight ? maxHeight : size.height;
  return size;
}

+ (CGSize)getSizeByScalingAndCroppingForImageSize:(CGSize)imageSize {
  CGFloat scaledWidth = imageSize.width;
  CGFloat scaledHeight = imageSize.height;

  CGFloat minWidth = 47;
  CGFloat maxWidth = 140;
  CGFloat minHeight = 47;
  CGFloat maxHeight = 140;

  if (imageSize.width <= minWidth && imageSize.height <= minHeight) {
    scaledWidth = minWidth;
    scaledHeight = minHeight;
  } else if (imageSize.width <= minWidth && imageSize.height > minHeight) {
    scaledWidth = minWidth;
    scaledHeight = minWidth * imageSize.height / imageSize.width;
  } else if (imageSize.width > minWidth && imageSize.height < minHeight) {
    scaledWidth = minHeight * imageSize.width / imageSize.height;
    scaledHeight = minHeight;
  } else if (imageSize.width > maxWidth || imageSize.height > maxHeight) {
    if (CGSizeEqualToSize(imageSize, CGSizeMake(maxWidth, maxHeight)) == NO) {
      CGFloat scale = maxWidth / imageSize.width < maxHeight / imageSize.height
                          ? maxWidth / imageSize.width
                          : maxHeight / imageSize.height;

      scaledWidth = imageSize.width * scale;
      scaledHeight = imageSize.height * scale;
      if (scaledWidth < minWidth) {
        scaledWidth = minWidth;
        scaledHeight = minWidth * scaledHeight / scaledWidth;
      } else if (scaledHeight < minHeight) {
        scaledWidth = minHeight * scaledWidth / scaledHeight;
        scaledHeight = minHeight;
      }
    }
  }
  return CGSizeMake(scaledWidth, scaledHeight);
}

@end
