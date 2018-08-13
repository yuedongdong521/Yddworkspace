//
//  WeChatWindow.h
//  Yddworkspace
//
//  Created by ydd on 2018/6/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FloatCollectView.h"
#import "FloatRoundEntryView.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
  windowHidden,
  roundEntryViewShowed,
  roundEntryViewHidden,
} FloatWindowStatus;

@interface WeChatWindow : UIWindow

@property (nonatomic, assign) FloatWindowStatus statu;
@property (nonatomic, weak) UINavigationController *navController;
@property (nonatomic, strong) FloatCollectView *collectView;
@property (nonatomic, strong) FloatRoundEntryView *roundEntryView;

+ (instancetype)shareWeChatWindow;
- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
