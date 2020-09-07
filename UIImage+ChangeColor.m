//
//  UIImage+ChangeColor.m
//  Yddworkspace
//
//  Created by ispeak on 2017/7/13.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "UIImage+ChangeColor.h"

@implementation UIImage (ChangeColor)

- (UIImage *)imageChangeColor:(UIColor *)color
{
    //获取画布
//    获取画布时，里面三个参数分别代表大小，是否是不透明的，缩放比例。根据原图设置是否是不透明的，如果原图不透明，那么设置为YES，如果是透明的就设置为NO。第三个参数是缩放比例，因为有Retina屏幕，所以设置为0即可，根据屏幕缩放
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    //画笔沾取颜色
    [color setFill];

    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //绘制一次
    [self drawInRect:bounds blendMode:kCGBlendModeOverlay alpha:1.0f];
    //再绘制一次
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    //获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 绘制图片
 
 @param color 背景色
 @param size 大小
 @param text 文字
 @param textAttributes 字体设置
 @param isCircular 是否圆形
 @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color
                          size:(CGSize)size
                          text:(NSString *)text
                textAttributes:(NSDictionary *)textAttributes
                      circular:(BOOL)isCircular
{
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // circular
    if (isCircular) {
        CGPathRef path = CGPathCreateWithEllipseInRect(rect, NULL);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGPathRelease(path);
    }
    
    // color
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    // text
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    [text drawInRect:CGRectMake((size.width - textSize.width) / 2, (size.height - textSize.height) / 2, textSize.width, textSize.height) withAttributes:textAttributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
