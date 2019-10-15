//
//  UINavigationController+StatuBar.m
//  Yddworkspace
//
//  Created by ydd on 2019/9/19.
//  Copyright © 2019 QH. All rights reserved.
//

#import "UINavigationController+StatuBar.h"

@implementation UINavigationController (StatuBar)

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.topViewController;
}



@end
