//
//  MyTestTextView.h
//  Yddworkspace
//
//  Created by ydd on 2018/8/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTestTextView : UITextView<UIGestureRecognizerDelegate>

- (void)setMyTextViewAttributedText:(NSAttributedString *)attributedText;

@end
