//
//  BezierPathViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/7/7.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "BezierPathViewController.h"

@interface BezierPathViewController ()<CAAnimationDelegate>

@property (nonatomic, strong) UIView *sinView;
@property (nonatomic, strong) UIBezierPath *sinPath;
@property (nonatomic, strong) CAShapeLayer *sinLayer;

@property (nonatomic, strong) UIView *cosView;
@property (nonatomic, strong) UIBezierPath *cosPath;
@property (nonatomic, strong) CAShapeLayer *cosLayer;

@property (nonatomic, strong) UIView *tanView;
@property (nonatomic, strong) UIBezierPath *tanPath;
@property (nonatomic, strong) CAShapeLayer *tanLayer;

@property(nonatomic, strong) NSTimer *animationTimer;

@end

@implementation BezierPathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor blackColor];
    _sinView = [self creatBezierPathViewWithFrame:CGRectMake(20, 80, 30 * 2 * M_PI, 60) WithBankgroundColor:[UIColor grayColor]];
  
    _cosView = [self creatBezierPathViewWithFrame:CGRectMake(20, 200, 30 * 2 * M_PI, 60) WithBankgroundColor:[UIColor grayColor]];
    
    _tanView = [self creatBezierPathViewWithFrame:CGRectMake(20, 300, 30 * 2 * M_PI, 60) WithBankgroundColor:[UIColor grayColor]];
    
//    [self drawSinLayer];
//    [self drawCosLayer];
//    [self drawTanLayer];
}

- (UIView *)creatBezierPathViewWithFrame:(CGRect)frame WithBankgroundColor:(UIColor *)color
{
  static int tag = 0;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = color;
    view.layer.masksToBounds = YES;
  view.tag = tag;
  tag++;
    [self.view addSubview:view];
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
  [view addGestureRecognizer:tap];
    return view;
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
  UIView *view = tap.view;
  if (!view) {
    return;
  }

//  [self cabasicAnimationAction:view];
  [self keyFrameAnimation:view];
}

- (void)cabasicAnimationAction:(UIView *)view
{
  CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
  shapeLayer.fillColor = [UIColor clearColor].CGColor;
  shapeLayer.strokeColor = [UIColor cyanColor].CGColor;
  shapeLayer.shouldRasterize = YES;
  [view.layer addSublayer:shapeLayer];
  
  UIBezierPath *orginPath = [self drawSinPathForStartPoint:CGPointMake(0, view.frame.size.height / 2.0) ForA:view.frame.size.height / 2.0 ForWidth:1 ForType:view.tag];
  
  UIBezierPath *path = [self drawSinPathForStartPoint:CGPointMake(0, view.frame.size.height / 2.0) ForA:view.frame.size.height / 2.0 ForWidth:view.frame.size.width ForType:view.tag];
  CABasicAnimation *animatio = [CABasicAnimation animationWithKeyPath:@"path"];
  animatio.duration = 5;
  animatio.repeatCount = HUGE_VALF;
  [animatio setRemovedOnCompletion:NO];
  animatio.fromValue = (id)orginPath.CGPath;
  animatio.toValue = (id)path.CGPath;
  animatio.fillMode = kCAFillModeForwards;
  [shapeLayer addAnimation:animatio forKey:@"animate"];
}

- (void)keyFrameAnimation:(UIView *)view
{
  CAShapeLayer *shapelayer = [[CAShapeLayer alloc] init];
  shapelayer.fillColor = [UIColor clearColor].CGColor;
  shapelayer.strokeColor = [UIColor redColor].CGColor;
  shapelayer.lineWidth = 0.5;
  shapelayer.frame = view.bounds;
  [view.layer addSublayer:shapelayer];
  CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
  NSMutableArray *values = [NSMutableArray array];
  for (int i = 0; i < 5; i++) {
    
    UIBezierPath *path = [self drawBezierPathForStartX:i * ViewW(view) / 4 ForA:ViewH(view) * 0.5 ForWidth:ViewW(view) / 4.0 ForMaxWidth:ViewW(view) ForType:view.tag];
    [values addObject:(__bridge id)path.CGPath];
  }
  keyFrameAnimation.duration = 5;
  keyFrameAnimation.repeatCount = 10;
  keyFrameAnimation.values = values;
  keyFrameAnimation.keyTimes = @[@(1), @(1), @(1), @(1), @(1)];
  [keyFrameAnimation setRemovedOnCompletion:NO];
  [keyFrameAnimation setFillMode:kCAFillModeForwards];
  [shapelayer addAnimation:keyFrameAnimation forKey:@"keyFrameAnimation"];
}

- (UIBezierPath *)drawSinPathForStartPoint:(CGPoint)startPoint ForA:(CGFloat)A ForWidth:(CGFloat)width ForType:(BezierPathType)type
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:startPoint];
    for (int i = 0; i < width; i++) {
        CGFloat y = 0;
        if (type == BezierPathType_sin) {
            y = A * sinf(i * 2 * M_PI / width) + A;
        } else if (type == BezierPathType_cos) {
            y = A * cosf(i * 2 * M_PI / width) + A;
        } else if (type == BezierPathType_tan) {
            y = A * tanf(i * 2 * M_PI / width) + A;
        }
        
        [bezierPath addLineToPoint:CGPointMake(i, y)];
    }
//    [bezierPath closePath];
    return bezierPath;
}

