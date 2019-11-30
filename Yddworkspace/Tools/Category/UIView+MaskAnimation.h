//
//  UIView+MaskAnimation.h
//  Yddworkspace
//
//  Created by ydd on 2019/11/13.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MaskAnimation)<CAAnimationDelegate>



- (void)maskAnimationDuration:(CGFloat)duration
               animationWidth:(CGFloat)animationWidth
                  repeatCount:(NSInteger)repeatCount;

- (void)maskAnimationStop;

@end

NS_ASSUME_NONNULL_END
