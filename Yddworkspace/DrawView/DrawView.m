//
//  DrawView.m
//  Yddworkspace
//
//  Created by ydd on 2020/1/15.
//  Copyright © 2020 QH. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    switch (self.type) {
        case DrawType_line:
            [self drawLine];
            break;
        case DrawType_text:
            [self drawText];
            break;
        case DrawType_box:
            [self drawBox];
            break;
        case DrawType_box_border:
            [self drawBoxBorder];
            break;
        case DrawType_box_bgColor:
            [self drawBoxBgColor];
            break;
        case DrawType_ellipse:
            [self drawEllipse];
            break;
        case DrawType_arc:
            [self drawArc];
            break;
        case DrawType_gradient:
            [self drawGradient];
            break;
        case DrawType_addLine:
            [self drawAddLine];
            break;
        case DrawType_fillEllipse:
            [self drawFillEllipse];
            break;
        case DrawType_prism:
            [self drawPrism];
            break;
        case DrawType_fillColorPrism:
            [self drawFillColorPrism];
            break;
        case DrawType_fillBorder:
            [self drawFillBorder];
            break;
        case DrawType_bezier:
            [self drawBezier];
            break;
        case DrawType_bezier2:
            [self drawBezier2];
            break;
        case DrawType_dottedline:
            [self drawDottedline];
            break;
        case DrawType_image:
            [self drawImage];
            break;
        case DrawType_image1:
            [self drawImage1];
            break;
        case DrawType_image2:
            [self drawImage2];
            break;
        case DrawType_image3:
            [self drawImage3];
            break;
        default:
            break;
    }
}

 /// NO.1画一条线
- (void)drawLine
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);//线条颜色
    CGContextMoveToPoint(context, 20, 20);
    CGContextAddLineToPoint(context, 200,20);
    CGContextStrokePath(context);
}

/// NO.2画文字
- (void)drawText
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBFillColor (context, 0.5, 0.5, 0.5, 0.5);
    NSString *text = @"高级iOS开发工程师";
    [text drawInRect:self.bounds withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:30]}];
}

/// NO.3画一个矩形 没有边框
- (void)drawBox
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0.25, 0, 0.5);
    CGContextFillRect(context, CGRectMake(2, 2, 270, 270));
    CGContextStrokePath(context);
}

/// NO.4画正方形边框
- (void)drawBoxBorder
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);//线条颜色
    CGContextSetLineWidth(context, 2.0);
    CGContextAddRect(context, CGRectMake(2, 2, 270, 270));
    CGContextStrokePath(context);
}

/// NO.5画方形背景颜色
- (void)drawBoxBgColor
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    UIGraphicsPushContext(context);
    CGContextSetLineWidth(context,320);
    CGContextSetRGBStrokeColor(context, 250.0/255, 250.0/255, 210.0/255, 1.0);
    CGContextStrokeRect(context, CGRectMake(0, 0, 320, 460));
    UIGraphicsPopContext();
}
/// NO.6 椭圆
- (void)drawEllipse
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *aColor = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0];
    
    CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0, 1.0);
    
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    
    //椭圆
    
    CGRect aRect= CGRectMake(80, 80, 160, 100);
    
    CGContextSetRGBStrokeColor(context, 0.6, 0.9, 0, 1.0);
    
    CGContextSetLineWidth(context, 3.0);
    
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    
    CGContextAddRect(context, self.bounds); //矩形
    
    CGContextAddEllipseInRect(context, aRect); //椭圆
    
    CGContextDrawPath(context, kCGPathStroke);
    
    
    
}

/// NO.7 圆弧
- (void)drawArc
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBStrokeColor(context, 0, 0, 1, 1);
    
    CGContextMoveToPoint(context, 100, 100);
    
    CGContextAddArcToPoint(context, 50, 100, 50, 150, 50);
    
    CGContextStrokePath(context);
}

/// NO.8 渐变
- (void)drawGradient
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClip(context);
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    CGFloat colors[] =
    {
        204.0 / 255.0, 224.0 / 255.0, 244.0 / 255.0, 1.00,
        
        29.0 / 255.0, 156.0 / 255.0, 215.0 / 255.0, 1.00,
        
        0.0 / 255.0,  50.0 / 255.0, 126.0 / 255.0, 1.00,
    };
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents
    
    (rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    
    CGColorSpaceRelease(rgb);
    
    CGContextDrawLinearGradient(context, gradient,CGPointMake
                                
                                (0.0,0.0) ,CGPointMake(0.0,self.frame.size.height),
                                
                                kCGGradientDrawsBeforeStartLocation);
}

