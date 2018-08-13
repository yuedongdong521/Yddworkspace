//
//  BaseNavigationViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/6/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import "WeChatTestFloatViewController.h"

#import "FloadRoundEntryAnimator.h"

@interface BaseNavigationViewController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.delegate = self;
  // 设置导航栏侧滑pop手势
  self.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
  self.interactivePopGestureRecognizer.delegate = self;
  [self.interactivePopGestureRecognizer setEnabled:YES];
  
  UIScreenEdgePanGestureRecognizer *panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationTransition:)];
  panGesture.edges = UIRectEdgeLeft;
  [self.view addGestureRecognizer:panGesture];
}

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan
{
  [WeChatWindow shareWeChatWindow].navController = self;
  [[WeChatWindow shareWeChatWindow] handleNavigationTransition:pan];
}

#pragma mark UIGetureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  return self.viewControllers.count > 1;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
  return YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  if (self.viewControllers.count > 0) {
    viewController.hidesBottomBarWhenPushed = YES;
  }
  [super pushViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(nonnull UIViewController *)fromVC toViewController:(nonnull UIViewController *)toVC
{
  BOOL isCustomTransition = NO;
  if (operation == UINavigationControllerOperationPush) {
    if ([toVC isKindOfClass:[WeChatTestFloatViewController class]]) {
      WeChatTestFloatViewController *testVC = (WeChatTestFloatViewController *)toVC;
      isCustomTransition = testVC.isNeedCustomTransition;
    }
  }  else if (operation == UINavigationControllerOperationPop) {
    if ([fromVC isKindOfClass:[WeChatTestFloatViewController class]]) {
      WeChatTestFloatViewController *testVC = (WeChatTestFloatViewController *)fromVC;
      isCustomTransition = testVC.isNeedCustomTransition;
    }
  }
  if (isCustomTransition) {
    return [[FloadRoundEntryAnimator alloc] initWidthOperation:operation sourceCenter:[WeChatWindow shareWeChatWindow].roundEntryView.center];
  }
  
  return nil;
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
