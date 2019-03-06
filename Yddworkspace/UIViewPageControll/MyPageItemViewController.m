//
//  MyPageItemViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/11.
//  Copyright © 2019 QH. All rights reserved.
//

#import "MyPageItemViewController.h"
#import "PlayOrPausButton.h"

@interface MyPageItemViewController ()

@end

@implementation MyPageItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  PlayOrPausButton *btn = [PlayOrPausButton buttonWithType:UIButtonTypeCustom frame:CGRectMake(20, 100, 100, 100) imgSize:25];
  [btn addTarget:self action:@selector(playOrPausBtnAction:) forControlEvents:UIControlEventTouchUpInside];
  btn.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:btn];
  [btn setPlay:btn.selected animated:NO];
  
  
  
}

- (void)playOrPausBtnAction:(PlayOrPausButton *)btn
{
  btn.selected = !btn.selected;
  [btn setPlay:btn.selected animated:YES];
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
