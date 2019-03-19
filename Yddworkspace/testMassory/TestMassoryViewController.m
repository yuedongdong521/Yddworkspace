//
//  TestMassoryViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/3/8.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TestMassoryViewController.h"

@interface TestMassoryViewController ()

@end

@implementation TestMassoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor grayColor];
  UIView *view1 = [self createViewWithColor:[UIColor redColor]];
  [self.view addSubview:view1];
  [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.mas_equalTo(0);
    make.top.mas_equalTo(80);
    make.height.mas_equalTo(view1.mas_width).multipliedBy(9.0/21);
  }];
  
  UIView *view2 = [self createViewWithColor:[UIColor greenColor]];
  [view1 addSubview:view2];
  [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.mas_equalTo(0);
    make.height.mas_equalTo(view1.mas_height);
    make.width.mas_equalTo(view1.mas_width).dividedBy(3);
    make.width.mas_equalTo(view1).priorityLow();
    make.width.lessThanOrEqualTo(view1);
  }];
  
  
  
  
}

- (UIView *)createViewWithColor:(UIColor *)color
{
  UIView *view = [[UIView alloc] init];
  view.backgroundColor = color;
  return view;
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
