//
//  RunLoopViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/2.
//  Copyright © 2019 QH. All rights reserved.
//

/*
RunLoop的定义

当有持续的异步任务需求时，我们会创建一个独立的生命周期可控的线程。RunLoop就是控制线程生命周期并接收事件进行处理的机制。

RunLoop是iOS事件响应与任务处理最核心的机制，它贯穿iOS整个系统。

Foundation: NSRunLoop
Core Foundation: CFRunLoop 核心部分，代码开源，C 语言编写，跨平台

目的

通过RunLoop机制实现省电，流畅，响应速度快，用户体验好

理解

进程是一家工厂，线程是一个流水线，Run Loop就是流水线上的主管；当工厂接到商家的订单分配给这个流水线时，Run Loop就启动这个流水线，让流水线动起来，生产产品；当产品生产完毕时，Run Loop就会暂时停下流水线，节约资源。
RunLoop管理流水线，流水线才不会因为无所事事被工厂销毁；而不需要流水线时，就会辞退RunLoop这个主管，即退出线程，把所有资源释放。

RunLoop并不是iOS平台的专属概念，在任何平台的多线程编程中，为控制线程的生命周期，接收处理异步消息都需要类似RunLoop的循环机制实现，Android的Looper就是类似的机制。

特性

主线程的RunLoop在应用启动的时候就会自动创建
其他线程则需要在该线程下自己启动
不能自己创建RunLoop
RunLoop并不是线程安全的，所以需要避免在其他线程上调用当前线程的RunLoop
RunLoop负责管理autorelease pools
RunLoop负责处理消息事件，即输入源事件和计时器事件
 

 RunLoop 运行时主要有以下六种状态：

 kCFRunLoopEntry -- 进入runloop循环
 kCFRunLoopBeforeTimers -- 处理定时调用前回调
 kCFRunLoopBeforeSources -- 处理input sources的事件
 kCFRunLoopBeforeWaiting -- runloop睡眠前调用
 kCFRunLoopAfterWaiting -- runloop唤醒后调用
 kCFRunLoopExit -- 退出runloop
 
 Run Loop Modes
 理解
 Run Loop Mode就是流水线上支持生产的产品类型，流水线在一个时刻只能在一种模式下运行，生产某一类型的产品。消息事件就是订单。
 
 Cocoa定义了四中Mode
 
 Default：NSDefaultRunLoopMode，默认模式，在Run Loop没有指定Mode的时候，默认就跑在Default Mode下
 Connection：NSConnectionReplyMode，用来监听处理网络请求NSConnection的事件
 Modal：NSModalPanelRunLoopMode，OS X的Modal面板事件
 Event tracking：UITrackingRunLoopMode，拖动事件
 Common mode：NSRunLoopCommonModes，是一个模式集合，当绑定一个事件源到这个模式集合的时候就相当于绑定到了集合内的每一个模式
 
*/

#import "RunLoopViewController.h"
#import "MyTask.h"

@interface RunLoopViewController ()

@end

@implementation RunLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  
  
  [self testAction];
  
  
  
}


- (void)testAction
{
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  MyTask *task0 = [[MyTask alloc] init];
  [queue addOperation:task0];
  
//  MyTask *task1 = [[MyTask alloc] init];
//  [queue addOperation:task1];
//  
//  MyTask *task2 = [[MyTask alloc] init];
//  [queue addOperation:task2];
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
