//
//  AnimationViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2016/11/10.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "AnimationViewController.h"

@interface AnimationViewController ()

@property(nonatomic, retain) UIImageView *animationView;
@property (nonatomic, assign) int angle;
@end

@implementation AnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.angle = 0;
    self.animationView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"0" ofType:@"jpg"]]];
    self.animationView.contentMode = UIViewContentModeScaleAspectFill;
    self.animationView.frame = self.view.bounds;
    [self.view addSubview:self.animationView];
    [self iOS8BlurImageImplement];
    // Do any additional setup after loading the view.
}

- (void)iOS8BlurImageImplement
{
    UIBlurEffect *blureffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *bgView = [[UIVisualEffectView alloc] initWithEffect:blureffect];
    bgView.alpha = 0.8;
    bgView.frame = self.view.bounds;
    [self.view addSubview:bgView];
}

 - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self startAnimation];
}

-(void)startAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.05];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(startAnimation)];
    self.angle += 5;
    self.animationView.layer.anchorPoint = CGPointMake(1,1);//以右下角为原点转，（0,0）是左上角转，（0.5,0,5）心中间转，其它以此类推
    self.animationView.transform = CGAffineTransformMakeRotation(self.angle * (M_PI / 180.0f));
    
    [UIView commitAnimations];
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
