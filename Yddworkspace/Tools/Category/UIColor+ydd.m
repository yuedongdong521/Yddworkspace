//
//  UIColor+ydd.m
//  Yddworkspace
//
//  Created by ispeak on 2018/3/9.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "UIColor+ydd.h"

@implementation UIColor (ydd)

+ (instancetype)colorWithHexStr:(NSString *)hexStr
{
    unsigned long hex = [self strToHexWithStr:hexStr];
    CGFloat r = ((hex & 0xff0000) >> 16) / 255.0;
    CGFloat g = ((hex & 0xff00) >> 8) / 255.0;
    CGFloat b = (hex & 0xff) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

+ (unsigned long)strToHexWithStr:(NSString *)hexStr
{
   unsigned long hex = strtoul([hexStr UTF8String], 0, 16);
    return hex;
}

@end
