//
//  BezierView.m
//  Yddworkspace
//
//  Created by ydd on 2020/1/14.
//  Copyright © 2020 QH. All rights reserved.
//

#import "BezierView.h"

@interface BezierPoint : UIView

@property (nonatomic, copy) void(^didChange)(CGPoint p);

@end

@implementation BezierPoint

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.width * 0.5;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint p = [pan locationInView:self.superview];
    self.center = p;
    if (self.didChange) {
        self.didChange(p);
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged:
            
        
            break;
        case UIGestureRecognizerStateEnded:
        
            break;
            
        default:
            break;
    }
}


@end

@interface BezierView ()

@property (nonatomic, assign) CGPoint controlPoint1;

@property (nonatomic, assign) CGPoint controlPoint2;

@end


@implementation BezierView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(rect.size.width * 0.5, 0)];
    [path addCurveToPoint:CGPointMake(rect.size.width * 0.5, rect.size.height) controlPoint1:self.controlPoint1 controlPoint2:self.controlPoint2];
    [[UIColor greenColor] set];
    [path stroke];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.controlPoint1 = CGPointZero;
        self.controlPoint2 = CGPointZero;
        
        BezierPoint *point1 = [[BezierPoint alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        point1.backgroundColor = [UIColor redColor];
        [self addSubview:point1];
        point1.didChange = ^(CGPoint p) {
            self.controlPoint1 = p;
            [self setNeedsDisplay];
        };
        
        BezierPoint *point2 = [[BezierPoint alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        point2.backgroundColor = [UIColor redColor];
        [self addSubview:point2];
        point2.didChange = ^(CGPoint p) {
            self.controlPoint2 = p;
            [self setNeedsDisplay];
        };
    }
    return self;
}


@end
