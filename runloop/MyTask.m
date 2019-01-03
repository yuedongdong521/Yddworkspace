//
//  MyTask.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/2.
//  Copyright © 2019 QH. All rights reserved.
//

#import "MyTask.h"

@implementation MyTask

static NSTimer *_timer;

- (void)main
{
  NSLog(@"开启线程 = %@, curThread = %@", self, [NSThread currentThread]);
  _timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(taskAction:) userInfo:nil repeats:YES];
  [_timer fire];
  [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
  
}

- (void)taskAction:(id)sender
{
  NSLog(@"执行了 NSTimer");
  static int i = 0;
  if (i > 10) {
    if ([_timer isValid]) {
      [_timer invalidate];
    }
  }
  i++;
}

- (void)dealloc
{
  NSLog(@"dealloc mytask = %@", self);
}

@end
