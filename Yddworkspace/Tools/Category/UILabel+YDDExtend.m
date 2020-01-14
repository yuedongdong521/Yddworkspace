//
//  UILabel+YDDExtend.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/30.
//  Copyright © 2019 QH. All rights reserved.
//

#import "UILabel+YDDExtend.h"
#import <objc/runtime.h>

const void *_fontGradColorLayer;

@implementation UILabel (YDDExtend)

- (void)setFontGradColors:(NSArray <UIColor *>*)colors
{
    UIView *superView = self.superview;
    if (!superView) {
        return;
    }
    self.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradLayer = [[CAGradientLayer alloc] init];
    CGFloat count = (CGFloat)colors.count;
    NSMutableArray *mutArr = [NSMutableArray array];
    NSMutableArray *locations = [NSMutableArray array];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutArr addObject:(__bridge id)obj.CGColor];
        [locations addObject:@(idx / count)];
    }];
    gradLayer.colors = mutArr;
    gradLayer.locations = locations;
    gradLayer.startPoint = CGPointMake(0, 1);
    gradLayer.endPoint = CGPointMake(1, 1);
    gradLayer.frame = self.frame;
    [superView.layer addSublayer:gradLayer];
    self.frame = gradLayer.bounds;
    gradLayer.mask = self.layer;
}


- (CAGradientLayer *)fontGradLayer
{
    return objc_getAssociatedObject(self, _fontGradColorLayer);
}

- (void)setFontGradLayer:(CAGradientLayer *)fontGradLayer
{
   
    UIView *superView = self.superview;
    if (!superView) {
        return;
    }
    self.backgroundColor = [UIColor clearColor];
    fontGradLayer.frame = self.frame;
    [superView.layer addSublayer:fontGradLayer];
    self.frame = fontGradLayer.bounds;
    fontGradLayer.mask = self.layer;
    objc_setAssociatedObject(self, _fontGradColorLayer, fontGradLayer, OBJC_ASSOCIATION_RETAIN);
}


+ (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)color textAlignment:(NSTextAlignment)alignment
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    label.textAlignment = alignment;
    return label;
}


@end
