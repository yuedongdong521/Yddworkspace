//
//  CustomTransitionViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/24.
//  Copyright © 2019 QH. All rights reserved.
//

#import "CustomTransitionViewController.h"
#import "CustomTransition.h"


@interface CustomTransitionViewController ()<UINavigationControllerDelegate>

@end

@implementation CustomTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
}

- (UIView *)transitionAnmateView
{
    return nil;
}

/**
 为这个动画添加用户交互
 */
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController NS_AVAILABLE_IOS(7_0)
{
    
    
    return nil;
}

/**
 用来自定义转场动画
 要返回一个准守UIViewControllerInteractiveTransitioning协议的对象,并在里面实现动画即可
 1.创建继承自 NSObject 并且声明 UIViewControllerAnimatedTransitioning 的的动画类。
 2.重载 UIViewControllerAnimatedTransitioning 中的协议方法。
 */
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0)
{
    if (![fromVC isKindOfClass:[CustomTransitionViewController class]] ||
        ![toVC isKindOfClass:[CustomTransitionViewController class]] ||
        ![(CustomTransitionViewController *)fromVC transitionAnmateView] ||
        ![(CustomTransitionViewController *)toVC transitionAnmateView]) {
        return nil;
    }
    CustomTransition *transition = [[CustomTransition alloc] init];
    if (operation == UINavigationControllerOperationPush) {
        transition.animationStatus = AnimationStatus_push;
    }
    return transition;
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
