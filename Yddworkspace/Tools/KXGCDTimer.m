//
//  KXGCDTimer.m
//  KXLive
//
//  Created by ydd on 2020/11/18.
//  Copyright © 2020 ibobei. All rights reserved.
//

#import "KXGCDTimer.h"
#import "YYCategoriesMacro.h"

@interface KXGCDTimer ()
{
    dispatch_source_t _timer;
}

/// 倒计时起始时间
@property (nonatomic, strong) NSDate *startTime;


@end

@implementation KXGCDTimer

- (void)dealloc
{
    NSLog(@"KXGCDTimer dealloc");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.duration = 1;
        self.isFire = YES;
        self.direction = KXTimerDirection_Increase;
        self.timeQueue = dispatch_get_main_queue();
    }
    return self;
}

- (void)startWithTime:(NSInteger)startTime
{
    [self startWithTotal:self.totalTime
               startTime:startTime
               direction:self.direction];
}

- (void)startWithTotal:(NSInteger)total
             startTime:(NSInteger)startTime
             direction:(KXTimerDirection)direction
{
    [self stopTimer];
    self.totalTime = total;
    self.startTime = [NSDate dateWithTimeIntervalSinceNow:-startTime];
    self.direction = direction;
    [self startTimer];
}

- (void)startTimer
{
    [self stopTimer];
    if (!_startTime) {
        _startTime = [NSDate date];
    }
    @weakify(self);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timeQueue);
  
    int64_t walltime = 0;
    if (!_isFire) {
        walltime = self.duration * NSEC_PER_SEC;
    }
    
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, walltime), self.duration * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        @strongify(self);
        NSInteger curCount = [[NSDate date] timeIntervalSinceDate:self.startTime];
        BOOL isFinish = curCount >= self.totalTime;
        
        NSInteger backCount = self.direction == KXTimerDirection_Increase ? curCount : self.totalTime - curCount;
        
        if (isFinish) {
            [self stopTimer];
        }
        
        if (self.timeAction) {
            self.timeAction(backCount, isFinish);
        }
        
    });
    dispatch_resume(_timer);
}

- (void)stopTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}



@end
