//
//  ProgressView.h
//  yddZS
//
//  Created by ydd on 2018/10/25.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressView : UIView

@property(nonatomic, strong) UIColor *fillColor;
@property(nonatomic, assign) CGFloat progressValue;

@end

NS_ASSUME_NONNULL_END
