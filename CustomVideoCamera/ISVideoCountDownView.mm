//
//  ISVideoCountDownView.m
//  iShow
//
//  Created by student on 2017/7/18.
//
//

#import "ISVideoCountDownView.h"
#import "Masonry.h"
#import "UIColor+Hex.h"

typedef void (^Completion)(void);

@interface ISVideoCountDownView ()
@property(nonatomic, strong, readonly) UILabel* countLabel;  // 倒计时的label
@property(nonatomic, assign) NSInteger count;  // 计时
@property(nonatomic, strong) dispatch_source_t timer;
@property(nonatomic, copy) Completion completion;  // 倒计时完成回调的block

@end

@implementation ISVideoCountDownView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self creatUI];
  }
  return self;
}

- (void)creatUI {
  self.backgroundColor = [UIColor clearColor];
  UIView* backView = [[UIView alloc] init];
  backView.backgroundColor =
      [[UIColor colorWithHexString:@"ffdd00"] colorWithAlphaComponent:0.75];
  backView.layer.cornerRadius = self.frame.size.width / 2;
  backView.clipsToBounds = YES;
  [self addSubview:backView];
  [backView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
  }];

  _countLabel = [[UILabel alloc] init];
  _countLabel.textColor = [UIColor colorWithHexString:@"202020"];
  _countLabel.backgroundColor = [UIColor clearColor];
  _countLabel.font = [UIFont boldSystemFontOfSize:47.5];
  _countLabel.textAlignment = NSTextAlignmentCenter;
  [backView addSubview:_countLabel];
  [_countLabel mas_makeConstraints:^(MASConstraintMaker* make) {
    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
  }];
}

- (void)creatTimer {
  // 创建一个队列
  dispatch_queue_t queue =
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  // dispatch_source_t 本质上是一个oc对象！！
  self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
  // GCD的时间参数
  dispatch_time_t start = DISPATCH_TIME_NOW;
  dispatch_time_t interval = 1 * NSEC_PER_SEC;
  dispatch_source_set_timer(self.timer, start, interval, 0);

  // 设置定时器的回调
  __weak typeof(&*self) weakSelf = self;
  dispatch_source_set_event_handler(self.timer, ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      if (_count > 0) {
        weakSelf.countLabel.text =
            [NSString stringWithFormat:@"%ld", (long)_count];
        // [weakSelf animationTest];

        [weakSelf animationTwo];
        _count--;
      } else {  // 倒计时完成
        if (weakSelf.completion) {
          weakSelf.completion();
        }
        dispatch_source_cancel(_timer);
        _timer = nil;
        NSLog(@"倒计时的定时器已摧毁1");
      }
    });
  });

  // 启动定时器
  dispatch_resume(self.timer);
}

- (void)animationTest {
  CABasicAnimation* animation2 =
      [CABasicAnimation animationWithKeyPath:@"opacity"];
  animation2.duration = 0.30;
  animation2.toValue = @(0.2);
  animation2.removedOnCompletion = YES;
  animation2.fillMode = kCAFillModeForwards;
  [_countLabel.layer addAnimation:animation2 forKey:@"opacity"];

  CAKeyframeAnimation* animation;
  animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
  animation.duration = 0.30;
  animation.removedOnCompletion = YES;
  animation.fillMode = kCAFillModeForwards;
  NSMutableArray* values = [NSMutableArray array];
  [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(
                                                        0.2, 0.2, 1.0)]];
  [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(
                                                        1.5, 1.5, 1.0)]];
  [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(
                                                        1.4, 1.4, 1.0)]];
  animation.values = values;
  [_countLabel.layer addAnimation:animation forKey:nil];
}

- (void)animationTwo {
  self.alpha = 1;
  [UIView animateWithDuration:0.9
                        delay:0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     self.alpha = 0;
                   }
                   completion:^(BOOL finished){

                   }];
}

- (void)startCountDown:(void (^)(void))completion {
  _completion = completion;
  _count = 3;
  [self creatTimer];
}

- (void)cancleTimer {
  if (_timer) {
    dispatch_source_cancel(_timer);
    _timer = nil;
  }
}

- (void)dealloc {
  if (_timer) {
    dispatch_source_cancel(_timer);
    _timer = nil;
  }
}

@end
