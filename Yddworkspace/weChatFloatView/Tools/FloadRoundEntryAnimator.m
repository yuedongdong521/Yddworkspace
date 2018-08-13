//
//  FloadRoundEntryAnimator.m
//  Yddworkspace
//
//  Created by ydd on 2018/6/19.
//  Copyright © 2018年 QH. All rights reserved.
//


#import "FloadRoundEntryAnimator.h"
#import "WeChatWindow.h"

@interface FloadRoundEntryAnimator ()<CAAnimationDelegate>

@property (nonatomic, assign) UINavigationControllerOperation operation;

@property (nonatomic, assign) CGPoint sourceCenter;

@end

@implementation FloadRoundEntryAnimator

- (instancetype)initWidthOperation:(UINavigationControllerOperation)operation sourceCenter:(CGPoint)sourceCenter
{
  self =  [super init];
  if (self) {
    _sourceCenter = sourceCenter;
    _operation = operation;
  }
  return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
  return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
  CAShapeLayer *mask = [[CAShapeLayer alloc] init];
  CGFloat size = 100;
  CGRect sourceRect = CGRectMake(_sourceCenter.x - size / 2, _sourceCenter.y - size / 2, size, size);
  UIBezierPath *sourcePath = [UIBezierPath bezierPathWithRoundedRect:sourceRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
  UIBezierPath *screenPath = [UIBezierPath bezierPathWithRoundedRect:[UIScreen mainScreen].bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(100, 100)];
  
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
  animation.duration = [self transitionDuration:transitionContext];
  animation.delegate = self;
  [animation setRemovedOnCompletion:YES];;
  [animation setValue:transitionContext forKey:@"transitionContext"];
  [animation setValue:mask forKey:@"mask"];
  
  if (_operation == UINavigationControllerOperationPush) {
    [WeChatWindow shareWeChatWindow].roundEntryView.alpha = 0;
    [WeChatWindow shareWeChatWindow].statu = roundEntryViewHidden;
    
    mask.path = screenPath.CGPath;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    if (toView) {
      toView.layer.mask = mask;
      [transitionContext.containerView addSubview:toView];
    }
    
    animation.fromValue = (id)sourcePath.CGPath;
    animation.toValue = (id)screenPath.CGPath;
  } else {
    [WeChatWindow shareWeChatWindow].roundEntryView.alpha = 1;
    [WeChatWindow shareWeChatWindow].statu = roundEntryViewShowed;
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    if (toView) {
      [transitionContext.containerView insertSubview:toView atIndex:0];
    }
    
    mask.path = sourcePath.CGPath;
    if (fromView) {
      fromView.layer.mask = mask;
      animation.fromValue = (id)screenPath.CGPath;
      animation.toValue = (id)sourcePath.CGPath;
    }
  }
  [mask addAnimation:animation forKey:@"pathAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  CAShapeLayer *mask = [anim valueForKey:@"mask"];
  [mask removeFromSuperlayer];
  id <UIViewControllerContextTransitioning> transition = [anim valueForKey:@"transitionContext"];
  [transition completeTransition:flag];
  
}

@end
