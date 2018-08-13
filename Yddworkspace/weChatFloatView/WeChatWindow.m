//
//  WeChatWindow.m
//  Yddworkspace
//
//  Created by ydd on 2018/6/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "WeChatWindow.h"

#import "WeChatTestFloatViewController.h"

static WeChatWindow *_window;

const CGFloat collectViewWidth = 150.0;
const CGFloat roundEntryViewWidth = 100.0;
const CGFloat roundEntryViewMargin = 20.0;

@interface WeChatWindow ()

@property (nonatomic, assign) CGRect collectionViewOriginalFrame;

@property (nonatomic, assign) CGRect collectionViewDisplayFrame;



@end


@implementation WeChatWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)shareWeChatWindow
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _window = [[WeChatWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  });
  return _window;
}

- (CGRect)collectionViewOriginalFrame
{
  return CGRectMake(ScreenWidth, ScreenHeight, collectViewWidth, collectViewWidth);
}

- (CGRect)collectionViewDisplayFrame
{
  return CGRectMake(ScreenWidth - collectViewWidth, ScreenHeight - collectViewWidth, collectViewWidth, collectViewWidth);
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.windowLevel = UIWindowLevelStatusBar - 1;
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.collectView = [[FloatCollectView alloc] initWithFrame:self.collectionViewOriginalFrame];
    [self addSubview:_collectView];
    self.collectView.hidden = NO;
    
    
    self.roundEntryView = [[FloatRoundEntryView alloc] initWithFrame:CGRectMake(ScreenWidth - roundEntryViewMargin - roundEntryViewWidth, (ScreenHeight - roundEntryViewWidth) * 0.5, roundEntryViewWidth, roundEntryViewWidth)];
    _roundEntryView.layer.cornerRadius = roundEntryViewWidth * 0.5;
    _roundEntryView.backgroundColor = [UIColor blueColor];
    _roundEntryView.hidden = YES;
    __weak typeof(self) weakself = self;
    _roundEntryView.clickedCallback = ^{
      if (weakself) {
        [weakself pushVC];
      }
    };
    [self addSubview:_roundEntryView];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(processRoundEntryView:)];
    [_roundEntryView addGestureRecognizer:pan];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self makeKeyAndVisible];
  }
  return self;
}

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)gesture
{
  CGPoint point = [gesture locationInView:gesture.view];
  if (_statu == windowHidden) {
    switch (gesture.state) {
      case UIGestureRecognizerStateBegan:
        self.hidden = NO;
        break;
      case UIGestureRecognizerStateChanged:
      {
        CGFloat percent = point.x / ScreenWidth;
        // 20% 开始出现, 50% 完全展示
        percent -= 0.2;
        percent *= 10/3;
        percent = MIN(1, MAX(0, percent));
        CGRect frame = _collectView.frame;
        frame.origin.x = [self interpolate:self.collectionViewDisplayFrame.origin.x to:self.collectionViewOriginalFrame.origin.x percent:1 - percent];
        frame.origin.y = [self interpolate:self.collectionViewDisplayFrame.origin.y to:self.collectionViewOriginalFrame.origin.y percent:1 - percent];
        _collectView.frame = frame;
        BOOL isCollectViewInside = NO;
        CGPoint collectViewPoint = [self convertPoint:point toView:_collectView];
        if ([_collectView pointInside:collectViewPoint withEvent:nil]) {
          isCollectViewInside = YES;
        }
        [_collectView updateBgLayerPath:!isCollectViewInside];
      }
        break;
      case UIGestureRecognizerStateEnded:
      {
        CGPoint contentPoint = [_collectView convertPoint:point fromView:gesture.view];
        if ([_collectView.layer containsPoint:contentPoint]) {
          _roundEntryView.hidden = NO;
          _statu = roundEntryViewShowed;
          [self hideCollectView:nil];
        } else {
          [self hideCollectView:^{
            self.hidden = YES;
          }];
        }
      }
        break;
      case UIGestureRecognizerStateCancelled:
      {
        [self hideCollectView:^{
          self.hidden = YES;
        }];
      }
        break;
      default:
        break;
    }
    
    
  } else if (_statu == roundEntryViewShowed) {
    
  } else if (_statu == roundEntryViewHidden) {
    switch (gesture.state) {
      case UIGestureRecognizerStateBegan:
        break;
      case UIGestureRecognizerStateChanged:
        _roundEntryView.alpha = point.x / ScreenWidth;
        break;
      case UIGestureRecognizerStateEnded:
        _roundEntryView.alpha = 1;
        _statu = roundEntryViewShowed;
        break;
      case UIGestureRecognizerStateCancelled:
        _roundEntryView.alpha = 0;
        break;
      default:
        break;
    }
  }
}

- (void)pushVC
{
  WeChatTestFloatViewController *floatViewController = [[WeChatTestFloatViewController alloc] init];
  floatViewController.isNeedCustomTransition = YES;
  if (self.navController) {
    [self.navController pushViewController:floatViewController animated:YES];
  }
}

- (void)processRoundEntryView:(UIGestureRecognizer *)pan
{
  CGPoint point = [pan locationInView:self];
  switch (pan.state) {
    case UIGestureRecognizerStateBegan:
    {
      [self displayCollectView];
      [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.roundEntryView.center = point;
      } completion:nil];
    }
      break;
    case UIGestureRecognizerStateChanged:
    {
      self.roundEntryView.center = point;
      BOOL isCollectViewInside = NO;
      CGPoint collectViewPoint = [self convertPoint:point toView:self.collectView];
      if ([_collectView pointInside:collectViewPoint withEvent:nil]) {
        isCollectViewInside = YES;
      }
      [_collectView updateBgLayerPath:!isCollectViewInside];
    }
      break;
      case UIGestureRecognizerStateEnded:
      case UIGestureRecognizerStateCancelled:
    {
      CGPoint collectViewPoint = [self convertPoint:point toView:_collectView];
      if ([_collectView pointInside:collectViewPoint withEvent:nil]) {
        [self hideCollectView:nil];
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
          self.roundEntryView.alpha = 0.0;
        } completion:^(BOOL finished) {
          self.roundEntryView.hidden = YES;
          self.roundEntryView.alpha = 1;
          self.hidden = YES;
          self.statu = windowHidden;
        }];
      } else {
        CGRect frame = _roundEntryView.frame;
        if (point.x > ScreenWidth / 2) {
          frame.origin.x = ScreenWidth - roundEntryViewMargin - roundEntryViewWidth;
        } else {
          frame.origin.x = roundEntryViewMargin;
        }
        [self hideCollectView:nil];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
          self.roundEntryView.frame = frame;
        } completion:^(BOOL finished) {
          
        }];
      }
    }
      break;
    default:
      break;
  }
}

- (void)displayCollectView
{
  [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.collectView.frame = self.collectionViewDisplayFrame;
  } completion:nil];
}

- (void)hideCollectView:(void(^)())completion
{
  [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    self.collectView.frame = self.collectionViewOriginalFrame;
  } completion:^(BOOL finished) {
    if (completion) {
      completion();
    }
  }];
}

- (CGFloat)interpolate:(CGFloat)from to:(CGFloat)to percent:(CGFloat)percent
{
  return from + (to - from) * percent;
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
  CGPoint roundEntryViewPoint = [self convertPoint:point toView:_roundEntryView];
  if ([_roundEntryView pointInside:roundEntryViewPoint withEvent:event]) {
    return YES;
  }
  CGPoint collectViewPoint = [self convertPoint:point toView:_collectView];
  if ([_collectView pointInside:collectViewPoint withEvent:event]) {
    return YES;
  }
  return NO;
}

@end
