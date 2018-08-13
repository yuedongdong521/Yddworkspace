//
//  YddOperation.m
//  Yddworkspace
//
//  Created by ispeak on 2018/3/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "YddOperation.h"

@implementation YddOperation

- (void)main
{
    [super main];
    if ([_delegate respondsToSelector:@selector(operationBlack)]) {
        [_delegate operationBlack];
    }
}

@end
