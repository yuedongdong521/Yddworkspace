//
//  HalfBaseViewController.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/17.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define HalfBaseViewControllerDismissKey @"HalfBaseViewControllerDismiss"

typedef enum : NSUInteger {
    PUSH_DIRECTION_RIGHT = 0,
    PUSH_DIRECTION_LEFT,
} PUSH_DIRECTION;


@interface HalfContentView : UIView

@end


@interface HalfBaseViewController : UIViewController

@property (nonatomic, strong) HalfContentView *contentView;
@property (nonatomic, copy) void(^dismissFinish)(void);
@property (nonatomic, copy) void(^didDisAppear)(void);

- (void)modalPushViewController:(UIViewController *)viewController Animation:(BOOL)animation direction:(PUSH_DIRECTION)direction;

- (void)modalPopAnimation:(BOOL)animation;

- (void)popViewWillAppear;
- (void)dismiss;
- (void)destory;

@end

NS_ASSUME_NONNULL_END
