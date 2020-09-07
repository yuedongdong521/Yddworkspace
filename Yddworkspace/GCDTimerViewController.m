//
//  GCDTimerViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/8/22.
//  Copyright © 2020 QH. All rights reserved.
//

#import "GCDTimerViewController.h"

@interface GCDTimerViewController ()

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation GCDTimerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startTimer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"结束" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(stopTimer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(200);
        make.width.height.mas_equalTo(50);
    }];
    
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(300);
        make.width.height.mas_equalTo(50);
    }];
    
}


- (void)startTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    
    __block NSInteger count = 0;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 5 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        count++;
        NSLog(@"倒计时 : %ld", (long)count);
    });
    dispatch_resume(_timer);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger i = 0;
        while (1) {
            i++;
        }
    });
    
}


- (void)stopTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
//        _timer = nil;
    }
    NSLog(@"结束倒计时");
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
