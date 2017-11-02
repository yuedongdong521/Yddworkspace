//
//  MyTabBarViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/1.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MyTabBarViewController.h"
#import "ViewController.h"
#import "MainViewController.h"

@interface MyTabBarViewController ()

@end

@implementation MyTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initItem];
    
}

- (void)initItem
{
    ViewController *vc = [[ViewController alloc] init];
    vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"练习" image:nil selectedImage:nil];

    
    UINavigationController *navig1 = [[UINavigationController alloc] initWithRootViewController:vc];
    navig1.title = @"目录";
    
    MainViewController *mainVC = [[MainViewController alloc] init];
    mainVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:nil selectedImage:nil];
    UINavigationController *navig2 = [[UINavigationController alloc] initWithRootViewController:mainVC];
    navig2.title = @"主页";

    self.viewControllers = @[navig1, navig2];
    self.selectedIndex = 1;
    
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
