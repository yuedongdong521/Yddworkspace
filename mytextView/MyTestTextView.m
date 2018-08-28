//
//  MyTestTextView.m
//  Yddworkspace
//
//  Created by ydd on 2018/8/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyTestTextView.h"

@interface MyTestTextView()
{
 
}

@property(nonatomic, assign) NSRange selectRange;
@property(nonatomic, assign) NSTextCheckingType selectType;

@end



@implementation MyTestTextView

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
    self.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
    self.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor],
                                NSFontAttributeName:self.font
                                };
    
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.contentInset = UIEdgeInsetsZero;
    self.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.contentOffset = CGPointZero;
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
    
    self.editable = NO;
    
    for (int i = 0; i < self.gestureRecognizers.count; i++) {
      UIGestureRecognizer *ges = self.gestureRecognizers[i];
      ges.enabled = NO;
    }
//
//    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGes:)];
//    longGes.minimumPressDuration = 0.5;
//    longGes.delegate = self;
//    [self addGestureRecognizer:longGes];
//
    
//    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
//    tapGes.delegate = self;
//    [self addGestureRecognizer:tapGes];
//
//    [tapGes requireGestureRecognizerToFail:longGes];
    
    [self removeTextViewNotificationObservers];
    
    // 自定义text view选中文字后的菜单
    UIMenuItem *selectItem = [[UIMenuItem alloc] initWithTitle:@"选择文字" action:@selector(callSelectText:)];
    UIMenuItem *cancelItem = [[UIMenuItem alloc] initWithTitle:@"取消选中" action:@selector(cancelSelection:)];
    [UIMenuController sharedMenuController].menuItems = @[selectItem, cancelItem];
  }
  return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  CGPoint location = [touches.anyObject locationInView:self];
  NSString* urlStr = [self lineAtPosition:location];
  if (urlStr.length > 0) {
    NSLog(@"urlStr = %@", urlStr);
  }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [self cancelSelectUrl];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [self cancelSelectUrl];
}

- (void)longGes:(UILongPressGestureRecognizer *)ges
{
  return;
  switch (ges.state) {
    case UIGestureRecognizerStateBegan: {
      CGPoint location = [ges locationInView:self];
      NSString* urlStr = [self lineAtPosition:location];
      if (_selectType == NSTextCheckingTypePhoneNumber) {
        if (urlStr.length > 0) {
          NSLog(@"urlStr = %@", urlStr);
        }
      } else if (_selectType == NSTextCheckingTypeLink) {
        
      }
      
    }
      break;
    case UIGestureRecognizerStateChanged:
      
      break;
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateFailed:
    case UIGestureRecognizerStateCancelled:
      [self cancelSelectUrl];
      break;
    default:
      break;
  }
}

- (void)selectAll:(id)sender
{
}

