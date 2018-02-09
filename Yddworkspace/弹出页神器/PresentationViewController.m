//
//  PresentationViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/14.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "PresentationViewController.h"

@interface PresentationViewController ()<UIPopoverPresentationControllerDelegate>

@end

@implementation PresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"adapativePresentationStyleForPresentationController()这个方法只会在你 compact-with 的情况下被调用，也就是在这个例子里这个方法只会在iPhone应用里执行这个方法。运行app将得到如下效果。同时我们还设置了一个navagationbar并在他的右边添加了一个Done按钮，这个按钮绑定了一个dissmiss方法用来关闭整个窗口。";
    [self.view addSubview:label];
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationFullScreen;
}

- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    nav.topViewController.navigationItem.rightBarButtonItem = barItem;
    return nav;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
