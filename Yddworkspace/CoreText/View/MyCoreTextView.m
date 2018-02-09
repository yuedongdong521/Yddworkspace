//
//  MyCoreTextView.m
//  Yddworkspace
//
//  Created by ispeak on 2017/12/1.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MyCoreTextView.h"

@implementation MyCoreTextView

- (instancetype)initWithFrame:(CGRect)frame WithCTFrame:(CTFrameRef)frameRef 
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        _frameRef = frameRef;
        _images = [NSArray array];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw(_frameRef, context);
    for (NSDictionary *dic in _images) {
        UIImage *image = [dic objectForKey:@"image"];
        CGRect imageFrame = [[dic objectForKey:@"imageFrame"] CGRectValue];
        CGContextDrawImage(context, imageFrame, image.CGImage);
    }
    CFRelease(_frameRef);
}





@end
