//
//  AnimationViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2016/11/10.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "AnimationViewController.h"
#import "TextRollAnimationLabel.h"
#import "UIView+Extend.h"

@interface AnimationViewController ()

@property(nonatomic, retain) UIImageView *animationView;
@property (nonatomic, assign) int angle;
@property (nonatomic, strong) TextRollAnimationLabel *label;


@end

@implementation AnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.angle = 0;
    self.animationView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"0" ofType:@"jpg"]]];
    self.animationView.contentMode = UIViewContentModeScaleAspectFill;
    self.animationView.frame = self.view.bounds;
    [self.view addSubview:self.animationView];
    [self iOS8BlurImageImplement];
//     Do any additional setup after loading the view.
    
    
    _label = [[TextRollAnimationLabel alloc] init];
    _label.text = @"self.animationView.contentMode = UIViewContentModeScaleAspectFill;";
    _label.speed = 100;
    _label.repeatCount = MAXFLOAT;
    _label.dealyTime = 1;
    [self.view addSubview:self.label];
    [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(100);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0.jpg"]];
    imageView.frame = CGRectMake(20, 500, 50, 50);
    [imageView addMaskLayerImage:[UIImage imageNamed:@"headBoxCrown"]];
    [self.view addSubview:imageView];
    
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(20);
//        make.bottom.mas_equalTo(50);
//        make.left.right.mas_equalTo(50);
//    }];
    
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
    [self.label startAnimationFinished:^(BOOL flag) {
        
    }];
    
    [self startAnimation];
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
