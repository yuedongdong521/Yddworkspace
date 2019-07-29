//
//  CustomTransition.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/24.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AnimationStatus_push = 0,
    AnimationStatus_pop,
} AnimationStatus;


@interface CustomTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) AnimationStatus animationStatus;

@end

NS_ASSUME_NONNULL_END
