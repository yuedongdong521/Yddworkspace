//
//  ISVideoCountDownView.h
//  iShow
//
//  Created by student on 2017/7/18.
//
//

#import <UIKit/UIKit.h>

@interface ISVideoCountDownView : UIView

- (instancetype)initWithFrame:(CGRect)frame;
// 使用时 注意防止循环引用
- (void)startCountDown:(void (^)(void))completion;
- (void)cancleTimer;

@end
