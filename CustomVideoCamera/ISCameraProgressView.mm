//
//  ISCameraProgressView.m
//  CSRCameraProgressView
//
//  Created by student on 2017/7/14.
//  Copyright © 2017年 LeoAiolia. All rights reserved.
//

#import "ISCameraProgressView.h"
#import "ISCameraProgressViewLayer.h"

#define UIColorFromRGB(rgbValue)                                       \
  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                  green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                   blue:((float)(rgbValue & 0xFF)) / 255.0             \
                  alpha:1.0]

@interface ISCameraProgressView ()

@property(nonatomic, assign) NSTimeInterval totalTime;
@property(nonatomic, strong) dispatch_source_t timer;

@property(nonatomic, assign) NSTimeInterval currentTime;
@property(nonatomic, strong) CALayer* progressLayer;
@property(nonatomic, assign) BOOL ifFull;
@property(nonatomic, strong)
    NSMutableArray<ISCameraProgressViewLayer*>* historyLayers;

@end

@implementation ISCameraProgressView

- (instancetype)initWithFrame:(CGRect)frame
                  WithMaxTime:(CGFloat)maxTime
                  WithMinTime:(CGFloat)minTime {
  self = [super initWithFrame:frame];
  if (self == nil) {
    return nil;
  }

  CALayer* limitTimeLine = [[CALayer alloc] init];
  limitTimeLine.backgroundColor = [[UIColor whiteColor] CGColor];
  limitTimeLine.frame = CGRectMake(minTime / maxTime * ScreenWidth - 1, 0, 1,
                                   self.frame.size.height);
  [self.layer addSublayer:limitTimeLine];

  _totalTime = maxTime;
  _progressLayer = [[CAShapeLayer alloc] init];
  _progressLayer.backgroundColor = UIColorFromRGB(0xffdd00).CGColor;
  _progressLayer.frame = CGRectMake(0, 0, 0, self.frame.size.height);
  _progressLayer.hidden = YES;
  [self.layer addSublayer:_progressLayer];
  self.backgroundColor = [UIColor colorWithRed:45 / 255.f
                                         green:46 / 255.f
                                          blue:46 / 255.f
                                         alpha:1];

  _historyLayers = [NSMutableArray array];
  _historyTime = 0.0;
  return self;
}

- (void)start {
  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  if (self.historyLayers.count > 0) {
    self.historyLayers.lastObject.backgroundColor =
        UIColorFromRGB(0xffdd00).CGColor;
    _progressLayer.frame =
        CGRectMake(CGRectGetMaxX(self.historyLayers.lastObject.frame) + 1, 0, 0,
                   self.frame.size.height);
  } else {
    _progressLayer.frame = CGRectMake(0, 0, 0, self.frame.size.height);
  }
  _progressLayer.hidden = NO;
  [CATransaction commit];
  _currentTime = 0.0;

  [self creatTimer];
}

- (void)creatTimer {
  // 创建一个队列
  dispatch_queue_t queue = dispatch_get_main_queue();
  // dispatch_source_t 本质上是一个oc对象！！
  self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
  // GCD的时间参数
  dispatch_time_t start = DISPATCH_TIME_NOW;
  dispatch_time_t interval = TIMER_INTERVAL * NSEC_PER_SEC;
  dispatch_source_set_timer(self.timer, start, interval, 0);

  // 设置定时器的回调
  __weak typeof(&*self) weakSelf = self;
  dispatch_source_set_event_handler(self.timer, ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf timeLapse];
    });
  });
  // 启动定时器
  dispatch_resume(self.timer);
}

- (void)destoryTimer {
  if (_timer == nil) {
    return;
  }
  dispatch_source_cancel(_timer);
  _timer = nil;
}

- (void)stop {
  [self destoryTimer];

  _progressLayer.hidden = YES;

  _historyTime += _currentTime;
  ISCameraProgressViewLayer* layer = [[ISCameraProgressViewLayer alloc] init];
  layer.time = _currentTime;
  layer.frame =
      CGRectMake(_progressLayer.frame.origin.x, _progressLayer.frame.origin.y,
                 _ifFull ? _progressLayer.frame.size.width
                         : _progressLayer.frame.size.width - 1,
                 _progressLayer.frame.size.height);
  layer.backgroundColor = UIColorFromRGB(0xffdd00).CGColor;
  [self.layer addSublayer:layer];
  [_historyLayers addObject:layer];
}

- (void)deleteClick {
  self.historyLayers.lastObject.backgroundColor =
      UIColorFromRGB(0xf98a63).CGColor;
}

- (void)deleteCancle {
  self.historyLayers.lastObject.backgroundColor =
      UIColorFromRGB(0xffdd00).CGColor;
}

- (void)deleteSure {
  _historyTime -= self.historyLayers.lastObject.time;
  [self.historyLayers.lastObject removeFromSuperlayer];
  [self.historyLayers removeLastObject];
}

- (void)timeLapse {
  _currentTime += TIMER_INTERVAL;
  [self setNeedsDisplay];

  if (_currentTime + _historyTime >= _totalTime) {
    _ifFull = YES;
    [self.delegate cameraProgressViewDidFullTime];
  } else {  // 在录制完成之前 每一步定时器的调用
    if ([self.delegate respondsToSelector:@selector(updateProgress:)]) {
      [self.delegate updateProgress:_currentTime + _historyTime];
    }
  }
}

- (void)drawRect:(CGRect)rect {
  _progressLayer.frame =
      CGRectMake(_progressLayer.frame.origin.x, 0,
                 self.frame.size.width * (_currentTime / _totalTime),
                 self.frame.size.height);
}

// - (void)reset {
//    [self destoryTimer];
//    _progressLayer.hidden = YES;
//    [self.historyLayers enumerateObjectsUsingBlock:^(ISCameraProgressViewLayer
//    * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [obj removeFromSuperlayer];
//    }];
//    [self.historyLayers removeAllObjects];
//    _historyTime = 0.0;
//    _currentTime = 0.0;
// }

@end
