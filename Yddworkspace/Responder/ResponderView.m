//
//  ResponderView.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/10.
//  Copyright © 2019 QH. All rights reserved.
//

#import "ResponderView.h"

@implementation ResponderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


// 判断点击的点是否子范围内
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
  return [super pointInside:point withEvent:event];
}
// return 本次点击事件需要的最佳 view
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  return [super hitTest:point withEvent:event];
}


@end
