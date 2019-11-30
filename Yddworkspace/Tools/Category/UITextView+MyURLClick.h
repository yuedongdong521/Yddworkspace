//
//  UITextView+MyURLClick.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/29.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickURL)(NSURL *url);

@interface UITextView (MyURLClick)

@property(nonatomic, copy) ClickURL clickURL;

- (void)addURLClickAction:(ClickURL)clickURL;


- (NSRange)getCurSeletedRange;

- (void)setCurSelectedRange:(NSRange)range;


@end
