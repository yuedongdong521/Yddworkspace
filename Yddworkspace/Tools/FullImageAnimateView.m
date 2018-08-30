//
//  FullImageAnimateView.m
//  Yddworkspace
//
//  Created by ydd on 2018/7/26.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "FullImageAnimateView.h"

@interface FullImageAnimateView ()

@property(nonatomic, assign) CGRect originFrame;

@end

@implementation FullImageAnimateView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
  self = [super initWithFrame:frame];
  if (self) {
    [self addSubview:self.imageView];
    self.imageView.image = image;
  }
  return self;
}

- (UIImageView *)imageView
{
  if (!_imageView) {
    _imageView = [[UIImageView alloc] init];
    
  }
  return _imageView;
}

- (void)beganAnimateFrame:(CGRect)frame finish:(void(^)(BOOL finished))finish
{
  _originFrame = frame;
  CGRect fullFrame = [self getImageFullFrame:frame];
  self.imageView.frame = _originFrame;
  self.backgroundColor = [UIColor clearColor];
  __weak typeof(self) weakself = self;
  [UIView animateWithDuration:0.3 animations:^{
    weakself.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    weakself.imageView.frame = fullFrame;
  } completion:^(BOOL finished) {
    self.hidden = YES;
    if (finish) {
      finish(finished);
    }
  }];
}

- (void)endAnimationFinish:(void(^)(bool finished))finish
{
  __weak typeof(self) weakself = self;
  [UIView animateWithDuration:0.3 animations:^{
    weakself.backgroundColor = [UIColor clearColor];
    weakself.imageView.frame = weakself.originFrame;
  } completion:^(BOOL finished) {
    [weakself removeFromSuperview];
    if (finish) {
      finish(finished);
    }
  }];
}

- (CGRect)getImageFullFrame:(CGRect)frame
{
  CGFloat targetWidth = frame.size.width;
  CGFloat targetHeight = frame.size.height;
  
  CGFloat targetRota = targetWidth / targetHeight;
  CGFloat screenRota = ScreenWidth / ScreenHeight;
  
  CGRect fullFrame;
  if (targetRota > screenRota) {
    CGFloat fullH = targetHeight * ScreenWidth / targetWidth;
    fullFrame = CGRectMake(0, (ScreenHeight - fullH) * 0.5, ScreenWidth, fullH);
  } else {
    CGFloat fullW = targetHeight * ScreenWidth / targetWidth;
    fullFrame = CGRectMake((ScreenWidth - fullW), 0, fullW, ScreenHeight);
  }
  return fullFrame;
}

- (CGRect)getOriginFrameTargetView:(UIView *)targetView inView:(UIView *)inView
{
  UIView *subView = targetView;
  while (YES) {
    if (subView.superview) {
      UIView *superView = subView.superview;
      CGRect frame = [subView convertRect:subView.frame toView:superView];
      if ([superView isEqual:inView]) {
        frame = [subView convertRect:subView.frame toView:[UIApplication sharedApplication].keyWindow];
        return frame;
      } else {
        subView = superView;
      }
    } else {
      return subView.frame;
    }
  }
}

- (void)dealloc
{
  NSLog(@"dealloc : %@",NSStringFromClass(self.class));
}

@end
