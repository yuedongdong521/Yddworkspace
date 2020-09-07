//
//  GlodAnimationViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/3/24.
//  Copyright © 2020 QH. All rights reserved.
//

#import "GlodAnimationViewController.h"

@interface KXGoldItem : UIImageView<CAAnimationDelegate>

@end

@implementation KXGoldItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.clipsToBounds = YES;
        self.image = [UIImage imageNamed:@"goldImage"];
    }
    return self;
}


- (void)addAnimationWithPath:(UIBezierPath *)path
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    // 设置动画的路径为心形路径
    animation.path = path.CGPath;
    // 动画时间间隔
    animation.duration = 2.0f;
    // 重复次数为最大值
    animation.repeatCount = 1; // FLT_MAX;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    // 将动画添加到动画视图上
    [self.layer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
   
}

- (UIBezierPath *)pathWithStartPoint:(CGPoint)startPoint
                               midP1:(CGPoint)midP1
                               midP2:(CGPoint)midP2
                            endPoint:(CGPoint)endPoint
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    [path addCurveToPoint:endPoint controlPoint1:midP1 controlPoint2:midP2];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    return path;
}

@end


@interface GlodAnimationView : UIView

@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation GlodAnimationView

- (void)startAnimationRect:(CGRect)rect
{
    int rectX = rect.origin.x;
    int rectW = rect.size.width;
    int rectY = rect.origin.y;
    int rectH = rect.size.height;
    KXGoldItem *item = [[KXGoldItem alloc] init];
    [self addSubview:item];
    int x = arc4random() % rectW + rectX;
    int endX = 0;
    
    CGFloat x1 = 0;
    CGFloat x2 = 0;
    CGFloat centerX = rectX + rectW * 0.5;
    if (fabs(x - centerX) < 20) {
        endX = x + arc4random() % 20;
        x1 = x + (x - centerX) * 0.3;
        x2 = x + (x - centerX) * 0.6;
    } else if (x > centerX) {
        endX = x + arc4random() % (int)(ScreenWidth - x);
        x1 = x + (x - centerX) * 0.3;
        x2 = x + (x - centerX) * 0.6;
    } else {
        endX = arc4random() % x;
        x1 = (centerX - x) * 0.3;
        x2 = (centerX - x) * 0.6;
    }
    item.frame = CGRectMake(x, rectY, 20, 20);
    
    CGPoint midPoint1 = CGPointMake(x1, arc4random() % 100 + 200);
    CGPoint midPoint2 = CGPointMake(x2, arc4random() % 100 + 200);
    UIBezierPath *path = [item pathWithStartPoint:CGPointMake(x, rectY + arc4random() % rectH) midP1:midPoint1 midP2:midPoint2 endPoint:CGPointMake(endX, ScreenHeight)];
    _path = path;
    [item addAnimationWithPath:path];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{

    [[UIColor redColor] set];
    [_path stroke];
}


@end


@interface GlodAnimationViewController ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) CGRect orignRect;

@property (nonatomic, strong) GlodAnimationView *animationView;

@end

@implementation GlodAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.animationView = [[GlodAnimationView alloc] init];
    [self.view addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [touches.anyObject locationInView:self.view];
    _orignRect = CGRectMake(p.x, p.y, 100, 100);
    [self startTimer];
}

- (void)stopTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
}

- (void)startTimer
{
    _count = 0;
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)timerAction
{
    _count++;
    if (_count * 0.02 > 0.5) {
        [self stopTimer];
        return;
    }
    [self.animationView startAnimationRect:_orignRect];
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
