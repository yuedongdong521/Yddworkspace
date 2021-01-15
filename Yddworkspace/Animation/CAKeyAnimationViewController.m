//
//  CAKeyAnimationViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/3/21.
//  Copyright © 2020 QH. All rights reserved.
//

#import "CAKeyAnimationViewController.h"

@interface CAKeyAnimationViewController ()<CAAnimationDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CAKeyAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(20, 100, ScreenWidth - 40, 200)];
    self.bgView.layer.masksToBounds = YES;
    [self.view addSubview:self.bgView];
    UIImage *image = [UIImage imageNamed:@"0.jpg"];
    CGFloat h = image.size.height * ((ScreenWidth - 40) / image.size.width);
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, - (h - 200) / 2, ScreenWidth - 40, h)];
    [self.bgView addSubview:self.imageView];
    self.imageView.image = image;
    
    [self dippingAndHeavingAnimaition];
}

- (void)rmvAnimation {
    CAAnimation * caAnimation = [self.imageView.layer animationForKey:@"liveBgImageViewJitter"];
    if (caAnimation) {
        [self.imageView.layer removeAnimationForKey:@"liveBgImageViewJitter"];
    }
}
// 上下浮动动画
- (void)dippingAndHeavingAnimaition {
    [self rmvAnimation];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    CGRect bgImgViewRect = self.imageView.frame;
    CGFloat height = bgImgViewRect.size.height-self.bgView.frame.size.height; // 浮动尺度
    CGFloat currentY = height + bgImgViewRect.origin.y;
//    animation.speed = 0.1;
    float duration = height/10;
    animation.duration = (duration < 10 ? 10: duration);
    animation.values = @[@(currentY),
                         @(currentY - height/4),
                         @(currentY - height/4*2),
                         @(currentY - height/4*3),
                         @(currentY - height),
                         @(currentY - height/ 4*3),
                         @(currentY - height/4*2),
                         @(currentY - height/4),
                         @(currentY)];
    animation.keyTimes = @[ @(0),
                            @(0.025),
                            @(0.085),
                            @(0.2),
                            @(0.5),
                            @(0.8),
                            @(0.915),
                            @(0.975),
                            @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    /// 设置calculationMode可以避免动画循环时的卡顿问题，但是会导致keyTimes和timingFunction属性失效
    animation.calculationMode = kCAAnimationPaced;
    animation.delegate = self;
    [self.imageView.layer addAnimation:animation forKey:@"liveBgImageViewJitter"];
}
- (void)liveBgImageViewStart {
    [self dippingAndHeavingAnimaition];
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
