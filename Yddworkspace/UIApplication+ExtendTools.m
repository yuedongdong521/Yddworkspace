//
//  UIApplication+ExtendTools.m
//  Yddworkspace
//
//  Created by ydd on 2019/12/16.
//  Copyright © 2019 QH. All rights reserved.
//

#import "UIApplication+ExtendTools.h"




@implementation UIApplication (ExtendTools)




+ (UIViewController *)curentViewController
{
    UIViewController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    return [self getTopViewControllerWithVC:vc];
}

+ (UIViewController *)getTopViewControllerWithVC:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)vc;
        return [self getTopViewControllerWithVC:tabVC.selectedViewController];
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getTopViewControllerWithVC:((UINavigationController *)vc).visibleViewController];
    } else if (vc.presentedViewController) {
        return [self getTopViewControllerWithVC:vc.presentedViewController];
    } else {
        return vc;
    }
}

@end
