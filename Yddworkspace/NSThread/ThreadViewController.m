//
//  ThreadViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2018/3/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "ThreadViewController.h"
#import "YddOperation.h"

@interface ThreadViewController () <YddOperationDelegate>
{
    dispatch_queue_t _ticketQueue;
    void* _ticketQueueTag;
}

@property(nonatomic, assign) NSInteger ticketCount;

@property(nonatomic, strong) NSThread* thread1;
@property(nonatomic, strong) NSThread* thread2;
@property(nonatomic, strong) NSThread* thread3;

@property(nonatomic, strong) NSLock* threadLock;

@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _threadLock = [[NSLock alloc] init];
    
    [self createDispatchQueueTag];
    
    NSArray* btnArr = @[ @"NSThread", @"Operation", @"GCD", @"GCDGroup", @"死锁1", @"死锁2", @"死锁三", @"死锁4", @"解决死锁"];
    CGFloat btnW = 60;
    CGFloat btnH = 40;
    int btnLine = 3;
    CGFloat rankH = 30;
    CGFloat btnX = (ScreenWidth - btnW * btnLine) / (btnLine + 1);
    for (int i = 0; i < btnArr.count; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:btnArr[i] forState:UIControlStateNormal];
        CGFloat btnY =
        rankH + (btnH + rankH) * (i / btnLine) + 64;
        button.frame =
        CGRectMake(btnX + (i % btnLine) * (btnW + btnX), btnY, btnW, btnH);
        button.tag = i;
        [button addTarget:self
                   action:@selector(buttonAction:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)buttonAction:(UIButton*)btn {
    _ticketCount = 100;
    switch (btn.tag) {
        case 0:
            [self startThread];
            break;
        case 1:
            [self createOperation];
            break;
        case 2:
            [self createGCDThread];
            break;
        case 3:
            [self testGCDGroup];
            break;
        case 4:
            [self testGCD1];
            break;
        case 5:
            [self testGCD2];
            break;
        case 6:
            [self testGCD3];
            break;
        case 7:
            [self testLock];
            break;
            
        case 8:
            [self testQueueTag];
            break;
            
        default:
            break;
    }
}

- (void)testGCD1
{
    NSLog(@"testGCD1_1:%@", [NSThread currentThread]);
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"testGCD1_2:%@", [NSThread currentThread]);
    });
}
- (void)testGCD2
{
    dispatch_queue_t queue = dispatch_queue_create("testGCD2", NULL);
    dispatch_async(queue, ^{
        NSLog(@"testGCD2_1:%@", [NSThread currentThread]);
        dispatch_sync(queue, ^{
            NSLog(@"testGCD2_2:%@", [NSThread currentThread]);
        });
    });
    
    
}
- (void)testGCD3
{
    dispatch_queue_t queue1 = dispatch_queue_create("testGCD3", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue1, ^{
        NSLog(@"testGCD3_1:%@", [NSThread currentThread]);
        dispatch_queue_t queue2 = dispatch_queue_create("testGCD3.3", DISPATCH_QUEUE_SERIAL);
        dispatch_sync(queue2, ^{
            NSLog(@"testGCD3_2:%@", [NSThread currentThread]);
        });
    });
}

- (void)startThread {
    [self createThread];
}

- (void)stopThread {
    if (_thread1 != nil) {
        if (![_thread1 isCancelled]) {
            [_thread1 cancel];
        }
        _thread1 = nil;
    }
    
    if (_thread2 != nil) {
        if (![_thread2 isCancelled]) {
            [_thread2 cancel];
        }
        _thread2 = nil;
    }
    
    if (_thread3 != nil) {
        if (![_thread3 isCancelled]) {
            [_thread3 cancel];
        }
        _thread3 = nil;
    }
}

