//
//  MyStringEdit.m
//  Yddworkspace
//
//  Created by ispeak on 2017/12/5.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MyStringEdit.h"

@implementation MyStringEdit

+ (NSMutableAttributedString *)attributedStringEditWithStr:(NSString *)str
{
    NSMutableAttributedString *mubAttString = [[NSMutableAttributedString alloc] init];
//    NSMutableString *mutbString = [NSMutableString stringWithString:str];
    while (1) {
        NSRange range = [str rangeOfString:@"\\n"];
        if (range.location != NSNotFound) {
            NSString *tmpStr = [str substringToIndex:range.location];
            NSMutableAttributedString *tmpAttStr = [[NSMutableAttributedString alloc] initWithString:tmpStr];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = NSTextAlignmentLeft;
            paragraphStyle.firstLineHeadIndent = 8.0;
            paragraphStyle.minimumLineHeight = 18.0;
            paragraphStyle.lineSpacing = 3.0;
            paragraphStyle.paragraphSpacing = 5.0;
            paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
            
            NSDictionary *dic = @{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:14],
                                  NSForegroundColorAttributeName:GETColor(0x888888, 1.0)
                                  ,NSParagraphStyleAttributeName:paragraphStyle};
            [tmpAttStr addAttributes:dic range:NSMakeRange(0, range.location)];
            [mubAttString appendAttributedString:tmpAttStr];
            
            str = [str substringFromIndex:range.location + range.length];
        } else {
            break;
        }
    }
    if (!mubAttString) {
        mubAttString = [[NSMutableAttributedString alloc] initWithString:str];
    }
    
    return mubAttString;
}


@end
