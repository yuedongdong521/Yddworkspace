//
//  HalfSecondViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/4/11.
//  Copyright © 2019 QH. All rights reserved.
//

#import "HalfSecondViewController.h"

@interface HalfSecondViewController ()

@property (nonatomic, strong) UIView *bgView;

@end

@implementation HalfSecondViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.height.mas_equalTo(ScreenHeight * 0.5);
    }];
    
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [testBtn setTitle:@"pop" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(pushAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:testBtn];
    [testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 50));
        make.left.top.mas_equalTo(20);
    }];
    
    
}

- (void)pushAction
{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromLeft;
    [self.bgView.layer addAnimation:animation forKey:nil];
    [self.bgView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];

    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor cyanColor];
    }
    return _bgView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self pushAction];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@" %@, frame : %@", NSStringFromClass(self.class), NSStringFromCGRect(self.view.frame));
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
