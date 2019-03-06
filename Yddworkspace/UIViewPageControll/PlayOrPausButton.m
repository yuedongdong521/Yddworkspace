//
//  PlayOrPausButton.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/15.
//  Copyright © 2019 QH. All rights reserved.
//

#import "PlayOrPausButton.h"

@interface PlayOrPausButton ()

@property(nonatomic, strong) UIBezierPath *playPath;
@property(nonatomic, strong) UIBezierPath *pausPath;

@property(nonatomic, strong) UIBezierPath *playRotaPath;

@property(nonatomic, strong) CAShapeLayer *btnLayer;
@property(nonatomic, strong) CAShapeLayer *borderLayer;


@end

@implementation PlayOrPausButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
  [super layoutSubviews];
}

- (instancetype)initWithFrame:(CGRect)frame imgSize:(CGFloat)imgSize
{
  self = [super initWithFrame:frame];
  if (self) {
    _imgSize = imgSize;
    [self.layer addSublayer:self.btnLayer];
    
  }
  return self;
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType frame:(CGRect)frame imgSize:(CGFloat)imgSize
{
  PlayOrPausButton *btn = [super buttonWithType:buttonType];
  if (btn) {
    btn.frame = frame;
    btn.imgSize = imgSize;
    [btn.layer addSublayer:btn.borderLayer];
    [btn.layer addSublayer:btn.btnLayer];
    
  }
  return btn;
}

- (CAShapeLayer *)borderLayer
{
  if (!_borderLayer) {
    _borderLayer = [[CAShapeLayer alloc] init];
    CGFloat borderSize = _imgSize + 30;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    _borderLayer.frame = self.bounds;
    _borderLayer.lineWidth = 5;
    _borderLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(w * 0.5, h * 0.5) radius:borderSize * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES].CGPath;
    _borderLayer.strokeColor = [UIColor greenColor].CGColor;
    _borderLayer.fillColor = [UIColor clearColor].CGColor;
    _borderLayer.shouldRasterize = YES;
  }
  return _borderLayer;
}

- (CAShapeLayer *)btnLayer
{
  if (!_btnLayer) {
    _btnLayer = [[CAShapeLayer alloc] init];
    _btnLayer.strokeColor = [UIColor clearColor].CGColor;
    _btnLayer.fillColor = [UIColor greenColor].CGColor;
    _btnLayer.frame = self.bounds;
    _btnLayer.shouldRasterize = YES;
  }
  return _btnLayer;
  
}

- (UIBezierPath *)playPath
{
  if (!_playPath) {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat startX = (w - _imgSize) * 0.5;
    CGFloat startY = (h - _imgSize) * 0.5;

    CGPoint p1, p2, p3, p4, p5, p6, p7, p8;
    p1 = CGPointMake(startX, startY);
    p2 = CGPointMake(p1.x + _imgSize / 2.0, p1.y + _imgSize / 4.0);
    p3 = CGPointMake(p2.x, p1.y + _imgSize - _imgSize / 4.0);
    p4 = CGPointMake(p1.x, p1.y + _imgSize);
    
    p5 = p2;
    p6 = CGPointMake(p1.x + _imgSize, p1.y + _imgSize / 2.0);
    p7 = p6;
    p8 = p3;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path addLineToPoint:p4];
    [path closePath];
    
    [path moveToPoint:p5];
    [path addLineToPoint:p6];
    [path addLineToPoint:p7];
    [path addLineToPoint:p8];
    [path closePath];
    
    _playPath = path;
  }
  return _playPath;
}

- (UIBezierPath *)playRotaPath
{
  if (!_playRotaPath) {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat startX = (w - _imgSize) * 0.5;
    CGFloat startY = (h - _imgSize) * 0.5;
    
    CGPoint p1, p2, p3, p4, p5, p6, p7, p8;
    p1 = CGPointMake(startX, startY);
    p2 = CGPointMake(p1.x + _imgSize, p1.y + _imgSize / 2);
    p3 = CGPointMake(p2.x, p1.y + _imgSize - _imgSize / 4.0);
    p4 = CGPointMake(p1.x, p1.y + _imgSize);
    
    p5 = p2;
    p6 = CGPointMake(p1.x + _imgSize, p1.y + _imgSize / 2.0);
    p7 = p6;
    p8 = p3;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path addLineToPoint:p4];
    [path closePath];
    
    [path moveToPoint:p5];
    [path addLineToPoint:p6];
    [path addLineToPoint:p7];
    [path addLineToPoint:p8];
    [path closePath];
    
    _playRotaPath = path;
  }
  return _playRotaPath;
}

- (UIBezierPath *)pausPath
{
  if (!_pausPath) {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat startX = (w - _imgSize) * 0.5;
    CGFloat startY = (h - _imgSize) * 0.5;
    CGFloat width = _imgSize / 3.0;
    CGPoint p1, p2, p3, p4, p5, p6, p7, p8;
    p1 = CGPointMake(startX, startY);
    p2 = CGPointMake(startX + width, startY);
    p3 = CGPointMake(startX + width, startY + _imgSize);
    p4 = CGPointMake(startX, startY + _imgSize);
    
    p5 = CGPointMake(startX + 2 * width, startY);
    p6 = CGPointMake(startX + 3 * width, startY);
    p7 = CGPointMake(startX + 3 * width, startY + _imgSize);
    p8 = CGPointMake(startX + 2 * width, startY + _imgSize);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path addLineToPoint:p4];
    [path closePath];
    
    [path moveToPoint:p5];
    [path addLineToPoint:p6];
    [path addLineToPoint:p7];
    [path addLineToPoint:p8];
    [path closePath];
    _pausPath = path;
  }
  return _pausPath;
}

- (void)setPlay:(BOOL)isPlay animated:(BOOL)animated
{
  CGPathRef toPath = isPlay ? self.playPath.CGPath : self.pausPath.CGPath;
  CGPathRef fromPath = isPlay ? self.pausPath.CGPath : self.playPath.CGPath;
  
  if (animated) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id _Nullable)(fromPath);
    animation.toValue = (__bridge id _Nullable)(toPath);
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    animation.duration = 0.3;
    
    CAMediaTimingFunction *timeFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [animation setTimingFunction:timeFunction];
    
    [_btnLayer addAnimation:animation forKey:@"animation"];
  } else {
    _btnLayer.path = toPath;
  }
}


@end
