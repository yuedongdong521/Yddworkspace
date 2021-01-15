//
//  KXGCDTimer.h
//  KXLive
//
//  Created by ydd on 2020/11/18.
//  Copyright © 2020 ibobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KXTimerDirection) {
    /// 递增
    KXTimerDirection_Increase = 0,
    /// 递减
    KXTimerDirection_Decrease
};


@interface KXGCDTimer : NSObject

/// 倒计时时间间隔, 默认1s
@property (nonatomic, assign) NSInteger duration;

/// 倒计时总时长
@property (nonatomic, assign) NSInteger totalTime;

/// 倒计时返回线程， 默认 mainQueue
@property (nonatomic, strong) dispatch_queue_t timeQueue;
/// 倒计时方向, 默认 KXTimerDirection_Increase 递增
@property (nonatomic, assign) KXTimerDirection direction;

/// 是否立刻执行倒计时方法, 默认YES
@property (nonatomic, assign) BOOL isFire;

@property (nonatomic, copy) void(^timeAction)(NSInteger currCount, BOOL isFinish);

- (void)startTimer;


/// <#Description#>
/// @param curTime 从curTime开始计时
- (void)startWithTime:(NSInteger)curTime;


/// <#Description#>
/// @param total 计时时长
/// @param startTime 从curTime开始计时
/// @param direction 计时方向
- (void)startWithTotal:(NSInteger)total
             startTime:(NSInteger)startTime
             direction:(KXTimerDirection)direction;

- (void)stopTimer;

@end

NS_ASSUME_NONNULL_END
