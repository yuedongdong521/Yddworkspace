//
//  MyTextView.m
//  Yddworkspace
//
//  Created by ispeak on 2017/1/5.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MyTextView.h"
#import <CoreText/CoreText.h>

@implementation MyTextView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    // Drawing code
    //步骤1：得到当前用于绘制画布的上下文，用于后续将内容绘制在画布上
    // 因为Core Text要配合Core Graphic 配合使用的，如Core Graphic一样，绘图的时候需要获得当前的上下文进行绘制
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(ref, CGSizeMake(0.3, 0.3), 0.3,  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor);
    // 步骤2：翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕左下角为（0，0））
    CGContextSetTextMatrix(ref, CGAffineTransformIdentity);
    CGContextTranslateCTM(ref, 0, self.bounds.size.height);
    CGContextScaleCTM(ref, 1.0, -1.0);
    
    
    CGMutablePathRef path = CGPathCreateMutable();
///*
    // 绘制图形路径
    //1.b画一个圆
    //1.b.1创建一条画圆的绘图路径(注意这里是可变的，不是CGPathRef)
    //1.b.2把圆的绘图信息添加到路径里
//    CGPathAddEllipseInRect(path, NULL, self.bounds);
 /*
    // 2.绘制四边形
    //第一种画法,通过连接固定的点绘制四边形
    //    CGContextMoveToPoint(ctx, 0, 20);
    //    CGContextAddLineToPoint(<#CGContextRef c#>, <#CGFloat x#>, <#CGFloat y#>);
    //    CGContextAddLineToPoint(<#CGContextRef c#>, <#CGFloat x#>, <#CGFloat y#>);
    //    CGContextAddLineToPoint(<#CGContextRef c#>, <#CGFloat x#>, <#CGFloat y#>);

    //第二种方式：指定起点和宽高绘制四边形
    //    CGContextAddRect(ctx, CGRectMake(20, 20, 200, 100));
    //    //渲染
    //    CGContextStrokePath(ctx);

    //第三种方式：二种的两步合并成一步。
    //画空心的四边形
    //    CGContextStrokeRect(ctx, CGRectMake(20, 20, 200, 100));
    //    //画实心的四边形
    //    CGContextFillRect(ctx, CGRectMake(20, 20, 200, 100));
    
    //第四种方式（oc的方法）：绘制实心的四边形，注意没有空心的方法
    //    UIRectFill(CGRectMake(20, 20, 200, 100));
    
    //第五种方式：画根线，设置线条的宽度（通过这种方式可以画斜的四边形）
    //    CGContextMoveToPoint(ctx, 20, 20);
    //    CGContextAddLineToPoint(ctx, 100, 200);
    //    CGContextSetLineWidth(ctx, 50);
    //    //注意，线条只能画成是空心的
    //    CGContextStrokePath(ctx);
 */
    
    
    //1 在这里，你需要创建一个边界，在区域的路径中您将绘制文本。（就是说我给你指定一个帐号，你必需给指定帐号汇钱）。在Mac和iOS上CoreText支持不同的形状，如矩形和圆。在这个简单的例子中，您将使用整个视图范围为在那里您将通过创建从self.bounds一个CGPath参考绘制矩形。
    CGPathAddRect(path, NULL, self.bounds);
    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:@"苍老师！"];
    //2 在核心文字你不使用的NSString，而是NSAttributedString，如下图所示。NSAttributedString是一个非常强大的NSString衍生类，它允许你申请的格式属性的文本。就目前而言，我们不会使用格式 - 这里只是创建了一个纯文本字符串。
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    //3 CTFramesetter当采用CoreText绘制文本最重要的一个类，它管理你的字体引用和你的文本绘制框架。就目前而言，你需要知道的是，CTFramesetterCreateWithAttributedString为您创建一个CTFramesetter，保留它，并用附带的属性字符串初始化它。在这部分中，之后使用CTFramesetterCreateFrame得到frame用framesetter和path，（我们选择整个字符串在这里），并在绘制时，文字会出现在矩形
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attString.length), path, NULL);
    CTFrameDraw(frame, ref);
    //4 CTFrameDraw在提供的大小在给定上下文后绘制，苍老师5. 最后，所有使用的对象被释放请注意，您使用一套像CTFramesetterCreateWithAttributedString和CTFramesetterCreateFrame功能，而不是直接使用Objective-C对象CoreText类时。你可能会认为自己“为什么我会要再次使用C，我认为我应该用Objective-C去完成？”好了，很多iOS上的底层库中都在使用标准C，因为速度和简单。不过别担心，你会发现CoreText函数很容易。只是一个要记住最重要的一点：不要忘记使用CFRelease释放内存。不管你信不信，这就是你使用CoreText绘制一些简单的文本
    CFRelease(framesetter);
    //5
    CFRelease(path);
    CFRelease(frame);
    
}


@end
