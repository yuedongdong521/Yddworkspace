//
//  CoreTextTowView.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/30.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "CoreTextTowView.h"
#import "UIImage+DrawRound.h"

@interface CoreTextTowView()
{
    CTFrameRef _frame;
    NSInteger _length;
    CGRect _imgFrame;
    NSMutableArray *arrText;
    CGFloat _contentOfSizeY;
    
}

@end
@implementation CoreTextTowView

static CGFloat ascentCallBacks(void * ref)
{
    return [(NSNumber *)[(__bridge NSDictionary *)ref valueForKey:@"height"] floatValue];
}
static CGFloat descentCallBacks(void * ref)
{
    return 0;
}
static CGFloat widthCallBacks(void * ref)
{
    return [(NSNumber *)[(__bridge NSDictionary *)ref valueForKey:@"width"] floatValue];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    NSLog(@"coretextTowView.bounds = %@", NSStringFromCGRect(self.bounds));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    arrText = [NSMutableArray array];

    NSString *textstr = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"coretextTest" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textstr];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor cyanColor] range:NSMakeRange(0, attributedString.length)];
    
    CTRunDelegateCallbacks callBackes;
    memset(&callBackes, 0, sizeof(CTRunDelegateCallbacks));
    callBackes.version = kCTRunDelegateVersion1;
    callBackes.getAscent = ascentCallBacks;
    callBackes.getDescent = descentCallBacks;
    callBackes.getWidth = widthCallBacks;
    
    NSDictionary *dicPic = @{@"height":@90, @"width":@160};
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callBackes, (__bridge void *)dicPic);
    unichar placeHolder = 0xFFFC;
    NSString *placeHolderStr = [NSString stringWithCharacters:&placeHolder length:1];
    NSMutableAttributedString *placeHolderAttrStr = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeHolderAttrStr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    
    [attributedString insertAttributedString:placeHolderAttrStr atIndex:60];
    
    NSDictionary *activeAttr = @{NSForegroundColorAttributeName:[UIColor redColor], @"click":NSStringFromSelector(@selector(clickAction))};
    [attributedString addAttributes:activeAttr range:NSMakeRange(100, 30)];
    [attributedString addAttributes:activeAttr range:NSMakeRange(200, 100)];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cirP = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100, 100, 50, 100)];
    [path appendPath:cirP];
    
    _length = attributedString.length;
    _frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedString.length), path.CGPath, NULL);
    
    CTFrameDraw(_frame, context);
    
    UIImage *image = [UIImage imageNamed:@"0.jpg"];
    
    [self handleActiveRectWithFrame:_frame];
    CGContextDrawImage(context, _imgFrame, image.CGImage);
    
    UIImage *image1 = [[UIImage imageNamed:@"1.jpg"] drawRoundWithPath:cirP Mode:UIViewContentModeScaleAspectFill];
    CGContextDrawImage(context, cirP.bounds,image1.CGImage);
    CFRelease(_frame);
    CFRelease(framesetter);
    
    
}



- (void)handleActiveRectWithFrame:(CTFrameRef)frame
{
    NSArray *arrlines = (NSArray *)CTFrameGetLines(frame);
    NSInteger count = arrlines.count;
    CGPoint points[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
    
    for (int i = 0; i < count; i++) {
        CTLineRef line = (__bridge CTLineRef)arrlines[i];
        CGFloat lineAscent;
        CGFloat lineDescent;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
        _contentOfSizeY += lineDescent + lineAscent;
        NSArray *arrGlyphRun = (NSArray *)CTLineGetGlyphRuns(line);
        for (int j = 0; j < arrGlyphRun.count; j++) {
            CTRunRef run = (__bridge CTRunRef)arrGlyphRun[j];
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];
            CGPoint point = points[i];
            if (delegate == nil) {
                NSString *string = attributes[@"click"];
                if (string) {
                    [arrText addObject:[NSValue valueWithCGRect:[self getLocWithFrame:frame CTLine:line CTRun:run origin:point]]];
                }
                continue;
            }
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            _imgFrame = [self getLocWithFrame:frame CTLine:line CTRun:run origin:point];
        }
    }
    
}

- (CGRect)getLocWithFrame:(CTFrameRef)frame CTLine:(CTLineRef)line CTRun:(CTRunRef)run origin:(CGPoint)origin
{
    CGFloat ascent;//行上边距离
    CGFloat descent;//行下边距离
    CGRect boundsRun;
    
    boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
    boundsRun.size.height = ascent + descent;
    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
    boundsRun.origin.x = origin.x + xOffset;
    boundsRun.origin.y = origin.y - descent;
    CGPathRef path = CTFrameGetPath(frame);
    CGRect colRect = CGPathGetBoundingBox(path);
    CGRect deleteBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);
    return deleteBounds;
}

-(CGRect)convertRectFromLoc:(CGRect)rect
{
    return CGRectMake(rect.origin.x, self.bounds.size.height - rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGRect imageFrmToScreen = [self convertRectFromLoc:_imgFrame];
    if (CGRectContainsPoint(imageFrmToScreen, location)) {
        [[[UIAlertView alloc] initWithTitle:@"点击了图片" message:nil delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [arrText enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect textFrameToScreen = [self convertRectFromLoc:[obj CGRectValue]];
        if (CGRectContainsPoint(textFrameToScreen, location)) {
            [self clickAction];
            *stop = YES;
        }
    }];
    
}

- (void)clickAction
{
    [[[UIAlertView alloc] initWithTitle:@"点击了文字" message:nil delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil] show];
}


@end
