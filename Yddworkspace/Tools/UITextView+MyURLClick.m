//
//  UITextView+MyURLClick.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/29.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "UITextView+MyURLClick.h"
#import <objc/runtime.h>

static const void *ClickURLKey = &ClickURLKey;

@implementation UITextView (MyURLClick)
@dynamic clickURL;

- (void)addURLClickAction:(ClickURL)clickURL
{
    self.clickURL = clickURL;
    UIGestureRecognizer *tap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(urlClickAction:)];
    [self addGestureRecognizer:tap];
}

- (void)urlClickAction:(UITapGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView:self];
    NSString *url = [self getClickURLForLocation:location];
    if (self.clickURL) {
        self.clickURL([NSURL URLWithString:url]);
    }
    
}

- (NSString *)getClickURLForLocation:(CGPoint)location
{
    location.y = location.y + self.contentOffset.y;
    UITextPosition *tapPosition = [self closestPositionToPoint:location];
    NSString *context = self.text;
    NSInteger startOffset = [self offsetFromPosition:self.beginningOfDocument toPosition:tapPosition];
    if (startOffset > context.length - 1) {
        return @"";
    }
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    if (error != nil) {
        return @"";
    }
    NSArray *results = [detector matchesInString:context options:NSMatchingReportProgress range:NSMakeRange(0, context.length)];
    
    for (NSTextCheckingResult* result in results) {
        if (result.resultType == NSTextCheckingTypeLink) {
            
            NSString* urlStr = [result.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSRange urlRange = [context rangeOfString:urlStr];
            if (urlRange.location != NSNotFound) {
                if (startOffset >= urlRange.location && startOffset < urlRange.length + urlRange.location) {
                    return urlStr;
                }
            } else {
                if ([urlStr hasPrefix:@"http://"]) {
                    NSString *tmpStr = [urlStr stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                    urlRange = [context rangeOfString:tmpStr];
                    if (urlRange.location != NSNotFound) {
                        if (startOffset >= urlRange.location && startOffset < urlRange.length + urlRange.location) {
                            return urlStr;
                        }
                    }
                }
            }
            
        }
    }
    return @"";
}

- (ClickURL)clickURL
{
    return objc_getAssociatedObject(self, ClickURLKey);
}

- (void)setClickURL:(ClickURL)clickURL
{
    objc_setAssociatedObject(self, ClickURLKey, clickURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (NSRange)getCurSeletedRange
{
    UITextPosition* beginning = self.beginningOfDocument;
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

- (void)setCurSelectedRange:(NSRange)range
{
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}



@end
