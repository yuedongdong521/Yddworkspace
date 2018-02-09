//
//  MyURLClickView.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/29.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickURL)(NSURL *url);

@interface MyURLClickView : UITextView

@property(nonatomic, copy) ClickURL clickURL;

- (instancetype)initWithFrame:(CGRect)frame WithClickURL:(ClickURL)clickURL;


@end
