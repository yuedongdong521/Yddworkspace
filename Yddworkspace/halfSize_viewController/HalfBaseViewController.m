//
//  HalfBaseViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/17.
//  Copyright © 2019 QH. All rights reserved.
//

#import "HalfBaseViewController.h"

@implementation HalfContentView


@end


@interface HalfBaseViewController ()<UIGestureRecognizerDelegate, CAAnimationDelegate>

@property (nonatomic, assign) PUSH_DIRECTION curDrection;

@end

@implementation HalfBaseViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.contentView.alpha = 1;
}

- (void)popViewWillAppear
{
    [self.view addSubview:self.contentView];
    CGFloat top = ScreenHeight * 0.5;
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(top, 0, 0, 0));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:HalfBaseViewControllerDismissKey object:nil];
}


// 禁止子视图响应父视图的手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.contentView]) {
        return NO;
    }
    return YES;
}

- (void)tapAction:(UIGestureRecognizer *)ges
{
    [self dismiss];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self destory];
    if (_dismissFinish) {
        _dismissFinish();
    }
    
}

- (void)destory
{
    
}


- (HalfContentView *)contentView
{
    if (!_contentView) {
        _contentView = [[HalfContentView alloc] init];
    }
    return _contentView;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.contentView.alpha = 0.0;
    
}

- (void)modalPushViewController:(HalfBaseViewController *)viewController Animation:(BOOL)animation direction:(PUSH_DIRECTION)direction
{
    
    __weak typeof(self) wealself = self;
    viewController.didDisAppear = ^{
        __strong typeof(self) strongself = wealself;
        strongself.contentView.alpha = 1;
    };
    viewController.view.alpha = 0;
    [self presentViewController:viewController animated:NO completion:^{
        __strong typeof(self) strongself = wealself;
        viewController.view.alpha = 1;
        if (animation) {
            self.curDrection = direction;
            CATransition *transition = [CATransition animation];
            transition.duration = 0.2;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionMoveIn;
            transition.delegate = strongself;
            
            transition.subtype = strongself.curDrection == PUSH_DIRECTION_RIGHT ? kCATransitionFromRight : kCATransitionFromLeft;
            [viewController.view.layer addAnimation:transition forKey:nil];
        }
    }];
    
}

- (void)modalPopAnimation:(BOOL)animation
{
    if (animation) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype = _curDrection == PUSH_DIRECTION_RIGHT ? kCATransitionFromLeft : kCATransitionFromRight;
        [self.view.layer addAnimation:transition forKey:nil];
    }
    if (_didDisAppear) {
        _didDisAppear();
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
