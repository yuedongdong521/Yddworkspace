//
//  UIColor+Hex.h
//  iShow
//
//  Created by ispeak on 17/3/9.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

/**
 十六进制字符串获取颜色

 @param color color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 @return (UIColor *)
 */
+ (UIColor*)colorWithHexString:(NSString*)color;

+ (UIColor*)colorWithHexString:(NSString*)color alpha:(CGFloat)alpha;

@end
