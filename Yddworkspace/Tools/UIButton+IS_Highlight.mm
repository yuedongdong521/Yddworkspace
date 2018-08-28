//
//  UIButton+IS_Highlight.m
//  iShow
//
//  Created by student on 2017/8/31.
//
//

#import "UIButton+IS_Highlight.h"

@implementation UIButton (IS_Highlight)

- (void)setBackgroundColor:(UIColor*)color forState:(UIControlState)state {
  [self setBackgroundImage:[self buttonImageFromColor:color] forState:state];
}

- (UIImage*)buttonImageFromColor:(UIColor*)color {
  CGRect rect = CGRectMake(0, 0, 1000, 1000);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);
  UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return img;
}

@end