- (void)tapGes:(UITapGestureRecognizer*)ges
{
  
//  if (ges.state == UIGestureRecognizerStateBegan) {
//    CGPoint location = [ges locationInView:self];
//    NSString* urlStr = [self lineAtPosition:location];
//    if (urlStr.length > 0) {
//      NSLog(@"urlStr = %@", urlStr);
//    }
//  } else {
//    [self cancelSelectUrl];
//  }
  
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



/* 选中文字后是否能够呼出菜单 */
- (BOOL)canBecameFirstResponder {
  return YES;
}

/* 选中文字后的菜单响应的选项 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if (action == @selector(callSelectText:)) { // 菜单不能响应copy项
    return YES;
  }
  else if (action == @selector(cancelSelection:)) { // 菜单不能响应select all项
    return YES;
  }
  
  // 事实上一个return NO就可以将系统的所有菜单项全部关闭了
  return NO;
}

#pragma mark - Menu Item Actions

- (void)callSelectText:(id)sender {
}

- (void)cancelSelection:(id)sender {
}


- (void)contentTextViewTapGes:(UITapGestureRecognizer*)tap {
  CGPoint location = [tap locationInView:self];
  NSString* urlStr = [self lineAtPosition:location];
  if (urlStr.length > 0) {

  }
}


- (NSString*)lineAtPosition:(CGPoint)position {
  position.y += self.contentOffset.y;
  UITextPosition* tapPosition = [self closestPositionToPoint:position];
  
  NSString* context = [self getMyTextViewText];
  if (context.length < 1) {
    return @"";
  }
  NSInteger startOffset =
  [self offsetFromPosition:self.beginningOfDocument
                            toPosition:tapPosition];
  if (startOffset > context.length - 1) {
    return @"";
  }
  NSLog(@"startStr = %@",
        [context substringWithRange:NSMakeRange(startOffset, 1)]);
  NSError* error = nil;
  NSDataDetector* detector =
  [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber
                                  error:&error];
  if (error != nil) {
    return @"";
  }
  NSArray* results = [detector matchesInString:context
                                       options:NSMatchingReportProgress
                                         range:NSMakeRange(0, context.length)];
  
  for (NSTextCheckingResult* result in results) {
    if (result.resultType == NSTextCheckingTypeLink || result.resultType == NSTextCheckingTypePhoneNumber) {
      NSString* urlStr = [result.URL.absoluteString
                          stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      if (result.resultType == NSTextCheckingTypePhoneNumber) {
        urlStr = result.phoneNumber;
      }
      NSRange range = result.range;
      if (range.location != NSNotFound) {
        if (startOffset >= range.location &&
            startOffset < NSMaxRange(range)) {
          NSMutableAttributedString *mutAtt = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
          
          [mutAtt addAttributes:@{NSBackgroundColorAttributeName:[UIColor cyanColor]} range:range];
          _selectRange = range;
          _selectType = result.resultType;
          self.attributedText = mutAtt;
          return urlStr;
        }
      }
    }
  }
  return @"";
}

- (void)cancelSelectUrl
{
  if (_selectRange.location != NSNotFound && NSMaxRange(_selectRange) < self.attributedText.length) {
    NSMutableAttributedString *mutAtt = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [mutAtt addAttributes:@{NSBackgroundColorAttributeName:[UIColor clearColor]} range:_selectRange];
    _selectRange = NSMakeRange(NSNotFound, 0);
    self.attributedText = mutAtt;
  }
}

- (NSArray *)matchUrl:(NSString *)urlStr
{
  NSMutableArray *returnArr = [NSMutableArray array];
  NSError *error;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
  if (error && error.code != 0) {
    return returnArr;
  }
  
  NSArray *resultArr = [regex matchesInString:self.attributedText.string options:NSMatchingReportProgress range:NSMakeRange(0, self.attributedText.string.length)];
  for (NSTextCheckingResult* result in resultArr) {
    [returnArr addObject:NSStringFromRange(result.range)];
  }
  
  return returnArr;
}

- (NSMutableAttributedString*)showStringLink:(NSString*)str {
  NSMutableAttributedString* mutAttStr =
  [[NSMutableAttributedString alloc] initWithString:str];
  if (mutAttStr.length < 1) {
    return mutAttStr;
  }
  [mutAttStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:16.0]
                    range:NSMakeRange(0, mutAttStr.length)];
  NSError* error = nil;
  NSDataDetector* detector =
  [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                  error:&error];
  
//  NSError *error;
////  NSString *regulaStr = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
//  NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
//  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
//                                                                         options:NSRegularExpressionCaseInsensitive
//                                                                           error:&error];
  
  if (error != nil || !detector) {
    return mutAttStr;
  }
  NSArray* results = [detector matchesInString:str
                                       options:NSMatchingReportProgress
                                         range:NSMakeRange(0, str.length)];
  
  for (NSTextCheckingResult* result in results) {
//    if (result.resultType == NSTextCheckingTypeLink) {
    NSString* substringForMatch = [str substringWithRange:result.range];
      NSURL* url = result.URL;
      [mutAttStr addAttributes:@{NSLinkAttributeName : substringForMatch}
                         range:result.range];
//    }
  }
  return mutAttStr;
}

- (void)setMyTextViewAttributedText:(NSAttributedString *)attributedText
{
  NSMutableAttributedString *mutAtt = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
  [attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
    if (!value) {
      [mutAtt replaceCharactersInRange:range withAttributedString:[self showStringLink:[[attributedText attributedSubstringFromRange:range]string]]];
    }
  }];
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
  
  paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
  
  self.attributedText = mutAtt;
}

- (NSString*)getMyTextViewText
{
  NSMutableString *mutText = [[NSMutableString alloc] initWithCapacity:self.attributedText.length];
  [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
    if (value) {
      [mutText appendString:@"⍰"];
    } else {
      NSAttributedString *att = [self.attributedText attributedSubstringFromRange:range];
      [mutText appendString:att.string];
    }
  }];
  
  return mutText;
}


@end
