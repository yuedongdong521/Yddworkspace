//
//  CustomTransitionPushControlle.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/22.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomTransitionPushControlle : NSObject <UIViewControllerAnimatedTransitioning,CAAnimationDelegate>

@property (nonatomic, strong)id <UIViewControllerContextTransitioning> transitionContext;

@end