/// NO.9添加线
- (void)drawAddLine
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *aColor = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0];
    
    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1.0);
    
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    
    CGContextSetLineWidth(context, 4.0);
    
    CGPoint aPoints[5];
    
    aPoints[0] =CGPointMake(60, 60);
    
    aPoints[1] =CGPointMake(260, 60);
    
    aPoints[2] =CGPointMake(260, 300);
    
    aPoints[3] =CGPointMake(60, 300);
    
    aPoints[4] =CGPointMake(60, 60);
    
    CGContextAddLines(context, aPoints, 5);
    
    CGContextDrawPath(context, kCGPathStroke); //开始画线
}
/// NO.10绘制实心圆
- (void)drawFillEllipse
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillEllipseInRect(context, CGRectMake(95, 95, 100.0, 100));
    CGContextStrokePath(context);
}
/// NO.11棱形
- (void)drawPrism
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    CGContextMoveToPoint(context, 100, 100);
    
    CGContextAddLineToPoint(context, 150, 150);
    
    CGContextAddLineToPoint(context, 100, 200);
    
    CGContextAddLineToPoint(context, 50, 150);
    
    CGContextAddLineToPoint(context, 100, 100);
    
    CGContextStrokePath(context);
}

/// NO.12用红色填充
- (void)drawFillColorPrism
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, 100, 100);
    
    CGContextAddLineToPoint(context, 150, 150);
    
    CGContextAddLineToPoint(context, 100, 200);
    
    CGContextAddLineToPoint(context, 50, 150);
    
    CGContextAddLineToPoint(context, 100, 100);
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextFillPath(context);
}

/// NO.13带边框的填充色块
- (void)drawFillBorder
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    CGRect rectangle = CGRectMake(60,170,200,80);
    
    CGContextAddRect(context, rectangle);
    
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextFillRect(context, rectangle);
}

/// NO.14 绘制贝塞尔曲线
/// 贝塞尔曲线是通过移动一个起始点，然后通过两个控制点,还有一个中止点，调用CGContextAddCurveToPoint() 函数绘制
- (void)drawBezier
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextMoveToPoint(context, 10, 10);
    CGContextAddCurveToPoint(context, 0, 50, 300, 250, 300, 400);
    CGContextStrokePath(context);
}
/// NO.15 二次贝塞尔曲线
- (void)drawBezier2
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextMoveToPoint(context, 10, 200);
    CGContextAddQuadCurveToPoint(context, 150, 10, 300, 200);
    CGContextStrokePath(context);
}
/// NO.16 虚线
- (void)drawDottedline
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 5.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGFloat dashArray[] = {2,6,4,2};
    CGContextSetLineDash(context, 3, dashArray, 4);//跳过3个再画虚线，所以刚开始有6-（3-2）=5个虚点
    
    CGContextMoveToPoint(context, 10, 200);
    CGContextAddQuadCurveToPoint(context, 150, 10, 300, 200);
    CGContextStrokePath(context);
}

- (void)drawImage
{
    UIImage* myImageObj = [UIImage imageNamed:@"0.jpg"];
    
//    [myImageObj drawAtPoint:CGPointMake(0, 0)];
    
    [myImageObj drawInRect:CGRectMake(0, 0, 320, 480)];

    NSString *s = @"清风 原木纯品";
    [s drawAtPoint:CGPointMake(100, 0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:34]}];
}

- (void)drawImage1
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage *img = [UIImage imageNamed:@"0.jpg"];
    CGImageRef image = img.CGImage;
    CGContextSaveGState(context);
    CGRect touchRect = CGRectMake(0, 0, img.size.width, img.size.height);
    
    CGContextDrawImage(context, touchRect, image);
    CGContextRestoreGState(context);
}

- (void)drawImage2
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage *img = [UIImage imageNamed:@"0.jpg"];
    CGImageRef image = img.CGImage;
    
    CGContextSaveGState(context);
    CGContextRotateCTM(context, M_PI);
    
    CGContextTranslateCTM(context, -img.size.width, -img.size.height);
    CGRect touchRect = CGRectMake(0, 0, img.size.width, img.size.height);
    
    CGContextDrawImage(context, touchRect, image);
    
    CGContextRestoreGState(context);
}

- (void)drawImage3
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage *img = [UIImage imageNamed:@"0.jpg"];
    
    CGImageRef image = img.CGImage;
    
    CGContextSaveGState(context);
    
    CGAffineTransform myAffine = CGAffineTransformMakeRotation(M_PI);
    
    myAffine = CGAffineTransformTranslate(myAffine, -img.size.width, -img.size.height);
    
    CGContextConcatCTM(context, myAffine);
    
    CGContextRotateCTM(context, M_PI);
    
    CGContextTranslateCTM(context, -img.size.width, -img.size.height);
    CGRect touchRect = CGRectMake(0, 0, img.size.width, img.size.height);
    
    CGContextDrawImage(context, touchRect, image);
    
    CGContextRestoreGState(context);
}


@end
