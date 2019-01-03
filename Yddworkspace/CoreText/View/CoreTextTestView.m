//
//  CoreTextTestView.m
//  Yddworkspace
//
//  Created by ydd on 2018/9/6.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "CoreTextTestView.h"

@implementation CoreTextTestView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetTextMatrix(context, CGAffineTransformIdentity);
  CGContextTranslateCTM(context, 0, self.bounds.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  
  CTFrameDraw(_frameRef, context);
  for (CoreTextImageModel *imageModel in self.imageArr) {
    UIImage *image = [UIImage imageNamed:imageModel.name];
    CGRect imageFrame = imageModel.imageFrame;
    CGContextDrawImage(context, imageFrame, image.CGImage);
  }
//  CFRelease(_frameRef);
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  
}


- (instancetype)initWithFrame:(CGRect)frame 
{
  self = [super initWithFrame:frame];
  if (self) {
    
  }
  return self;
}

- (void)setFrameRef:(CTFrameRef)frameRef
{
  _frameRef = frameRef;
}

- (void)dealloc
{
  NSLog(@"dealloc %@", NSStringFromClass(self.class));
}


@end
