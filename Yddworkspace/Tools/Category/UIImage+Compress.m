//
//  UIImage+Compress.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/4.
//  Copyright © 2019 QH. All rights reserved.
//

#import "UIImage+Compress.h"


@implementation UIImage (Compress)



/** 压缩图片质量 (尽可能保留图片清晰度，图片不会明显模糊,缺点在于，不能保证图片压缩后小于指定大小)*/
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength
{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    NSLog(@"Before compressing Quality loop, image size = %lu KB  %@",(unsigned long)data.length/1024,NSStringFromCGSize(self.size));
    
    if (data.length < maxLength) {
        return data;
    }
    
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
    
    NSLog(@"After compressing Quality loop, image size = %lu KB  %@", (unsigned long)data.length / 1024,NSStringFromCGSize(self.size));
    return data;
}

/** 压缩图片尺寸(压缩图片尺寸可以使图片小于指定大小，但会使图片明显模糊(比压缩图片质量模糊)) */
-(NSData *)compressBySizeWithMaxLength:(NSUInteger)maxLength
{
    UIImage *resultImage = self;
    NSData *data = UIImageJPEGRepresentation(resultImage, 1);
    NSLog(@"Before compressing size loop, image size = %lu KB  %@",(unsigned long)data.length/1024,NSStringFromCGSize(resultImage.size));
    
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        // Use image to draw (drawInRect:), image is larger but more compression time
        // Use result image to draw, image is smaller but less compression time
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, 1);
    }
    NSLog(@"After compressing size loop, image size = %lu KB  %@", (unsigned long)data.length / 1024,NSStringFromCGSize(resultImage.size));
    return data;
}

/** 两种图片压缩方法结合 */
-(NSData *)compressWithMaxLength:(NSUInteger)maxLength
{
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    NSLog(@"Before compressing quality, image size = %lu KB",(unsigned long)data.length/1024);
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        NSLog(@"Compression = %.1f", compression);
        NSLog(@"In compressing quality loop, image size = %lu KB", (unsigned long)data.length / 1024);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    NSLog(@"After compressing quality, image size = %lu KB", (unsigned long)data.length / 1024);
    if (data.length < maxLength) return data;
    
    UIImage *resultImage = [UIImage imageWithData:data];
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        NSLog(@"Ratio = %.1f", ratio);
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
        NSLog(@"In compressing size loop, image size = %lu KB", (unsigned long)data.length / 1024);
    }
    NSLog(@"After compressing size loop, image size = %lu KB  %@", (unsigned long)data.length / 1024,NSStringFromCGSize(resultImage.size));
    return data;
}

/** 1.设置固定size 2.两种图片压缩方法结合 */
-(NSData *)compressWithMaxLength:(NSUInteger)maxLength maxSize:(CGSize)maxSize
{
    if (maxSize.width <= 0 || maxSize.height <= 0) {
        return [self compressWithMaxLength:maxLength];
    }
    
    UIImage *resultImage = self;
    
    CGFloat actualHeight = self.size.height;
    CGFloat actualWidth = self.size.width;
    
    CGFloat fixelW = CGImageGetWidth(self.CGImage);
    CGFloat fixelH = CGImageGetHeight(self.CGImage);
    
    NSLog(@"image原始size = %@",NSStringFromCGSize(self.size));
    NSLog(@"image原始像素信息 = %@",NSStringFromCGSize(CGSizeMake(fixelW, fixelH)));
    NSLog(@"image原始大小 = %@",[self getImageDataLength]);
    
    CGFloat maxHeight = maxSize.height;
    CGFloat maxWidth = maxSize.width;
    
    CGFloat imgRatio = actualWidth/actualHeight;
    CGFloat maxRatio = maxWidth/maxHeight;
    
    if (actualHeight > maxHeight || actualWidth > maxWidth) {
        if (imgRatio < maxRatio) {
            //根据最大高度调整宽度
            imgRatio = maxHeight/actualHeight;
            actualWidth = imgRatio*actualWidth;
            actualHeight = maxHeight;
        } else if(imgRatio > maxRatio) {
            //根据最大宽度调整高度
            imgRatio = maxWidth/actualWidth;
            actualHeight = imgRatio*actualHeight;
            actualWidth = maxWidth;
        } else {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
        
        CGSize size = CGSizeMake(actualWidth, actualHeight);
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        CGFloat fixelW_compress = CGImageGetWidth(resultImage.CGImage);
        CGFloat fixelH_compress = CGImageGetHeight(resultImage.CGImage);
        NSLog(@"image尺寸压缩后size = %@",NSStringFromCGSize(size));
        NSLog(@"image尺寸压缩后像素信息 = %@",NSStringFromCGSize(CGSizeMake(fixelW_compress, fixelH_compress)));
        NSLog(@"image尺寸压缩后大小 = %@",[resultImage getImageDataLength]);
    }
    
    return [resultImage compressWithMaxLength:maxLength];
}

- (NSString *)getImageDataLength
{
    NSData *data = UIImageJPEGRepresentation(self, 1);
    double dataLength = [data length] * 1.0;
    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
    NSInteger index = 0;
    while (dataLength > 1024) {
        dataLength /= 1024.0;
        index ++;
    }
    return [NSString stringWithFormat:@"%.3f %@",dataLength,typeArray[index]];
}





@end
