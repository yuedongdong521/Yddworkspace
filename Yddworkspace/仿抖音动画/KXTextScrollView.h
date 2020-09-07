//
//  KXTextScrollView.h
//  KXLive
//
//  Created by ydd on 2020/6/18.
//  Copyright © 2020 ibobei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KXTextScrollView : UIScrollView

/**  控制滚动跳的速度 默认为0.5 越大越快 建议不超过1.5    */
@property (nonatomic, assign) CGFloat rate;



/**
 请使用这个方法初始化
 
 @param frame frame
 @param inteval 两个label之间的距离
 @param fontSize label的字体大小
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame
                      inteval:(CGFloat)inteval
                     fontSize:(UIFont *)fontSize;

- (void)updataArray:(NSArray<NSString *> *)dataArray;

- (void)updateContent:(NSString *)content;

- (void)startTimer;
/**
 关闭定时器
 */
- (void)closeTimer;
/**  暂停或者重启定时器    */
- (void)changeTimerState;



@end

NS_ASSUME_NONNULL_END
