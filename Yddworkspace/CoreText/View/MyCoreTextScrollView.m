//
//  MyCoreTextScrollView.m
//  Yddworkspace
//
//  Created by ispeak on 2017/12/1.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MyCoreTextScrollView.h"
#import "MyCoreTextView.h"
#import "MyStringEdit.h"

@implementation MyCoreTextScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pagingEnabled = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)creatCTFrameRefWithContentStr:(NSString *)contentStr
{
    NSMutableAttributedString *attString = [MyStringEdit attributedStringEditWithStr:contentStr];
    
//    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:contentStr];
//    [attString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, attString.length)];
    
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
    
    NSInteger attStrLength = 0;
    
    int pageIndex = 0;
    while (attStrLength < attString.length) {
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.bounds);
        CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(attStrLength, 0), path, NULL);
        
        CGRect contextViewFrame = CGRectMake(0, ViewH(self) * pageIndex, ScreenWidth, ViewH(self));
        MyCoreTextView *myCoreTextView = [[MyCoreTextView alloc] initWithFrame:contextViewFrame WithCTFrame:frameRef];
        [self addSubview:myCoreTextView];
        pageIndex++;
        CFRange range = CTFrameGetVisibleStringRange(frameRef);
        attStrLength += range.length;
    }
    
    self.contentSize = CGSizeMake(0, ViewH(self) * pageIndex);
    
}

@end
