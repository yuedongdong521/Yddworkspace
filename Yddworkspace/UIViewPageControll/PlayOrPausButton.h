//
//  PlayOrPausButton.h
//  Yddworkspace
//
//  Created by ydd on 2019/1/15.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayOrPausButton : UIButton

@property (nonatomic, assign) CGFloat imgSize;
+ (instancetype)buttonWithType:(UIButtonType)buttonType frame:(CGRect)frame imgSize:(CGFloat)imgSize;
- (void)setPlay:(BOOL)isPlay animated:(BOOL)animated;
- (instancetype)initWithFrame:(CGRect)frame imgSize:(CGFloat)imgSize;

@end

NS_ASSUME_NONNULL_END
