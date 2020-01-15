//
//  BezierView.m
//  Yddworkspace
//
//  Created by ydd on 2020/1/14.
//  Copyright © 2020 QH. All rights reserved.
//

#import "BezierView.h"

@interface BezierPoint : UILabel

@property (nonatomic, copy) void(^didChange)(CGPoint p);

@end

@implementation BezierPoint

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.textAlignment = NSTextAlignmentCenter;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
        self.userInteractionEnabled = YES;
        self.layer.cornerRadius = frame.size.width * 0.5;
        self.layer.masksToBounds = YES;
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

@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, assign) CGPoint endPoint;

@end


@implementation BezierView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.startPoint];
    [path addCurveToPoint:self.endPoint controlPoint1:self.controlPoint1 controlPoint2:self.controlPoint2];
    [[UIColor greenColor] set];
    [path stroke];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.controlPoint1 = CGPointZero;
        self.controlPoint2 = CGPointZero;
        self.startPoint = CGPointZero;
        self.endPoint = CGPointZero;
        
        BezierPoint *point1 = [[BezierPoint alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        point1.text = @"C1";
        point1.backgroundColor = [UIColor redColor];
        [self addSubview:point1];
        
        __weak typeof(self) weakself = self;
        point1.didChange = ^(CGPoint p) {
            __strong typeof(weakself) strongself = weakself;
            strongself.controlPoint1 = p;
            [strongself setNeedsDisplay];
        };
        
        BezierPoint *point2 = [[BezierPoint alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        point2.text = @"C2";
        point2.backgroundColor = [UIColor redColor];
        [self addSubview:point2];
        point2.didChange = ^(CGPoint p) {
            __strong typeof(weakself) strongself = weakself;
            strongself.controlPoint2 = p;
            [strongself setNeedsDisplay];
        };
        
        BezierPoint *startP = [[BezierPoint alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        startP.text = @"S";
        startP.backgroundColor = [UIColor redColor];
        [self addSubview:startP];
        startP.didChange = ^(CGPoint p) {
            __strong typeof(weakself) strongself = weakself;
            strongself.startPoint = p;
            [strongself setNeedsDisplay];
        };
        
        BezierPoint *endP = [[BezierPoint alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        endP.text = @"E";
        endP.backgroundColor = [UIColor redColor];
        [self addSubview:endP];
        endP.didChange = ^(CGPoint p) {
            __strong typeof(weakself) strongself = weakself;
            strongself.endPoint = p;
            [strongself setNeedsDisplay];
        };
        
        
        
    }
    return self;
}


@end
