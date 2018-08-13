//
//  WeChatTestFloatViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/6/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "WeChatTestFloatViewController.h"

@interface WeChatTestFloatViewController ()
{
 dispatch_queue_t _cx_queue;
 dispatch_queue_t _bx_queue;
}
@end

@implementation WeChatTestFloatViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.navigationController.navigationBar.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  _cx_queue = dispatch_queue_create("changxing_queue", DISPATCH_QUEUE_SERIAL);
  _bx_queue = dispatch_queue_create("bingxing_queue", DISPATCH_QUEUE_CONCURRENT);
  
  
//  dispatch_sync(_bx_queue, ^{
    [self testDispath];
//  });
  
  
  CGFloat red = (arc4random() % 255) / 255.0;
  CGFloat green = (arc4random() % 255) / 255.0;
  CGFloat blue = (arc4random() / 255) / 255.0;
  self.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
  
  CGFloat naviBarRed = (arc4random() % 255) / 255.0;
  CGFloat naviBarGreen = (arc4random() % 255) / 255.0;
  CGFloat naviBarBlue = (arc4random() / 255) / 255.0;
  UIView *naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
  naviBar.backgroundColor = [UIColor colorWithRed:naviBarRed green:naviBarGreen blue:naviBarBlue alpha:1.0];
  [self.view addSubview:naviBar];
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, 44)];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.textColor = [UIColor blackColor];
  titleLabel.text = @"详情";
  [naviBar addSubview:titleLabel];
  
  UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
  back.frame = CGRectMake(20, 20, 44, 44);
  [back addTarget:self action:@selector(backVC) forControlEvents:UIControlEventTouchUpInside];
  [back setTitle:@"<返回" forState:UIControlStateNormal];
  [naviBar addSubview:back];
}

- (void)testDispath
{
  NSLog(@"testDispath task1 : %@", [NSThread currentThread]);
  for (int i = 0; i < 3; i++) {
    dispatch_async(_cx_queue, ^{
      long num = i == 1 ? 100 : 1000000000;
      while (num) {
        num--;
      };
      NSLog(@"testDispath task (%d) : %@", i, [NSThread currentThread]);
    });
  }
  NSLog(@"testDispath task 3 : %@", [NSThread currentThread]);
}

- (void)backVC
{
  [self.navigationController popViewControllerAnimated:YES];
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
