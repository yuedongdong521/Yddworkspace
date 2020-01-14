//
//  UILabel+YDDExtend.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/30.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (YDDExtend)

@property (nonatomic, strong) CAGradientLayer *fontGradLayer;

- (void)setFontGradColors:(NSArray <UIColor *>*)colors;

+ (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)color textAlignment:(NSTextAlignment)alignment;

@end

NS_ASSUME_NONNULL_END
