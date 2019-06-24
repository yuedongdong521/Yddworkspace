//
//  HalfMainViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/4/11.
//  Copyright © 2019 QH. All rights reserved.
//

#import "HalfMainViewController.h"
#import "HalfSecondViewController.h"

@interface HalfMainViewController ()
@property (nonatomic, strong) UIView *contentView;

@end

@implementation HalfMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
//    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.height.mas_equalTo(ScreenHeight * 0.5);
    }];
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [testBtn setTitle:@"push" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(pushAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:testBtn];
    [testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 50));
        make.left.top.mas_equalTo(20);
    }];
    
    
}

- (void)pushAction
{
    HalfSecondViewController *second = [[HalfSecondViewController alloc] init];
    second.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    UITabBarController *tabVC = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
//    UINavigationController *nav =  tabVC.selectedViewController;
//    [nav pushViewController:second animated:YES];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    
//    animation.type = @"pageCurl";
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromRight;
    [self.contentView.layer addAnimation:animation forKey:nil];
    [self.contentView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];

//    [self presentViewController:second animated:NO completion:nil];
    [self.view addSubview:second.view];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@", NSStringFromClass(self.class));
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
