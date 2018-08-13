//
//  FullImageAnimateView.h
//  Yddworkspace
//
//  Created by ydd on 2018/7/26.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullImageAnimateView : UIView

@property(nonatomic, strong) UIImageView *imageView;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)beganAnimateTargetView:(UIView *)targetView inView:(UIView *)inView finish:(void(^)(BOOL finished))finish;
- (void)endAnimationFinish:(void(^)(bool finished))finish;

@end
