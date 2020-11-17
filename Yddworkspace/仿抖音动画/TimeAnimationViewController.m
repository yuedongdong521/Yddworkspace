//
//  TimeAnimationViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/8/5.
//  Copyright © 2020 QH. All rights reserved.
//

#import "TimeAnimationViewController.h"
#import "ProgressAnimationView.h"

#define kTimeAnimationKey @"kTimeAnimationKey"

#define aKeyPath(objc, keyPath) @(((void)objc.keyPath, #keyPath))


@interface DrawPathView : UIView

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIView *pointView;

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, strong) UIColor *pointColor;

@end

@implementation DrawPathView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.coverView];
        self.coverView.frame = self.bounds;
        [self addSubview:self.pointView];
    }
    return self;
}

- (void)setPath:(UIBezierPath *)path
{
    _path = path;
    [self setNeedsDisplay];
}

- (void)startWithDuration:(CGFloat)duration option:(UIViewAnimationOptions)option
{
    CGRect frame = self.coverView.frame;
    frame.origin.x = frame.size.width;
    frame.size.width = 0;
    [UIView animateWithDuration:duration delay:0 options:option animations:^{
        self.coverView.frame = frame;
    } completion:^(BOOL finished) {
        if (!finished) {
            self.coverView.frame = frame;
        }
    }];
    
    [self pointAnimation];
}

- (void)pointAnimation
{
    self.pointView.backgroundColor = self.pointColor;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = self.path.CGPath;
    animation.duration = 3;
    animation.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.pointView.layer addAnimation:animation forKey:@"positionKey"];
}


- (void)resetView
{
    self.coverView.frame = self.bounds;
}

- (void)drawRect:(CGRect)rect
{
    [self.lineColor set];
    [_path stroke];
}

- (UIColor *)lineColor
{
    if (!_lineColor) {
        return [UIColor greenColor];
    }
    return _lineColor;
}

- (UIColor *)pointColor
{
    if (!_pointColor) {
        return [UIColor redColor];
    }
    return _pointColor;
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor whiteColor];
    }
    return _coverView;
}

- (UIView *)pointView
{
    if (!_pointView) {
        _pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        _pointView.layer.cornerRadius = 2.5;
        _pointView.layer.masksToBounds = YES;
    }
    return _pointView;
}

@end

@interface PathAnimationView : UIView<CAAnimationDelegate>

@property (nonatomic, strong) NSArray <NSNumber *>*points;

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) DrawPathView *pathView;




@end

@implementation PathAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.pathView = [[DrawPathView alloc] initWithFrame:self.bounds];
        [self addSubview:self.pathView];
        
        
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.bounds;
        _shapeLayer.strokeColor = [UIColor redColor].CGColor;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_shapeLayer];
        
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"flag : %d", flag);
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)startAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fillMode = kCAFillModeBackwards;
    animation.delegate = self;
    
    UIBezierPath *fromPath = [self createPath:YES];
    animation.fromValue = (__bridge id _Nullable)fromPath.CGPath;
    animation.toValue = (__bridge id _Nullable)self.path.CGPath;
    
    animation.duration = 3;
    animation.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    [self.shapeLayer addAnimation:animation forKey:@"path"];
}

- (void)startTowAnimation
{
    self.pathView.path = [self createPath:NO];

    [self.pathView startWithDuration:3 option:UIViewAnimationOptionCurveEaseInOut];
}

- (UIBezierPath *)path
{
    if (!_path) {
        _path = [self createPath:NO];
    }
    return _path;
}

- (UIBezierPath *)createPath:(BOOL)isStart
{
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = isStart ? 0 : self.bounds.size.height;
    
    NSInteger count = _points.count;
    [_points enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat v = 1 - [obj floatValue];
        CGPoint p;
        if (count <= 1) {
            p = CGPointMake(0, v * height);
        } else {
            p = CGPointMake(width * idx / ((CGFloat)count - 1), v * height);
        }
        if (idx == 0) {
            [path moveToPoint:p];
        } else {
            [path addLineToPoint:p];
        }
    }];
    return path;
}

@end


@interface TimeAnimationViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) UIImageView *countDownImageView;

@property (nonatomic, strong) PathAnimationView *animationView;

@property (nonatomic, strong) ProgressAnimationView *progress;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) CAShapeLayer *pointsLayer;

@end

