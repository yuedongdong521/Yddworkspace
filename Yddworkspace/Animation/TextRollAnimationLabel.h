//
//  TextRollAnimationLabel.h
//  Yddworkspace
//
//  Created by ydd on 2020/3/23.
//  Copyright © 2020 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextRollAnimationLabel : UIView

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) CGFloat dealyTime;
@property (nonatomic, assign) CGFloat speed;

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, assign) NSInteger repeatCount;

@property (nonatomic, strong) CAMediaTimingFunction *function;

@property (nonatomic, assign, readonly) BOOL isAnimation;

- (void)startAnimationFinished:(void(^)(BOOL flag))finished;

@end

NS_ASSUME_NONNULL_END
