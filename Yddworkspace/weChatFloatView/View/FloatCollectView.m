//
//  FloatCollectView.m
//  Yddworkspace
//
//  Created by ydd on 2018/6/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "FloatCollectView.h"

@implementation FloatCollectView

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
    _bgLayer = [[CAShapeLayer alloc] init];
    _bgLayer.frame = self.bounds;
    _bgLayer.fillColor = [UIColor redColor].CGColor;
    [self updateBgLayerPath:YES];
    [self.layer addSublayer:_bgLayer];
  }
  return self;
}

- (void)updateBgLayerPath:(BOOL)isSmall
{
  CGFloat ratio = isSmall ? 1 : 1.3;

  UIBezierPath *path = [[UIBezierPath alloc] init];
  [path moveToPoint:CGPointMake(self.viewSize.width, self.viewSize.height * (1 - ratio))];
  [path addLineToPoint:CGPointMake(self.viewSize.width, self.viewSize.height)];
  [path addLineToPoint:CGPointMake((1 - ratio) * self.viewSize.width, self.viewSize.height)];
  [path addArcWithCenter:CGPointMake(self.viewSize.width, self.viewSize.height) radius:self.viewSize.width * ratio startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
  [path closePath];
  self.bgLayer.path = path.CGPath;
  
  NSLog(@"collectView frame : %@, \n hidden : %d, prentview : %@ \n alp : %f, \n layer.frame : %@",NSStringFromCGRect(self.frame), self.hidden, NSStringFromClass([[self superview] class]), self.alpha, NSStringFromCGRect(self.bgLayer.frame));
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
  return [self.bgLayer containsPoint:point];
}

- (CGSize)viewSize
{
  return self.bounds.size;
}

/**
 *   collectView BezierPath 坐标原理
 *               collectView
 *
 *       o(0.0)|       (width, 0) move起始位置
 *            --|------------|------> x
 *              |            |
 *              |            |
 *              |            |
 *              |            |
 *  (heigth,0)--|------------|---(width,height)圆心位置
 *              |
 *              V
 *              y
 */



@end
