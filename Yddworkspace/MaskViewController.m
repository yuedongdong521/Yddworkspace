//
//  MaskViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/11/13.
//  Copyright © 2019 QH. All rights reserved.
//

#import "MaskViewController.h"
#import "UIView+MaskAnimation.h"
#import "UILabel+YDDExtend.h"
#import <QuartzCore/CATransaction.h>

@interface MaskViewController ()

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) CALayer *imageLayer;

@end

@implementation MaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UILabel *label = [[UILabel alloc] init];
    
    label.text = @"今日头条";
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = UIColorHexRGBA(0xFF7FDB, 1);
    label.font = [UIFont systemFontOfSize:30];
    [self.view addSubview:label];
    [label sizeToFit];
    CGSize size = label.frame.size;
    label.frame = CGRectMake((ScreenWidth - size.width) * 0.5, (ScreenHeight - size.height) * 0.5, size.width, size.height);
//    [self addCoverView:label];
//    [label setFontGradColors:@[UIColorHexRGBA(0xFF7FDB, 0.3), UIColorHexRGBA(0xFF7FDB, 1), UIColorHexRGBA(0xFF7FDB, 0.3)]];
    
    
    
    self.label = label;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:@"stop" forState:UIControlStateSelected];
    [button setTitle:@"start" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.bottom.mas_equalTo(-50);
    }];
    
    UIImage *image = [UIImage imageNamed:@"0.jpg"];
    
    CALayer *imageLayer = [[CALayer alloc] init];
    imageLayer.frame = CGRectMake(20, 100, 200, image.size.height * 200 / image.size.width);
    imageLayer.contents = (__bridge id)[image CGImage];
    [self.view.layer addSublayer:imageLayer];
    _imageLayer = imageLayer;
    
    
    
}

- (void)buttonAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (btn.selected) {
        [self.label maskAnimationDuration:0.9 animationWidth:30 repeatCount:MAXFLOAT];
        self.imageLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI, 0, 1, 0);
    } else {
        [self.label maskAnimationStop];
        self.imageLayer.transform = CATransform3DIdentity;
    }
    [CATransaction commit];
}



- (void)addCoverView:(UIView *)view {
    //  添加挡住所有控件的覆盖层(挡住整superview，包括 superview 的子控件)

    // gradientLayer CAGradientLayer是CALayer的一个子类,用来生成渐变色的Layer
    CAGradientLayer *colorLayer = [CAGradientLayer layer];
    colorLayer.frame = (CGRect)view.bounds;
    
    colorLayer.startPoint = CGPointMake(-1.4, 0);
    colorLayer.endPoint = CGPointMake(1.4, 0);
    
    // 颜色分割线
    colorLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.1].CGColor,
                          (__bridge id)[UIColor colorWithWhite:0 alpha:0.1].CGColor,
                          (__bridge id)[UIColor colorWithWhite:1 alpha:0.1].CGColor,
                          (__bridge id)[UIColor colorWithWhite:1 alpha:0.1].CGColor,
                          (__bridge id)[UIColor colorWithWhite:0 alpha:0.1].CGColor];
    
    colorLayer.locations = @[
                             [NSNumber numberWithDouble:colorLayer.startPoint.x],
                             [NSNumber numberWithDouble:colorLayer.startPoint.x],
                             @0,
                             [NSNumber numberWithDouble:0.2],
                             [NSNumber numberWithDouble:1.2]];
    
    [view.layer addSublayer:colorLayer];
    
    // superview添加mask(能显示的遮罩)
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:0].CGPath;
//    maskLayer.frame = view.bounds;
    maskLayer.fillColor = [UIColor blackColor].CGColor; //设置填充色
    maskLayer.strokeColor = [UIColor clearColor].CGColor;
    

    colorLayer.mask = maskLayer;
   
    // 动画 animate
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.fromValue = colorLayer.locations;
    animation.toValue = @[
                          @0,
                          @1,
                          @1,
                          @1.2,
                          @1.2];
    animation.duration = 2.9;
    animation.repeatCount = HUGE;
    [animation setRemovedOnCompletion:NO];
    // 视图添加动画
    [colorLayer addAnimation:animation forKey:@"locations-layer"];

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
