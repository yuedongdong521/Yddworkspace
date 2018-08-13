//
//  FloatRoundEntryView.m
//  Yddworkspace
//
//  Created by ydd on 2018/6/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "FloatRoundEntryView.h"

@implementation FloatRoundEntryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _clickedCallback = nil;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
    [self addGestureRecognizer:tap];
  }
  return self;
}

- (void)gesture:(UITapGestureRecognizer *)tap
{
  if (_clickedCallback) {
    _clickedCallback();
  }
}

@end
