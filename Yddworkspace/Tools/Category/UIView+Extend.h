//
//  UIView+Extend.h
//  Yddworkspace
//
//  Created by ydd on 2019/6/26.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extend)

/** 改变view的响应范围, 负值变大, 正值变小 */
- (void)setResponsEdge:(UIEdgeInsets)edge;

/** 依据形变后的frame做transform形变 */
- (void)transformToSacleFrame:(CGRect)sacleFrame
                     duration:(CGFloat)duration
                      options:(UIViewAnimationOptions)options
                    animation:(BOOL)animation
                   completion:(void(^)(BOOL finished))completion;

- (CGAffineTransform)transformFrame:(CGRect)frame;

- (UIViewController *)superViewController;

- (void)addMaskLayerImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
