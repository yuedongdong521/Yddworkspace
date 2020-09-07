//
//  TimeAnimationViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/8/5.
//  Copyright © 2020 QH. All rights reserved.
//

#import "TimeAnimationViewController.h"

#define kTimeAnimationKey @"kTimeAnimationKey"

@interface TimeAnimationViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) UIImageView *countDownImageView;

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
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self invalidate];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self startTimeAnimation];
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

@end
