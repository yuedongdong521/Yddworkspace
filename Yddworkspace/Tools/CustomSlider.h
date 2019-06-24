//
//  CustomSlider.h
//  Yddworkspace
//
//  Created by ydd on 2019/6/20.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomSlider : UIView

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIColor *bgColor;

- (instancetype)initWithHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
