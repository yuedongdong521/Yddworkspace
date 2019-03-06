//
//  TestAutoreleasepoolViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/10.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TestAutoreleasepoolViewController.h"
#import <sys/sysctl.h>
#import <mach/mach.h>

@interface TestAutoreleasepoolViewController ()

@end

@implementation TestAutoreleasepoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [self testAutoreleasepool];
}
/*
 @autoreleasepool
 使用条件
 1.如果你编写的程序不是基于 UI 框架的，比如说命令行工具；
 2.如果你编写的循环中创建了大量的临时对象；
 3.如果你创建了一个辅助线程。
 */

- (void)testAutoreleasepool
{
  static const int step = 50000;
  static int iterationCount = 10 * step;
  NSNumber *num = nil;
  NSString *str = nil;
  for (int i = 0; i < iterationCount; i++) {
    @autoreleasepool {
      
      num = [NSNumber numberWithInt:i];
      str = [NSString stringWithFormat:@"打哈萨克的哈克实打实的哈克时间的话大声疾呼多阿萨德爱仕达按时 "];
      
      //Use num and str...whatever...
      [NSString stringWithFormat:@"%@%@", num, str];
      
      if (i % step == 0) {
        double ff  = [self usedMemory];
        NSLog(@"%f",ff);
      }
    }
  }
}

// 获取当前设备可用内存(单位：MB）

- (double)availableMemory
{
  vm_statistics_data_t vmStats;
  mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
  kern_return_t kernReturn = host_statistics(mach_host_self(),
                                             HOST_VM_INFO,
                                             (host_info_t)&vmStats,
                                             &infoCount);
  
  if (kernReturn != KERN_SUCCESS) {
    return NSNotFound;
  }
  
  return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}
             

// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
  task_basic_info_data_t taskInfo;
  mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
  kern_return_t kernReturn = task_info(mach_task_self(),
                                       TASK_BASIC_INFO,
                                       (task_info_t)&taskInfo,
                                       &infoCount);
  
  if (kernReturn != KERN_SUCCESS
      ) {
    return NSNotFound;
  }
  
  return taskInfo.resident_size / 1024.0 / 1024.0;
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
