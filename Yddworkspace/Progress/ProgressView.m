//
//  ProgressView.m
//  yddZS
//
//  Created by ydd on 2018/10/25.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView ()

@property(nonatomic, strong) CAShapeLayer *progressLayer;
@property(nonatomic, strong) UILabel *valueLabe;

@end

@implementation ProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self.layer addSublayer:self.progressLayer];
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.valueLabe];
    self.valueLabe.hidden = YES;
  }
  return self;
}

- (CAShapeLayer *)progressLayer
{
  if (!_progressLayer) {
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.fillColor = [UIColor purpleColor].CGColor;
    _progressLayer.strokeColor = [UIColor clearColor].CGColor;
  }
  return _progressLayer;
}

- (UILabel *)valueLabe
{
  if (!_valueLabe) {
    _valueLabe = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, 40, 20)];
    _valueLabe.textAlignment = NSTextAlignmentCenter;
    _valueLabe.font = [UIFont systemFontOfSize:10];
  }
  return _valueLabe;
}

- (UIBezierPath*)getLayerPathWithRate:(CGFloat)rate
{
  CGFloat height = self.frame.size.height;
  CGFloat width = self.frame.size.width;
  UIBezierPath *path = [[UIBezierPath alloc] init];
  // 端点类型
  path.lineCapStyle = kCGLineCapRound;
  // 连接类型
  path.lineJoinStyle = kCGLineJoinRound;
  [path moveToPoint:CGPointZero];
  [path addLineToPoint:CGPointMake(0, height)];
  [path addLineToPoint:CGPointMake(width * rate - height, height)];
  [path addLineToPoint:CGPointMake(width * rate, 0)];
  // 封闭线
  [path closePath];
  // 各个点连线
  [path stroke];
  return path;
}

- (void)setProgressValue:(CGFloat)progressValue
{
  _progressValue = progressValue;
  UIBezierPath *path = [self getLayerPathWithRate:progressValue];
  self.progressLayer.path = path.CGPath;
  CGFloat x = self.frame.size.width * progressValue;
  CGRect labelFrame = self.valueLabe.frame;
  labelFrame.origin.x = x + self.frame.size.height;
  self.valueLabe.frame = labelFrame;
  self.valueLabe.text = [NSString stringWithFormat:@"%.2f",progressValue];
  if (progressValue > 1 || progressValue < 0) {
    self.valueLabe.hidden = YES;
  } else {
    self.valueLabe.hidden = NO;
  }
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
  
  
  
}


@end
