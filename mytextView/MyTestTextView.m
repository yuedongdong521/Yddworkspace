//
//  MyTextView.m
//  Yddworkspace
//
//  Created by ydd on 2018/8/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyTextView.h"

@implementation MyTextView

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
    self.font = [UIFont systemFontOfSize:16];
    self.backgroundColor = [UIColor whiteColor];
    
    self.returnKeyType = UIReturnKeyDone;
    self.scrollEnabled = NO;
    self.dataDetectorTypes =
    UIDataDetectorTypeNone;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.contentInset = UIEdgeInsetsZero;
    self.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.contentOffset = CGPointZero;
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
    
    self.editable = NO;
    [self removeTextViewNotificationObservers];
  }
  return self;
}

- (void)removeTextViewNotificationObservers {
  [[NSNotificationCenter defaultCenter]
   removeObserver:self
   name:UITextViewTextDidChangeNotification
   object:self];
  
  [[NSNotificationCenter defaultCenter]
   removeObserver:self
   name:UITextViewTextDidBeginEditingNotification
   object:self];
  
  [[NSNotificationCenter defaultCenter]
   removeObserver:self
   name:UITextViewTextDidEndEditingNotification
   object:self];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  if([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [NSStringFromClass([otherGestureRecognizer class])isEqualToString:@"UITextTapRecognizer"]){
    
    return NO;
    
  }
  return YES;
}


@end
