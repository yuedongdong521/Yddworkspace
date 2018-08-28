//
//  InvocationMethodViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/8/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "InvocationMethodViewController.h"
#import "InvocationMethod.h"
@interface InvocationMethodViewController ()

@property(nonatomic, strong)NSMutableArray *dataArray;
@property(nonatomic, strong)NSMutableArray *dateArr;

@end

@implementation InvocationMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  

  self.view.backgroundColor = [UIColor whiteColor];
  
  
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  static int count = 0;
  int tag = count % self.dataArray.count;
  
  InvocationMethod *method = [[InvocationMethod alloc] init];
  [method doSomethingWithDayStr:self.dateArr[tag] params:self.dataArray[tag]];
  count++;
}


- (NSMutableArray *)dataArray
{
//  周一打篮球
//  周二逛街
//  周三洗衣服
//  周四打游戏
//  周五唱歌
//  其他休息
  if (!_dataArray) {
    _dataArray = [NSMutableArray arrayWithArray:@[@{@"something" : @"打篮球"},
                                                  @{@"something" : @"逛街"},
                                                  @{@"something" : @"洗衣服"},
                                                  @{@"something" : @"打游戏"},
                                                  @{@"something" : @"唱歌"}]];
  }
  return _dataArray;
}

- (NSMutableArray *)dateArr
{
  if (!_dateArr) {
    _dateArr = [NSMutableArray arrayWithArray:@[@"day1", @"day2",@"day3", @"day4",@"day5"]];
  }
  return _dateArr;
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
