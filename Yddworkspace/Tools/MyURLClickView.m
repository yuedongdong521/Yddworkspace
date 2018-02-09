//
//  MyURLClickView.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/29.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyURLClickView.h"

@implementation MyURLClickView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame WithClickURL:(ClickURL)clickURL
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clickURL = clickURL;
        self.editable = NO;
        self.scrollEnabled = NO;
        self.linkTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                    NSForegroundColorAttributeName:[UIColor blueColor]
                                    };
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(urlClickAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)urlClickAction:(UITapGestureRecognizer *)tap
{
    if (self.text.length < 1) {
        return;
    }
    CGPoint location = [tap locationInView:self];
    NSString *strURL = [self getClickURLForLocation:location];
    if (self.clickURL) {
        self.clickURL([NSURL URLWithString:strURL]);
    }
}

- (NSString *)getClickURLForLocation:(CGPoint)location
{
    NSString *context = self.text;
    if (context.length < 1) {
        return @"";
    }
    location.y += self.contentOffset.y;
    
    UITextPosition *position = [self closestPositionToPoint:location];
    NSInteger startOffset = [self offsetFromPosition:self.beginningOfDocument toPosition:position];
    if (startOffset > context.length - 1) {
        return @"";
    }
    
    NSError *error = nil;
    NSDataDetector *datector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    if (error != nil) {
        return @"";
    }
    
    NSArray *array = [datector matchesInString:context options:NSMatchingReportProgress range:NSMakeRange(0, self.text.length)];
    
    for (NSTextCheckingResult *result in array) {
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

- (void)setText:(NSString *)text
{
    if (text.length < 1) {
        return;
    }

    self.attributedText = [self creatAttributedText:text];
    
}

- (NSMutableAttributedString *)creatAttributedText:(NSString *)str
{
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:str];
    [att addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                         NSForegroundColorAttributeName:[UIColor grayColor],
                         } range:NSMakeRange(0, str.length)];
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    if (error != nil) {
        return att;
    }
    
    NSArray *arr = [detector matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];
    
    for (NSTextCheckingResult *result in arr) {
        if (result.resultType == NSTextCheckingTypeLink) {
            [att addAttributes:@{NSLinkAttributeName:result.URL.absoluteString} range:result.range];
        }
    }
    return att;
    
    
}





@end
