//
//  ProgressViewController.m
//  yddZS
//
//  Created by ydd on 2018/10/25.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import "ProgressViewController.h"
#import "ProgressView.h"

@interface ProgressViewController ()

@property (nonatomic, strong) ProgressView *progressView;

@end

@implementation ProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor grayColor];
  
  
  self.progressView.frame = CGRectMake(20, 100, 300, 30);
  [self.view addSubview:self.progressView];
  __block CGFloat rate = 0;
  __weak typeof(self) weakself = self;
  NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    if (rate >= 1) {
      rate = 0;
    }
    weakself.progressView.progressValue = rate;
    rate += 0.01;
  }];
  
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
  
}


- (ProgressView *)progressView
{
  if (!_progressView) {
    _progressView = [[ProgressView alloc] init];
    
  }
  return _progressView;
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
