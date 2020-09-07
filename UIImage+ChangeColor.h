//
//  UIImage+ChangeColor.h
//  Yddworkspace
//
//  Created by ispeak on 2017/7/13.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ChangeColor)

- (UIImage *)imageChangeColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;


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
                      circular:(BOOL)isCircular;


@end
