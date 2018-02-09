//
//  UIImage+DrawRound.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/30.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "UIImage+DrawRound.h"

@implementation UIImage (DrawRound)

- (UIImage *)drawRoundWithPath:(UIBezierPath *)path Mode:(UIViewContentMode)mode
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:path.bounds];
    imageView.contentMode = mode;
    imageView.image = self;
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, imageView.bounds);
    CGContextClip(context);
    [imageView.image drawInRect:imageView.bounds];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

@end
