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


@end
