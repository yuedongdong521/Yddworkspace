//
//  MyAttributedString.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MyAttributedString.h"
#import "CTModel.h"


/* Callbacks */
static void deallocCallback( void* ref ){
    ref =nil;
}

static CGFloat ascentCallback( void *ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback( void *ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"descent"] floatValue];
}

static CGFloat widthCallback( void* ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

@implementation MyAttributedString

/*
以下是著名的Arial变体：
Arial：有时称为Arial Regular以便与Arial Narrow区别，其包括Arial、Arial Italic（斜体）、Arial Bold（粗体）、Arial Bold Italic（粗斜体）和Arial Unicode MS
Arial Black：此字体的特色在于其笔画相当的粗，包含Arial Black、Arial Black Italic（斜体）
Arial Narrow：为Arial的细瘦版本，包含Arial Narrow Regular、Arial Narrow Bold（粗体）、Arial Narrow Italic（斜体）和Arial Narrow Bold Italic（粗斜体）
Arial Rounded：包含Arial Rounded Bold（粗体），此字体可在微软韩文字体Gulim找到。
*/
- (instancetype)initWithSize:(CGSize)size
{
    self = [super init];
    if (self) {
        self.font = @"Arial";
        self.color = [UIColor blackColor];
        self.strokeColor = [UIColor blackColor];
        self.strokeWidth = 0.0;
        self.images = [NSMutableArray array];
        self.contentSize = size;
    }
    return self;
}

- (NSAttributedString *)attrStringFromMark:(NSString *)mark
{
    if (mark == nil) {
        NSLog(@"没有内容");
        return nil;
    }
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSError *error = nil;
    //(.*?) .通配符  *？匹配上一个元素零次或多次， 但次数尽可能少。
    // ^匹配必须从字符串或一行的开头开始。
    // <>的位置
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(.*?)(<[^>]+>|\\Z)" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSArray *chunks = [regex matchesInString:mark options:0 range:NSMakeRange(0, mark.length)];
    if (error) {
        NSLog(@"解析标签出现错误:%@\n%@",[error userInfo],error);
        //匹配不到，返回原字符串
        return [[NSAttributedString alloc] initWithString:mark];
    }
    NSLog(@"chunks = %@", chunks);
    
    for (NSTextCheckingResult *result in chunks) {
        //1. 字符串切割 快速枚举chunks数组中我们用正则找到的NSTextCheckingResult对象，对“chunks”数组中的元素用<字符分割（<是标签的起始）。其结果，在parts [0]中的内容添加到aString中(aString是一个NSAttributedString)，接下来在parts[1]中你有标记的内容为后面的文本改变格式。
        NSString *tmpStr = [mark substringWithRange:result.range];
        NSArray *parts = [tmpStr componentsSeparatedByString:@"<"];
        
        UIFont *font = [UIFont fontWithName:self.font size:self.contentSize.height / 40];
    
        //2. 设置当前文本显示样式 创建一个字典保持一系列的格式化选项- 这是你可以通过格式属性的NSAttributedString的方式。看看这些Key的名称- 他们是苹果定义的常量(详情请围观参考)。通过调用appendAttributedString: 新的文本块与应用格式被添加到结果字符串。
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)self.font, self.contentSize.height / 40, NULL);
        NSDictionary *attrDic = @{
                                  (id)kCTForegroundColorAttributeName: (id)self.color.CGColor,
                                  (id)kCTFontAttributeName:(__bridge id)fontRef,
                                  (id)kCTStrokeColorAttributeName:(__bridge id)self.strokeColor.CGColor,
                                  (id)kCTStrokeWidthAttributeName:[NSNumber numberWithFloat:self.strokeWidth]
                                  };
        [aString appendAttributedString:[[NSAttributedString alloc]initWithString:parts[0] attributes:attrDic]];
        CFRelease(fontRef);
        
        //3. 是否带属性， 处理新的样式  检查如果有文字后发现了一个标记；如果以font开头的正则表达式每一种可能的标记属性。对于face属性的字体的名称保存在self.font，为color我和你做了一点改变：对<font color="red">文本值red采取的是colorRegex，然后选择器redColor被创建和执行在UIColor。
        if (parts.count > 1) {
            NSString *tag = parts[1];
            if ([tag hasPrefix:@"font"]) {
                //stroke color
                NSRegularExpression *scReg = [[NSRegularExpression alloc] initWithPattern:@"(?<=strokeColor=\")\\w+" options:0 error:nil];
                [scReg enumerateMatchesInString:tag options:0 range:NSMakeRange(0, tag.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                    if ([[tag substringWithRange:result.range] isEqualToString:@"none"]) {
                        self.strokeWidth = 0.0;
                    } else {
                        self.strokeWidth = -3.0;
                        SEL colorSel = NSSelectorFromString([NSString stringWithFormat:@"%@Color", [tag substringWithRange:result.range]]);
                        self.strokeColor = [UIColor performSelector:colorSel];
                    }
                }];
                
                //Color
                NSRegularExpression *colorReg = [[NSRegularExpression alloc] initWithPattern:@"(?<=color=\")\\w+" options:0 error:nil];
                [colorReg enumerateMatchesInString:tag options:0 range:NSMakeRange(0, tag.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                    SEL colorSel = NSSelectorFromString([NSString stringWithFormat:@"%@Color", [tag substringWithRange:result.range]]);
                    self.color = [UIColor performSelector:colorSel];
                }];
                
                //font <font color="red" strokeColor="orange" face="Zapfino">Letter from the editor
                NSRegularExpression *faceRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=face=\")[^\"]+" options:0 error:nil];
                [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                    self.font = [tag substringWithRange:result.range];
                }];
                //end of font parsing 结束字体解析
            } else if ([tag hasPrefix:@"img"]) {
                
                __block  NSString *filename = @"";
                NSRegularExpression *imageRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=src=\")[^\"]+" options:0 error:nil];
                [imageRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, tag.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                    NSRange range = result.range;
                    if (range.location != NSNotFound) {
                        filename = [tag substringWithRange:range];
                    }
                }];
                //2
                CTModel *model = [[CTModel alloc] initWithViewSize:_contentSize];
                CGFloat width = model.columnRect.size.width;
                CGFloat height = 0;
                
                UIImage *image = [UIImage imageNamed:filename];
                if (image) {
                    height = width * (image.size.height / image.size.width);
                    //3
                    if (height > model.columnRect.size.height - font.lineHeight) {
                        height = model.columnRect.size.height - font.lineHeight;
                        width = height * (image.size.width / image.size.height);
                    }
                }
                
                [_images addObject:@{@"width": [NSNumber numberWithFloat:width], @"height": [NSNumber numberWithFloat:height], @"filename": filename, @"location": [NSNumber numberWithInteger:aString.length]}];
                
                
                CTRunDelegateCallbacks callbacks;
                callbacks.version = kCTRunDelegateVersion1;
                callbacks.getAscent = ascentCallback;
                callbacks.getDescent = descentCallback;
                callbacks.getWidth = widthCallback;
                callbacks.dealloc = deallocCallback;
                
                NSDictionary *imageAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:width],@"width", [NSNumber numberWithFloat:height], @"height", nil];
                
                CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(imageAttr));
                NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        //set the delegate
                                                        (__bridge id)delegate, (NSString*)kCTRunDelegateAttributeName,
                                                        nil];
                [aString appendAttributedString:[[NSAttributedString alloc]initWithString:@" " attributes:attrDictionaryDelegate]];
            }
        }
    }
    return aString;
}

- (void)dealloc
{
    NSLog(@"MyAttributedString dealloc");
}


@end
