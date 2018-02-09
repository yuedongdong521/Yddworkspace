//
//  CTScrollView.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "CTScrollView.h"
#import "CTColumnView.h"

@implementation CTScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)buildFramesAttrString:(NSAttributedString *)attrString AndImages:(NSArray *)images
{
    _imageIndex = 0;
    self.pagingEnabled = YES;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    
    int textPos = 0;
    CGFloat pageIndex = 0.0;
    CTModel *models = [[CTModel alloc] initWithViewSize:self.bounds.size];
    
    while (textPos < attrString.length) {
        UIView *pageView = [[UIView alloc] init];

        pageView.frame = CGRectMake(models.pageRect.origin.x + ViewW(self) * pageIndex, models.pageRect.origin.y, models.pageRect.size.width, models.pageRect.size.height);
        [self addSubview:pageView];
        
        pageIndex++;
        
        NSLog(@"pageView Frame = %@", NSStringFromCGRect(pageView.frame));
        
        CGRect columnFrame = models.columnRect;
        
        //1
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, columnFrame);
        CTFrameRef ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, nil);
        //2
        CTColumnView *columnView = [[CTColumnView alloc] initWithFrame:columnFrame andCTFrame:ctframe];
        if (images.count > _imageIndex) {
            [self attachImagesWithFrameImages:images Ctframe:ctframe Margin:models.margin ColumnView:columnView];
        }
        [pageView addSubview:columnView];
        
        NSLog(@"columnView Frame = %@", NSStringFromCGRect(columnView.frame));
        
        //3
        CFRange frameRange = CTFrameGetVisibleStringRange(ctframe);
        textPos = textPos + frameRange.length;
    }
    self.contentSize = CGSizeMake(pageIndex * self.bounds.size.width, 0);
}


- (void)attachImagesWithFrameImages:(NSArray *)images Ctframe:(CTFrameRef)ctframe Margin:(CGFloat)margin ColumnView:(CTColumnView *)columnView
{
    //1 获取段落（ctframe） 行 （lines）
    NSArray *lines = (NSArray *)CTFrameGetLines(ctframe);
    //2 获取行的起始点坐标
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
    //3
    NSDictionary *nextImage = images[_imageIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue];
    //4
    for (int lineIndex = 0; lineIndex < lines.count; lineIndex++) {
        CTLineRef line = (__bridge CTLineRef)lines[lineIndex];
        //5
        
        NSArray * glyphRuns = (NSArray *)CTLineGetGlyphRuns(line);
        NSString *imageFilename = [nextImage objectForKey:@"filename"];
        UIImage *img = [UIImage imageNamed:imageFilename];
        if (glyphRuns.count > 0 && img != nil) {
            for (id run in glyphRuns) {
                // 1
               CFRange runRange = CTRunGetStringRange((__bridge CTRunRef)run);
                if (runRange.location > imgLocation || runRange.location + runRange.length <= imgLocation) {
                    continue;
                }
                //2
                CGRect imgBounds = CGRectZero;
                CGFloat ascent = 0;
                imgBounds.size.width = (CGFloat)CTRunGetTypographicBounds((__bridge CTRunRef) run, CFRangeMake(0, 0), &ascent, NULL, NULL);
                imgBounds.size.height = ascent;
                //3
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange((__bridge CTRunRef)run).location, nil);
                imgBounds.origin.x = origins[lineIndex].x + xOffset;
                imgBounds.origin.y = origins[lineIndex].y;
                //4
                [columnView.images addObject:@{@"image":img, @"frame": [NSValue valueWithCGRect:imgBounds]}];
                //5
                _imageIndex++;
                if (_imageIndex < images.count) {
                    nextImage = images[_imageIndex];
                    imgLocation = [[nextImage objectForKey:@"location"] intValue];
                }
            }
        }
    }
}

- (void)dealloc
{
    NSLog(@"CTScrollView dealloc");
}


@end
