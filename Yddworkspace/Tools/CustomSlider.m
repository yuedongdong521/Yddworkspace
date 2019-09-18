//
//  CustomSlider.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/20.
//  Copyright © 2019 QH. All rights reserved.
//

#import "CustomSlider.h"

@interface ThumButton : UIButton

@end

@implementation ThumButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = self.bounds;
    
    if (CGRectContainsPoint(CGRectInset(rect, -20, -20), point)) {
        return YES;
    }
    return NO;
    
}

@end


@interface CustomSlider ()

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) CAShapeLayer *coverLayer;

@property (nonatomic, strong) CAGradientLayer *sliderLayer;

@property (nonatomic, strong) UIView *thumView;

@end

@implementation CustomSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithHeight:(CGFloat)height
{
    self = [super init];
    if (self) {
        [self.layer addSublayer:self.sliderLayer];
        [self addSubview:self.coverView];
        [self addSubview:self.thumView];
        self.thumView.frame = CGRectMake(0, 0, height, height);
    
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
    [self changeSliderProgress];
    
}

- (void)changeSliderProgress
{
    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;
    CGFloat x = _progress * w;
    CGRect frame = self.bounds;
    frame.origin.x = x;
    frame.size.width = w - x;
    self.coverView.frame = frame;
    self.coverLayer.frame = self.coverView.bounds;
    
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:CGPointMake(0, h * 0.5) radius:h * 0.5 startAngle:M_PI * 3 * 0.5 endAngle:M_PI * 0.5 clockwise:YES];
    [path addLineToPoint:CGPointMake(frame.size.width, h)];
    [path addLineToPoint:CGPointMake(frame.size.width, 0)];
    [path closePath];
    self.coverLayer.path = path.CGPath;
    self.coverView.layer.mask = self.coverLayer;
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.sliderLayer.frame = self.bounds;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.bounds.size.height * 0.5;
    self.thumView.layer.masksToBounds = YES;
    self.thumView.layer.cornerRadius = self.bounds.size.height * 0.5;
    
}

- (void)setBgColor:(UIColor *)bgColor
{
    if (bgColor) {
        self.coverView.backgroundColor = bgColor;
    }
}


- (CAGradientLayer *)sliderLayer
{
    if (!_sliderLayer) {
        _sliderLayer = [[CAGradientLayer alloc] init];
        _sliderLayer.colors = @[(__bridge id)UIColorHexRGBA(0XFFA692, 1).CGColor, (__bridge id)UIColorHexRGBA(0XD15FFF, 1).CGColor];
        _sliderLayer.locations = @[@(0), @(1)];
        _sliderLayer.startPoint = CGPointMake(0, 1);
        _sliderLayer.endPoint = CGPointMake(1, 1);
    }
    return _sliderLayer;
}

- (CAShapeLayer *)coverLayer
{
    if (!_coverLayer) {
        _coverLayer = [[CAShapeLayer alloc] init];
        _coverLayer.backgroundColor = [UIColor clearColor].CGColor;
    }
    return _coverLayer;
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
    }
    return _coverView;
}

- (UIView *)thumView
{
    if (!_thumView) {
        _thumView = [[UIView alloc] init];
        _thumView.backgroundColor = [UIColor redColor];
        
    }
    return _thumView;
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    if (!self.isThumbtn) {
//        return;
//    }
    CGPoint pt = [touches.anyObject locationInView:self];
    CGPoint thumCenter = self.thumView.center;
    CGRect frame =self.thumView.frame;
    CGFloat spaceX = abs((int)(pt.x - thumCenter.x));
    if (spaceX < 50) {
        CGFloat minX = frame.size.width * 0.5;
        CGFloat maxX = self.frame.size.width - minX;
        CGFloat x = pt.x;
        x = x > maxX ? maxX : x < minX ? minX : x;
        
        self.thumView.center = CGPointMake(x, frame.size.height * 0.5);
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = CGRectInset(self.bounds, 0, -20);
    if (CGRectContainsPoint(rect, point)) {
        return YES;
    }
    return NO;
}



@end
