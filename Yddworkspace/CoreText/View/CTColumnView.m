//
//  CTColumnView.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "CTColumnView.h"

@implementation CTColumnView

- (instancetype)initWithFrame:(CGRect)frame andCTFrame:(CTFrameRef)ctFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.ctFrame = ctFrame;
        self.backgroundColor = [UIColor whiteColor];
        self.images = [NSMutableArray array];
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
    
    CTFrameDraw(_ctFrame, context);
    
    for (NSDictionary* imageData in self.images) {
        UIImage* img = [imageData objectForKey:@"image"];
//        CGRect imgBounds = CGRectFromString([imageData objectForKey:@"frame"]);
        CGRect imgBounds = [[imageData objectForKey:@"frame"] CGRectValue];

        CGContextDrawImage(context, imgBounds, img.CGImage);
    }

    CFRelease(_ctFrame);
    
}

- (void)dealloc
{
    NSLog(@"CTColumnView dealloc");
}

@end
