//
//  MainViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/1.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.text = self.title;
    [self.view addSubview:label];
    
    int r = (0x7b7c84 & 0xFF0000) >> 16;
    int g = (0x7b7c84 & 0x00FF00) >> 8;
    int b = (0x7b7c84 & 0x0000FF);
    NSLog(@"color r = %x, g = %x, b = %x", r, g, b);

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    NSLog(@"MainViewController.view.frame2 = %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"MainViewController.view.bounds2 = %@", NSStringFromCGRect(self.view.bounds));
     NSLog(@"MainViewController.edgesForExtendedLayout = %lu", (unsigned long)self.edgesForExtendedLayout);
    NSLog(@"MainViewController.translucent = %d", self.navigationController.navigationBar.translucent);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
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
