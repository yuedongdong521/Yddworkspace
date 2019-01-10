//
//  MyResponderBtn.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/10.
//  Copyright © 2019 QH. All rights reserved.
//

#import "MyResponderBtn.h"

@implementation MyResponderBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)createBtn:(NSString *)title color:(UIColor*)color tag:(NSInteger)tag frame:(CGRect)frame target:(id)target action:(SEL)action
{
  MyResponderBtn *btn1 = [MyResponderBtn buttonWithType:UIButtonTypeSystem];
  btn1.frame = frame;
  btn1.tag = tag;
  [btn1 setTitle:title forState:UIControlStateNormal];
  btn1.backgroundColor = color;
  [btn1 addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  return btn1;
}
// 扩大 button 的响应范围
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
  CGRect bounds = CGRectInset(self.bounds, -20, -20);
  return CGRectContainsPoint(bounds, point);
}

@end
