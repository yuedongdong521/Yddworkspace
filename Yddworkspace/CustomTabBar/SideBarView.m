//
//  SideBarView.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/22.
//  Copyright © 2019 QH. All rights reserved.
//

#import "SideBarView.h"
#import "UIView+Extend.h"
#import "AppManager.h"
#import "PresentationViewController.h"

@interface SideBarView ()


@end

@implementation SideBarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 100, 100, 100);
        [btn setTitle:@"sideBar" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(sideBarAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

- (void)sideBarAction
{
    UINavigationController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    NSLog(@"%@",NSStringFromSelector(_cmd));
    PresentationViewController *pvc = [[PresentationViewController alloc] init];
//    [vc presentViewController:pvc animated:YES completion:^{
//
//    }];
    [vc pushViewController:pvc animated:YES];
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
