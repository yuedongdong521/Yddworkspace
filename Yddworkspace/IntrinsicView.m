//
//  IntrinsicView.m
//  Yddworkspace
//
//  Created by ispeak on 2017/3/13.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "IntrinsicView.h"

static bool closeIntrinsic = false;//测试关闭Intrinsic的影响

@implementation IntrinsicView

- (instancetype)init
{
    self = [super init];
    if (self) {
        //不兼容旧版Autoreizingmask，只使用AutoLayout
        //如果为YES，在AutoLayout中则会自动将view的frame和bounds属性转换为约束。
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

//当用户设置extendSize时，提示系统IntrinsicContentSize变化了。
-(void)setExtendSize:(CGSize)extendSize{
    _extendSize = extendSize;
    //如果不加这句话，在view显示之后（比如延时几秒），再设置extendSize不会有效果。
    //本例中也就是testInvalidateIntrinsic的方法不会产生预期效果。
    [self invalidateIntrinsicContentSize];
}

//通过覆盖intrinsicContentSize函数修改View的Intrinsic的大小
-(CGSize)intrinsicContentSize{
    if (closeIntrinsic) {
        return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
    } else {
        return CGSizeMake(_extendSize.width, _extendSize.height);
    }
}

@end