@implementation TimeAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self.view addSubview:self.label];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [self.view addSubview:self.countDownImageView];
    
    [self.countDownImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 75));
    }];
    
    self.count = 30;
    
    self.animationView = [[PathAnimationView alloc] initWithFrame:CGRectMake(20, 300, 300, 50)];
    NSMutableArray *mutArr = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        [mutArr addObject:[NSNumber numberWithFloat:arc4random() % 10 / 10.0]];
    }
    self.animationView.points = mutArr;
    
    [self.view addSubview:self.animationView];
    
    [self.view addSubview:self.progress];
    
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.animationView.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(30);
    }];
    
    [self.view.layer addSublayer:self.shapeLayer];
    self.shapeLayer.frame = CGRectMake(20, 400, 100, 100);
    self.shapeLayer.path = [self drawWithWidth:100].CGPath;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self invalidate];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self startTimeAnimation];
    
    [self.animationView startTowAnimation];
//    [self.animationView startAnimation];
    
    [self.progress updateWithLeft:arc4random() % 300 + 100 right:arc4random() % 300 + 100];
    
    [self startLayerAnimation];
    
}

- (ProgressAnimationView *)progress
{
    if (!_progress) {
        _progress = [[ProgressAnimationView alloc] init];
    }
    return _progress;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:30];
        _label.textColor = [UIColor redColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (void)timerAction
{
    if (self.count <= 0) {
        self.count = 30;
    }
    
    self.countDownImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pk_count_down_0%ld", (long)self.count]];
    
    [self addAnimation];
//    self.label.text = [NSString stringWithFormat:@"%ld", (long)self.count];
    self.count--;
}

- (void)invalidate
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)startTimeAnimation
{
    [self invalidate];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}


- (void)removeAnimation
{
    [_countDownImageView.layer removeAnimationForKey:kTimeAnimationKey];
    _countDownImageView.transform = CGAffineTransformIdentity;
}

- (void)addAnimation
{
    [self removeAnimation];
    
    CGFloat duration = 0.5;
    CABasicAnimation *scaleAni = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAni.fromValue = [NSNumber numberWithFloat:1.5f];
    scaleAni.toValue = [NSNumber numberWithFloat:1.0f];
    scaleAni.duration = duration;
    
    CABasicAnimation *opacityAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAni.fromValue = [NSNumber numberWithFloat:0.0];
    opacityAni.toValue = [NSNumber numberWithFloat:1.0];
    opacityAni.duration = duration;
    opacityAni.fillMode = kCAFillModeForwards;
    opacityAni.autoreverses = YES;
    opacityAni.repeatCount = 1;
    opacityAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *group1 = [CAAnimationGroup animation];
    group1.duration = duration;
    group1.removedOnCompletion = NO;
    group1.repeatCount = 1;
    group1.fillMode = kCAFillModeForwards;
    [group1 setAnimations:@[scaleAni, opacityAni]];
    
    [self.countDownImageView.layer addAnimation:group1 forKey:kTimeAnimationKey];
    
}


- (UIImageView *)countDownImageView
{
    if (!_countDownImageView) {
        _countDownImageView = [[UIImageView alloc] init];
        _countDownImageView.clipsToBounds = YES;
        _countDownImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _countDownImageView;
}


- (UIBezierPath *)drawWithWidth:(CGFloat)width
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(0, width)];
    [path addLineToPoint:CGPointMake(width, width)];
    CGFloat v = cos(M_PI / 6);
    NSLog(@"v = %.3f", v);
    
    [path addLineToPoint:CGPointMake(width * 0.5, width * (1 - cos(M_PI / 6)))];
    [path closePath];
    return path;
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.fillColor = [UIColor greenColor].CGColor;
        _shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        _shapeLayer.lineWidth = 3;
        _shapeLayer.lineCap = kCALineCapSquare;
    }
    return _shapeLayer;
}
/// 画线动画
- (void)startLayerAnimation
{
    if (!self.pointsLayer.superlayer) {
        [self.shapeLayer addSublayer:self.pointsLayer];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 3;
    animation.repeatCount = 10;
    animation.removedOnCompletion = NO;
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.shapeLayer addAnimation:animation forKey:@"strokeEnd"];
    
    CAKeyframeAnimation *pointAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pointAnimation.path = [self drawWithWidth:100].CGPath;
    pointAnimation.duration = 3;
    pointAnimation.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pointAnimation.fillMode = kCAFillModeForwards;
    pointAnimation.removedOnCompletion = NO;
    pointAnimation.repeatCount = 10;
    [self.pointsLayer addAnimation:pointAnimation forKey:@"pointAnimation"];
    
    
}

- (CAShapeLayer *)pointsLayer
{
    if (!_pointsLayer) {
        _pointsLayer = [[CAShapeLayer alloc] init];
        _pointsLayer.frame = CGRectMake(0, 0, 5, 5);
        _pointsLayer.cornerRadius = 2.5;
        _pointsLayer.masksToBounds = YES;
        _pointsLayer.backgroundColor = [UIColor redColor].CGColor;
    }
    return _pointsLayer;
}

@end
