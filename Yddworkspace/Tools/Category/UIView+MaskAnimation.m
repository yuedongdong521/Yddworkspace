//
//  UIView+MaskAnimation.m
//  Yddworkspace
//
//  Created by ydd on 2019/11/13.
//  Copyright © 2019 QH. All rights reserved.
//

#import "UIView+MaskAnimation.h"

@implementation UIView (MaskAnimation)

- (void)maskAnimationDuration:(CGFloat)duration
               animationWidth:(CGFloat)animationWidth
                  repeatCount:(NSInteger)repeatCount
{
    NSAssert([self isKindOfClass:[UIView class]], @"必须是UIView子类");

    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc]init];
    gradientLayer.frame = self.bounds;
    CGFloat size = animationWidth / self.frame.size.width;

    NSArray *startLocations = @[@(0), @(size / 2.0), @(size)];
    NSArray *endLocations = @[@(1.0 - size), @(1.0 - (size / 2.0)), @(1)];
    gradientLayer.locations = startLocations;
    gradientLayer.startPoint = CGPointMake(0 - (size * 2.0), 0.5);
    gradientLayer.endPoint = CGPointMake(1 + size, 0.5);
    [gradientLayer setColors:@[(id)UIColorHexRGBA(0xFFFFFF, 0.5).CGColor,
                               (id)UIColorHexRGBA(0xFFFFFF, 1).CGColor,
                               (id)UIColorHexRGBA(0xFFFFFF, 0.5).CGColor]];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.fromValue = startLocations;
    animation.toValue = endLocations;
    animation.duration = duration;
    animation.repeatCount = repeatCount;
    animation.delegate = self;
    self.layer.mask = gradientLayer;
    [gradientLayer addAnimation:animation forKey:@"MaskAnimationKey"];
}


- (void)maskAnimationStop
{
    if (self.layer.mask) {
        [self.layer.mask removeAllAnimations];
        self.layer.mask = nil;
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim valueForKey:@"MaskAnimationKey"]) {
        self.layer.mask = nil;
    }
}

@end
