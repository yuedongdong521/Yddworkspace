//
//  FloadRoundEntryAnimator.h
//  Yddworkspace
//
//  Created by ydd on 2018/6/19.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FloadRoundEntryAnimator : NSObject  <UIViewControllerAnimatedTransitioning>

- (instancetype)initWidthOperation:(UINavigationControllerOperation)operation sourceCenter:(CGPoint)sourceCenter;

@end

NS_ASSUME_NONNULL_END