- (UIBezierPath *)drawBezierPathForStartX:(CGFloat)startX ForA:(CGFloat)A ForWidth:(CGFloat)width ForMaxWidth:(CGFloat)maxWidth ForType:(BezierPathType)type
{
  CGFloat x = startX;
  UIBezierPath *path = [UIBezierPath bezierPath];
  CGFloat endW = width + x;
  for (CGFloat i = x; i <= endW; i++) {
    CGFloat y = 0;
    switch (type) {
      case BezierPathType_sin:
        y = A * sin(i / maxWidth * 2 * M_PI) + A;
        break;
      case BezierPathType_cos:
        y = A * cos(i / maxWidth * 2 * M_PI) + A;
        break;
      case BezierPathType_tan:
        y = tan(i / maxWidth * 2 * M_PI);
        break;
      default:
        break;
    }
    if (i == x) {
      [path moveToPoint:CGPointMake(i, y)];
    } else {
      [path addLineToPoint:CGPointMake(i, y)];
    }
  }
  return path;
}

- (void)drawSinLayer
{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor cyanColor].CGColor;
    shapeLayer.shouldRasterize = YES;
    shapeLayer.frame = _sinView.bounds;
    shapeLayer.path = [self drawSinPathForStartPoint:CGPointMake(0, _sinView.frame.size.height / 2.0) ForA:_sinView.frame.size.height / 2.0 ForWidth:_sinView.frame.size.width ForType:BezierPathType_sin].CGPath;
    [_sinView.layer addSublayer:shapeLayer];
}

- (void)drawCosLayer
{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor cyanColor].CGColor;
    shapeLayer.shouldRasterize = YES;
    shapeLayer.frame = _cosView.bounds;
    shapeLayer.path = [self drawSinPathForStartPoint:CGPointMake(0, _cosView.frame.size.height / 2.0) ForA:_cosView.frame.size.height / 2.0 ForWidth:_cosView.frame.size.width ForType:BezierPathType_cos].CGPath;
    [_cosView.layer addSublayer:shapeLayer];
}

- (void)drawTanLayer
{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor cyanColor].CGColor;
    shapeLayer.shouldRasterize = YES;
    shapeLayer.frame = _tanView.bounds;
    shapeLayer.path = [self drawSinPathForStartPoint:CGPointMake(0, _tanView.frame.size.height / 2.0) ForA:_tanView.frame.size.height / 2.0 ForWidth:_tanView.frame.size.width ForType:BezierPathType_tan].CGPath;
    [_tanView.layer addSublayer:shapeLayer];
}

- (void)startAnamition:(UIView *)view
{
  NSInteger tag = view.tag;
  CGFloat width = view.frame.size.width;
  CGFloat heigth = view.frame.size.height;
  static CGFloat lastX = 0;
  
  static CGFloat lastY = 0;
  __block CGFloat x = 0;
  
  _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    if (x > width) {
      x = 0;
    }
    CGFloat y = 0;
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    switch (tag) {
      case BezierPathType_sin:
        y = heigth * 0.5 * sin(x / width * 2 * M_PI) + heigth * 0.5;
        break;
      case BezierPathType_cos:
        y = heigth * 0.5 * cos(x / width * 2 * M_PI) + heigth * 0.5;
        break;
      case BezierPathType_tan:
        y = tan(x / width * 3 * M_PI);
        break;
      default:
        break;
    }
    [bezierPath moveToPoint:CGPointMake(lastX, lastY)];
    [bezierPath addLineToPoint:CGPointMake(x, y)];
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor cyanColor].CGColor;
    shapeLayer.shouldRasterize = YES;
    shapeLayer.path = bezierPath.CGPath;
    [view.layer addSublayer:shapeLayer];
    x++;
    lastX = x;
    lastY = y;
  }];
}

- (void)addGroupAnimation
{
  CAShapeLayer *shapelayer = [[CAShapeLayer alloc] init];
  shapelayer.fillColor = [UIColor clearColor].CGColor;
  shapelayer.strokeColor = [UIColor greenColor].CGColor;
  shapelayer.shouldRasterize = YES;
  [_sinView.layer addSublayer:shapelayer];

  CGFloat A = ViewH(_sinView) * 0.5;
  CGFloat W = ViewW(_sinView);
  CGPoint startP = CGPointMake(0, A * sin(0) + A);
  CGPoint sendP = CGPointMake(W / 4.0, A * sin(M_PI_2) + A);
  UIBezierPath *path1 = [[UIBezierPath alloc] init];
  [path1 moveToPoint:CGPointZero];
  [path1 addLineToPoint:startP];
  
  UIBezierPath *path2 = [[UIBezierPath alloc] init];
  [path2 moveToPoint:startP];
  [path2 addLineToPoint:sendP];
  [path2 addLineToPoint:CGPointMake(W / 2.0, A * sin(M_PI) + A)];
  [path2 addLineToPoint:CGPointMake(W / 4.0 * 3, A * sin(M_PI * 3 / 2) + A)];
  [path2 addLineToPoint:CGPointMake(W / 4.0 * 3, A * sin(M_PI * 3 / 2) + A)];
  
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
  animation.delegate = self;
  animation.repeatCount = 10;
  animation.duration = 1.0;
  [animation setRemovedOnCompletion:YES];
  animation.fillMode =  kCAFillModeForwards;
  [animation setFromValue:(id)path1.CGPath];
  
  
  
  [animation setToValue:(id)path2.CGPath];
  [shapelayer addAnimation:animation forKey:@"animate1"];
  
}

- (void)animationDidStart:(CAAnimation *)anim
{
  
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
