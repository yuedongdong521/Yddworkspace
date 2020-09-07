//
//  KXVideoLoadMoreView.m
//  KXLive
//
//  Created by ydd on 2020/7/2.
//  Copyright © 2020 ibobei. All rights reserved.
//

#import "KXVideoLoadMoreView.h"

#define KXPullupMaskAnimationKey @"KXPullupMaskAnimationKey"

@interface KXVideoLoadMoreView ()

@property (nonatomic, strong) UIView *animationView;

@end

@implementation KXVideoLoadMoreView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.animationView = [[UIView alloc] initWithFrame:self.bounds];
        self.animationView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.animationView];
    }
    return self;
}

- (void)startAnimation
{
    CAGradientLayer *makeLayer = [[CAGradientLayer alloc]init];
    makeLayer.frame = self.animationView.bounds;
    NSArray *startLocations = @[@(0), @(0.45), @(0.5), @(0.55), @(1)];
    NSArray *endLocations = @[@(0), @(0), @(0.5), @(1), @(1)];
    makeLayer.locations = startLocations;
    makeLayer.startPoint = CGPointMake(0, 1);
    makeLayer.endPoint = CGPointMake(1, 1);

    id color1 = (id)[UIColor colorWithWhite:0 alpha:0.0].CGColor;
    id color2 = (id)[UIColor colorWithWhite:0 alpha:0.0].CGColor;
    id color3 = (id)[UIColor colorWithWhite:0 alpha:1].CGColor;

    [makeLayer setColors:@[color1, color2, color3, color2, color1]];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.fromValue = startLocations;
    animation.toValue = endLocations;
    animation.duration = 1;
    animation.repeatCount = MAXFLOAT;
    self.animationView.layer.mask = makeLayer;
    [makeLayer addAnimation:animation forKey:KXPullupMaskAnimationKey];
}

- (void)stopAnimation
{
    [self.animationView.layer.mask removeAllAnimations];
    self.animationView.layer.mask = nil;
}

@end
