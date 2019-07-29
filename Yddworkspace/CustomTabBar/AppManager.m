//
//  AppManager.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/22.
//  Copyright © 2019 QH. All rights reserved.
//

#import "AppManager.h"
#import "CustomTabBarController.h"
#import "CustomNavigationController.h"
#import "SideBarView.h"

static AppManager *_manager = nil;

@interface AppManager ()<UIGestureRecognizerDelegate>

@property (nonatomic, readonly) UIWindow *appWindow;

@property (nonatomic, strong) SideBarView *sideBar;

@property (nonatomic, strong) CustomNavigationController *navigation;
@property (nonatomic, strong) CustomTabBarController *tabBar;

@end

@implementation AppManager

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[AppManager alloc] init];
    });
    return _manager;
}

- (UIWindow *)appWindow
{
    return [UIApplication sharedApplication].delegate.window;
}

- (void)addTabBar
{
    
    _tabBar = [[CustomTabBarController alloc] init];
    _navigation = [[CustomNavigationController alloc] initWithRootViewController:_tabBar];
    self.appWindow.rootViewController = _navigation;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sideBarPanGes:)];
    pan.delegate = self;
    [_navigation.view addGestureRecognizer:pan];
    [self.appWindow addSubview:self.sideBar];
    [self.appWindow makeKeyAndVisible];
    
    // 是设置button响应排他性,避免多个控件同时响应
    [[UIButton appearance] setExclusiveTouch:YES];
    if (@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return _tabBar.selectedIndex == 0 && _navigation.viewControllers.count == 1;
}


- (void)sideBarPanGes:(UIPanGestureRecognizer *)pan
{
    CGRect orignRect = [UIScreen mainScreen].bounds;
    CGRect sideBarRect = kSideBarFrame;
    CGFloat viewX = orignRect.origin.x;
    CGFloat sideX = sideBarRect.origin.x;
    CGPoint move = [pan translationInView:self.navigation.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            
            viewX += move.x;
            sideX += move.x;
            if (viewX > kSideBarWidth || sideX > 0) {
                viewX = kSideBarWidth;
                sideX = 0;
            } else if (viewX < 0 || sideX < -kSideBarWidth) {
                viewX = 0;
                sideX = -kSideBarWidth;
            }
            orignRect.origin.x = viewX;
            sideBarRect.origin.x = sideX;
            self.navigation.view.frame = orignRect;
            self.sideBar.frame = sideBarRect;
        }
            break;
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint speed = [pan velocityInView:self.navigation.view];
            viewX = self.navigation.view.frame.origin.x;
            sideX = self.sideBar.frame.origin.x;
            if (fabs(speed.x)  > 200) {
                if (speed.x > 0) {
                    viewX = kSideBarWidth;
                    sideX = 0;
                } else {
                    viewX = 0;
                    sideX = -kSideBarWidth;
                }
            } else {
                CGFloat sideHaflW = kSideBarWidth * 0.5;
                if (viewX > sideHaflW || sideX > -sideHaflW) {
                    viewX = kSideBarWidth;
                    sideX = 0;
                } else {
                    viewX = 0;
                    sideX = -kSideBarWidth;
                }
            }
            orignRect.origin.x = viewX;
            sideBarRect.origin.x = sideX;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.navigation.view.frame = orignRect;
                self.sideBar.frame = sideBarRect;
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        default:
            self.navigation.view.frame = [UIScreen mainScreen].bounds;
            self.sideBar.frame = kSideBarFrame;
            break;
    }
}

- (SideBarView *)sideBar
{
    if (!_sideBar) {
        _sideBar = [[SideBarView alloc] init];
        _sideBar.frame = kSideBarFrame;
    }
    return _sideBar;
}


@end
