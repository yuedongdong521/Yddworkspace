//
//  HalfViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/4/11.
//  Copyright © 2019 QH. All rights reserved.
//

#import "HalfViewController.h"
#import "HalfMainViewController.h"

@interface HalfViewController ()

@property (nonatomic, strong) UIView *pkView;

@property (nonatomic, strong) HalfMainViewController *mainVC;
@property (nonatomic, strong) UIButton *btn;

@end

@implementation HalfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [testBtn setTitle:@"PK" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(pkAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    _btn = testBtn;
    _btn.backgroundColor = [UIColor whiteColor];
    
    [testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 50));
        make.left.bottom.mas_equalTo(-20);
    }];
    
    [self.view addSubview:self.pkView];
    [self.pkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, ScreenHeight * 0.5));
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(ScreenHeight * 0.5);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self pkAction:self.btn];
}


- (void)pkAction:(UIButton *)btn
{
    if (btn.selected) {
        return;
    }
    btn.selected = YES;
    [self.pkView setNeedsLayout];
    [self.pkView layoutIfNeeded];
    CGFloat bottom = self.pkView.frame.origin.y != ScreenHeight ?  ScreenHeight * 0.5 : 0;
    
    
    [self presentViewController:self.mainVC animated:YES completion:nil];
//  [self addChildViewController:self.mainVC];
//    [self.pkView addSubview:self.mainVC.view];
    
//    [self.mainVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsZero);
//    }];
//    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeDiscrete animations:^{
//        [self.pkView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(bottom);
//        }];
//    } completion:^(BOOL finished) {
//        if (bottom < 0) {
//            [self.mainVC.view removeFromSuperview];
//            self.mainVC = nil;
//        }
        btn.selected = NO;
//    }];
}


- (UIView *)pkView
{
    if (!_pkView) {
        _pkView = [[UIView alloc] init];
    }
    return _pkView;
}

- (HalfMainViewController *)mainVC
{
    if (!_mainVC) {
        _mainVC = [[HalfMainViewController alloc] init];
        _mainVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return _mainVC;
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