- (void)createThread {
    [self stopThread];
    NSThread* thread1 =
    [[NSThread alloc] initWithTarget:self
                            selector:@selector(startSellTicket)
                              object:nil];
    [thread1 setName:@"窗口1"];
    _thread1 = thread1;
    [_thread1 start];
    
    NSThread* thread2 =
    [[NSThread alloc] initWithTarget:self
                            selector:@selector(startSellTicket)
                              object:nil];
    [thread2 setName:@"窗口2"];
    _thread2 = thread2;
    [_thread2 start];
    
    NSThread* thread3 =
    [[NSThread alloc] initWithTarget:self
                            selector:@selector(startSellTicket)
                              object:nil];
    [thread3 setName:@"窗口3"];
    _thread3 = thread3;
    [_thread3 start];
    
    //    NSOperationQueue
}

- (void)createOperation {
    __weak typeof(self) weakself = self;
    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:3];
    
    YddOperation* yddOperation = [[YddOperation alloc] init];
    yddOperation.delegate = self;
    [yddOperation setName:@"窗口1"];
    [operationQueue addOperation:yddOperation];
    
    NSBlockOperation* blcokOperation =
    [NSBlockOperation blockOperationWithBlock:^{
        [weakself startSellTicket];
    }];
    blcokOperation.name = @"窗口2";
    [operationQueue addOperation:blcokOperation];
    
    NSInvocationOperation* invocationOperation =
    [[NSInvocationOperation alloc] initWithTarget:self
                                         selector:@selector(startSellTicket)
                                           object:nil];
    invocationOperation.name = @"窗口3";
    [operationQueue addOperation:invocationOperation];
}

- (void)createGCDThread {
    // DISPATCH_QUEUE_CONCURRENT 并发线程
    // DISPATCH_QUEUE_SERIAL 穿行线程
    dispatch_queue_t yddQueue =
    dispatch_queue_create("YddQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(yddQueue, ^{
        [self startSellTicket];
    });
    dispatch_async(yddQueue, ^{
        [self startSellTicket];
    });
    dispatch_async(yddQueue, ^{
        [self startSellTicket];
    });
    
    
}

- (void)testGCDGroup
{
    dispatch_group_t yddGroup = dispatch_group_create();
    
    dispatch_group_async(yddGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self startSellTicket];
    });
    
    dispatch_group_async(yddGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self startSellTicket];
    });
    dispatch_group_notify(yddGroup, dispatch_get_main_queue(), ^{
        NSLog(@"结束");
    });
}

- (void)testLock
{
    dispatch_queue_t queue = dispatch_queue_create("testLockQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_ticketQueue, ^{
        NSLog(@"%s : 1", __func__);
        dispatch_async(queue, ^{
            NSLog(@"%s : 2", __func__);
        });
    });
}


- (void)createDispatchQueueTag
{
    _ticketQueue = dispatch_queue_create("ticket_queue", DISPATCH_QUEUE_SERIAL);
    _ticketQueueTag = &_ticketQueueTag;
    dispatch_queue_set_specific(_ticketQueue, _ticketQueueTag, _ticketQueueTag, NULL);
}

- (void)dispatchAsyncBlock:(void(^)(void))block
{
    if (dispatch_get_specific(_ticketQueueTag)) {
        block();
    } else {
        dispatch_async(_ticketQueue, block);
    }
}

- (void)testQueueTag
{
    static int count = 0;
    
    [self dispatchAsyncBlock:^{
        count++;
        NSLog(@"%s : count = %d", __func__, count);
        if (count > 10) {
            count = 0;
        } else {
            [self testQueueTag];
            
        }
    }];
}


#pragma mark YddOperationDelegate
- (void)operationBlack {
    [self startSellTicket];
}

- (void)startSellTicket {
    while (_ticketCount) {
        [_threadLock lock];
        [self sellTicket];
        [_threadLock unlock];
    }
}

- (void)sellTicket {
    if (_ticketCount > 0) {
        _ticketCount--;
        NSLog(@"%@余票：%ld张 \n", [NSThread currentThread], (long)_ticketCount);
    } else {
        NSLog(@"%@没有足够的票（%ld）\n", [NSThread currentThread],
              (long)_ticketCount);
    }
}

- (void)dealloc {
    NSLog(@"Thread 释放");
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
