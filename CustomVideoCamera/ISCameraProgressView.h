//
//  ISCameraProgressView.h
//  CSRCameraProgressView
//
//  Created by student on 2017/7/14.
//  Copyright © 2017年 LeoAiolia. All rights reserved.
//

#import <UIKit/UIKit.h>

// #define ISCameraMaxTime    10.f
// #define ISLimitTime        3.f
#define TIMER_INTERVAL 0.05f

@protocol ISCameraProgressViewDelegate <NSObject>

@required

/**
 视频录制进度条走完了
 */
- (void)cameraProgressViewDidFullTime;

@optional

/**
 视频录制过程中更新progress
 */
- (void)updateProgress:(NSTimeInterval)time;

@end

@interface ISCameraProgressView : UIView

@property(nonatomic, weak) id<ISCameraProgressViewDelegate> delegate;
@property(nonatomic, assign) NSTimeInterval historyTime;

- (instancetype)initWithFrame:(CGRect)frame
                  WithMaxTime:(CGFloat)maxTime
                  WithMinTime:(CGFloat)minTime;

/**
 开始录制
 */
- (void)start;

/**
 暂停录制
 */
- (void)stop;

/**
 点击了删除，修改最后一条layer的颜色
 */
- (void)deleteClick;

/**
 取消删除
 */
- (void)deleteCancle;
/**
 确定删除
 */
- (void)deleteSure;

/**
 重新录制
 */
// - (void)reset;

@end
