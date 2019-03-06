//
//  ISAVWindowManager.m
//  iSpeak
//
//  Created by ydd on 2018/4/21.
//

#import "ISAVWindowManager.h"

static ISAVWindowManager* _manager = nil;
@implementation ISAVWindowManager

+ (ISAVWindowManager*)shareManager {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _manager = [[self alloc] init];
  });
  return _manager;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _avWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // window 等级：statusbar 1000，alert 2000，
    _avWindow.windowLevel = 1000000;
    _avWindow.hidden = YES;
  }
  return self;
}

- (void)setRootViewController:(UIViewController*)vc {
  //  UIWindow* currentKeyWindow = [UIApplication sharedApplication].keyWindow;
  _avWindow.hidden = NO;
  _avWindow.rootViewController = vc;
  [_avWindow makeKeyAndVisible];
  //  [currentKeyWindow makeKeyWindow];
  CATransition* animation = [CATransition animation];
  animation.duration = 0.3;
  animation.type = kCATransitionMoveIn;
  animation.subtype = kCATransitionFromTop;
  animation.timingFunction = [CAMediaTimingFunction
      functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [_avWindow.layer addAnimation:animation forKey:@"animation"];
  [_avWindow makeKeyWindow];
}

- (void)destroyAvWindowCompletion:(void (^)())completion {
  if (_avWindow.rootViewController.presentedViewController) {
    [_avWindow.rootViewController.presentedViewController
        dismissViewControllerAnimated:NO
                           completion:nil];
  }
  __weak typeof(self) weakself = self;
  [UIView animateWithDuration:0.3
      delay:0
      options:UIViewAnimationOptionCurveEaseInOut
      animations:^{
        weakself.avWindow.frame =
            CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
      }
      completion:^(BOOL finished) {
        weakself.avWindow.hidden = YES;
        weakself.avWindow.rootViewController = nil;
        [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
        weakself.avWindow.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        if (completion) {
          completion();
        }
      }];
}

@end
