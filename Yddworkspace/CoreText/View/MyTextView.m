//
//  MyTextView.m
//  Yddworkspace
//
//  Created by ispeak on 2017/1/5.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MyTextView.h"
#import <CoreText/CoreText.h>
#import "MyAttributedString.h"

@interface MyTextView()

@property (nonatomic, assign) CGRect imgFrame;
@property (nonatomic, assign) CTFrameRef frameRef;

@property (nonatomic, strong) NSMutableAttributedString *allAttString;


@end

@implementation MyTextView

/*
ref既是创建代理是绑定的对象。所以我们在这里，从字典中分别取出图片的宽和高。

值得注意的是，由于是c的方法，所以也没有什么对象的概念。是一个指针类型的数据。不过oc的对象其实也就是c的结构体。我们可以通过类型转换获得oc中的字典。
__bridge既是C的结构体转换成OC对象时需要的一个修饰词。

作者：老司机Wicky
链接：http://www.jianshu.com/p/6db3289fb05d
來源：简书
*/

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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    // Drawing code
    //步骤1：得到当前用于绘制画布的上下文，用于后续将内容绘制在画布上
    // 因为Core Text要配合Core Graphic 配合使用的，如Core Graphic一样，绘图的时候需要获得当前的上下文进行绘制
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    //文字添加阴影
    CGContextSetShadowWithColor(contextRef, CGSizeMake(0.3, 0.3), 0.3,  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor);
    
    // 步骤2：翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕左下角为（0，0））
    
    //（1）设置字形的变换矩阵为不做如行变换
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    // (2)平移方法，将画布向上平移一个屏幕高
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    
    // (3)缩放方法，x 轴缩放系数为1， 则不变， y轴缩放系数为-1， 则相当于以x轴为旋转轴转180度
    CGContextScaleCTM(contextRef, 1.0, -1.0);
//    coreText使用的是系统坐标，坐标原点在左下角，y轴正方向向上，与iOS屏幕坐标系相反（屏幕坐标系坐标原点在左上角）。
//    事实上呢，(1)(2)(3)三句是翻转画布的固定写法，这三句你以后会经常看到的。
    
    //步骤3 设置内容富文本
    
    //1 在核心文字你不使用的NSString，而是NSAttributedString，如下图所示。NSAttributedString是一个非常强大的NSString衍生类，它允许你申请的格式属性的文本。就目前而言，我们不会使用格式 - 这里只是创建了一个纯文本字符串。
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:_currentText];

    // 步骤4 图片的代理的设置
    // 事实上，图文混排就是在要插入图片的位置插入一个富文本类型的占位符。通过CTRUNDelegate设置图片
    // 设置一个回调结构体，告诉代理该回调那些方法
    CTRunDelegateCallbacks callBacks; //创建一个回调结构体， 设置相关参数
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks)); //memset将已开辟内存空间 callbacks 的首 n 个字节的值设为值 0, 相当于对CTRunDelegateCallbacks内存空间初始化
    callBacks.version = kCTRunDelegateVersion1;//设置回调版本，默认这个
    callBacks.getAscent = ascentCallBacks;//设置图片顶部距离基线的距离
    callBacks.getDescent = descentCallBacks;//设置图片底部距离基线的距离
    callBacks.getWidth = widthCallBacks;//设置图片宽
    
    NSDictionary *dicPic = @{@"height":@100, @"width":@100};//创建一个图片尺寸的字典，初始化代理对象需要
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callBacks, (__bridge void *) dicPic);//创建代理
    // 步骤 5 图片的插入
    //首先创建一个富文本类型的图片占位符，绑定我们的代理
   // unichar placeHolder = 0xFFCC;//创建空白字符
//    NSString *placeHolderStr = [NSString stringWithCharacters:&placeHolder length:1];//以空白字符生成字符串
    NSMutableAttributedString *placeHolderAttrStr = [[NSMutableAttributedString alloc] initWithString:@" "];//用字符串初始化占位符的富文本
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeHolderAttrStr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);//给字符串中的范围中字符串设置代理
    CFRelease(delegate);//释放（__bridge进行C与OC数据类型的转换，C为非ARC，需要手动管理）
    
    [attString insertAttributedString:placeHolderAttrStr atIndex:100];//将占位符插入原富文本

    // 步骤6 绘制文本
    //3 CTFramesetter当采用CoreText绘制文本最重要的一个类，它管理你的字体引用和你的文本绘制框架。就目前而言，你需要知道的是，CTFramesetterCreateWithAttributedString为您创建一个CTFramesetter，保留它，并用附带的属性字符串初始化它。在这部分中，之后使用CTFramesetterCreateFrame得到frame用framesetter和path，（我们选择整个字符串在这里），并在绘制时，文字会出现在矩形
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);//一个frame的工厂，负责生成frame
    
    
/*
    // 绘制图形路径
    //1.b画一个圆
    //1.b.1创建一条画圆的绘图路径(注意这里是可变的，不是CGPathRef)
    //1.b.2把圆的绘图信息添加到路径里
    //    CGPathAddEllipseInRect(path, NULL, self.bounds);

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
    //3 在这里，你需要创建一个边界，在区域的路径中您将绘制文本。（就是说我给你指定一个帐号，你必需给指定帐号汇钱）。在Mac和iOS上CoreText支持不同的形状，如矩形和圆。在这个简单的例子中，您将使用整个视图范围为在那里您将通过创建从self.bounds一个CGPath参考绘制矩形。
    CGMutablePathRef path = CGPathCreateMutable();//创建绘制区域
//    CGPathAddRect(path, NULL, CGRectMake(20, 20, self.frame.size.width - 40, self.frame.size.width - 40));//添加绘制尺寸
    CGPathAddEllipseInRect(path, NULL,  CGRectMake(20, 20, self.frame.size.width - 40, self.frame.size.width - 40));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attString.length), path, NULL);//工厂根据绘制区域及富文本（可选范围，多次设置）设置frame
    self.frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attString.length), path, NULL);//保存frame
    _allAttString = [[NSMutableAttributedString alloc] initWithAttributedString:attString]; //保存所有文本字符（包含图片）
    //4 CTFrameDraw在提供的大小在给定上下文后绘制，苍老师
    CTFrameDraw(frame, contextRef);//根据frame绘制文字
    /*
    frameSetter是根据富文本生成的一个frame生成的工厂，你可以通过framesetter以及你想要绘制的富文本的范围获取该CTRun的frame。
    但是你需要注意的是，获取的frame是仅绘制你所需要的那部分富文本的frame。即当前情况下，你绘制范围定为（10，1），那么你得到的尺寸是只绘制（10，1）的尺寸，他应该从屏幕左上角开始（因为你改变了坐标系），而不是当你绘制全部富文本时他该在的位置。
     */
    
    // 步骤7 绘制图片
    

    CGRect imgFrame = [self calculateImageRectWithFrame:frame];
    CGContextDrawImage(contextRef, imgFrame, self.image.CGImage);//绘制图片
    //5. 最后，所有使用的对象被释放请注意，您使用一套像CTFramesetterCreateWithAttributedString和CTFramesetterCreateFrame功能，而不是直接使用Objective-C对象CoreText类时。你可能会认为自己“为什么我会要再次使用C，我认为我应该用Objective-C去完成？”好了，很多iOS上的底层库中都在使用标准C，因为速度和简单。不过别担心，你会发现CoreText函数很容易。只是一个要记住最重要的一点：不要忘记使用CFRelease释放内存。不管你信不信，这就是你使用CoreText绘制一些简单的文本
    CFRelease(framesetter);
    //5
    CFRelease(path);
    CFRelease(frame);
    
}

//frame 的获取
//1.将代码分离，方便修改。
//2.最主要的是这部分代码到哪里都能用，达到复用效果。
/*
CTLine 可以看做Core Text绘制中的一行的对象 通过它可以获得当前行的line ascent,line descent ,line leading,还可以获得Line下的所有Glyph Runs
CTRun 或者叫做 Glyph Run，是一组属性相同attributes（属性）的字形的集合体
一个CTFrame有几个CTLine组成，有几行文字就有几行CTLine。一个CTLine有包含多个CTRun，一个CTRun是所有属性都相同的那部分富文本的绘制单元。所以CTRun是CTFrame的基本绘制单元
*/

- (CGRect)calculateImageRectWithFrame:(CTFrameRef)frame
{
    NSArray *arrlines = (NSArray *)CTFrameGetLines(frame);//根据frame获取需要绘制的线的数组
    NSInteger count = [arrlines count];//获取线的数量
    CGPoint points[count];//建立起点的数组（cgpoint类型为结构体，故用C语言的数组）
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);//获取起点
    
    //计算frame  思路：就是遍历我们的frame中的所有CTRun，检查他是不是我们绑定图片的那个，如果是，根据该CTRun所在CTLine的origin以及CTRun在CTLine中的横向偏移量计算出CTRun的原点，加上其尺寸即为该CTRun的尺寸。
    for (int i = 0; i < count; i++) {//遍历线的数组
        CTLineRef line = (__bridge CTLineRef)arrlines[i];
        NSArray *arrGlyphRun = (NSArray *)CTLineGetGlyphRuns(line);//获取GlyphRun数组（GlyphRun：高效的字符绘制方案）
        for (int j = 0; j < arrGlyphRun.count; j++) {//遍历CTRun数组
            CTRunRef run = (__bridge CTRunRef)arrGlyphRun[j];//获取CTRun
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);//获取CTRun的属性
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];//获取代理
            if (delegate == nil) {
                continue;
            }
            NSDictionary *dic = CTRunDelegateGetRefCon(delegate);//判断代理字典
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGPoint point = points[i];//获取一个起点
            CGFloat ascent;//获取上距
            CGFloat descent;//获取下距
            CGRect boundsRun;//创建一个frame
            boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            boundsRun.size.height = ascent + descent;//取得高
            CGFloat xoffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);//获取x偏移量
            boundsRun.origin.x = point.x + xoffset;//point是行起点位置，加上每个字的偏移量得到每个字的x
            boundsRun.origin.y = point.y - descent;//计算原点
            CGPathRef path = CTFrameGetPath(frame);//获取绘制区域
            
            
            CGRect colRect = CGPathGetBoundingBox(path);//获取剪裁区域边框
            CGRect imageBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);
            _imgFrame = imageBounds;
            return imageBounds;
        }
    }
    return CGRectZero;
}

//点击方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [self systemPointFromScreenPoint:[touch locationInView:self]]; //获取点击位置的系统坐标
    if ([self checkIsClickOnImgWithPoint:location]) { //检查是否点击在图片上，如果是，有限响应图片点击事件
        NSLog(@"点击图片");
        return;
    }
    [self clickOnStrWithPoint:location];//响应字符串事件
}

//坐标转换
/*
 将屏幕坐标转换为系统坐标
 */
- (CGPoint)systemPointFromScreenPoint:(CGPoint)origin
{
    return CGPointMake(origin.x, self.bounds.size.height - origin.y);
}

//图片点击检查
/*
 遍历图片frame的数组与点击位置比较，如果在范围内则从响应的数组中取出对应响应并执行，返回YES，否则返回NO
 */
- (BOOL)checkIsClickOnImgWithPoint:(CGPoint)point {
    if ([self isFrame:_imgFrame containsPoint:point]) {
        return YES;
    }
    return NO;
}
//点包含检测
- (BOOL)isFrame:(CGRect)frame containsPoint:(CGPoint)point
{
    return CGRectContainsPoint(frame, point);
}

//字符串点击检测
/*
 实际上接受所有非图片的点击事件，将字符串的每个字符取出与点击位置比较， 若在范围内则点击到文字，进而检测对应的文字是否响应事件，若存在则响应
 */

- (void)clickOnStrWithPoint:(CGPoint)location
{
    NSArray *lines = (NSArray *)CTFrameGetLines(_frameRef);//获取所有CTLine
    CFRange ranges[lines.count]; //初始化范围数组
    CGPoint origins[lines.count]; //初始化原点数组
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), origins);//获取所有CTLine的原点
    for (int i = 0;  i < lines.count; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        CFRange range = CTLineGetStringRange(line);
        ranges[i] = range;//获取每一行的范围
    } //获取所有CTLine的Range
    for (int i = 0; i < _allAttString.length; i++) { //逐子检测
        long maxLoc;
        int lineNum = 0;
        for (int j = 0; j < lines.count; j++) {//获取对应字符所在CTLine的index
            CFRange range = ranges[j];
            maxLoc = range.location + range.length - 1;
            NSLog(@"maxLoc = %ld", maxLoc);
            if (i <= maxLoc) {
                lineNum = j; //获取第i个字符在第j行
                break;
            }
        }
        CTLineRef line = (__bridge CTLineRef)lines[lineNum];//取到字符对应的CTLine
        CGPoint origin = origins[lineNum];
        CGRect CTRunFrame = [self frameForCTRunWithIndex:i CTLine:line origin:origin];//计算对应字符的frame
        if ([self isFrame:CTRunFrame containsPoint:location]) {// 如果点击位置在字符串范围内，响应事件，跳出循环
            NSAttributedString *attStr = [_allAttString attributedSubstringFromRange:NSMakeRange(i, 1)];
             NSLog(@"您点击到了第 %d 个字符，位于第 %d 行，字符为 %@。",i,lineNum + 1, attStr.string);//点击到文字，然而没有响应的处理。可以做其他处理
            return;
        }
    }
    NSLog(@"您没有点击到文字");//没有点击到文字，可以做其他处理
}

//字符frame计算
/*
 返回索引字符所在CTLine
 index:索引，字符在所有文本中的位置，
 line:索引字符所在CTLine
 origin： line的起点 、
 */
- (CGRect)frameForCTRunWithIndex:(NSInteger)index CTLine:(CTLineRef)line origin:(CGPoint)origin
{
    CGFloat offsetX = CTLineGetOffsetForStringIndex(line, index, NULL);//获取字符起点相对于CTLine的原点偏移量
    CGFloat offsexX2 = CTLineGetOffsetForStringIndex(line, index + 1, NULL);//获取下一个字符的偏移量，两者之间即为字符X范围
    offsetX += origin.x;
    offsexX2 += origin.x;//坐标转换，将点的CTLine坐标转换至系统坐标
    CGFloat offsetY = origin.y;//取到CTLine的起点Y
    CGFloat lineAscent;//初始化上下边距的变量
    CGFloat lineDescent;
    NSArray * runs = (__bridge NSArray *)CTLineGetGlyphRuns(line);//获取所有CTRun
    CTRunRef runCurrent;
    for (int k = 0; k < runs.count; k ++) {//获取当前点击的CTRun
        CTRunRef run = (__bridge CTRunRef)runs[k];
        CFRange range = CTRunGetStringRange(run);
        NSRange rangeOC = NSMakeRange(range.location, range.length);
        if ([self isIndex:index inRange:rangeOC]) {
            runCurrent = run;
            break;
        }
    }
    CTRunGetTypographicBounds(runCurrent, CFRangeMake(0, 0), &lineAscent, &lineDescent, NULL);//计算当前点击的CTRun高度
    offsetY -= lineDescent;
    CGFloat height = lineAscent + lineDescent;
    return CGRectMake(offsetX, offsetY, offsexX2 - offsetX, height);//返回一个字符的Frame
}

///范围检测
/*
 范围内返回yes，否则返回no
 */
-(BOOL)isIndex:(NSInteger)index inRange:(NSRange)range
{
    if ((index <= range.location + range.length - 1) && (index >= range.location)) {
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    CFRelease(_frameRef);
    NSLog(@"mytextview dealloc");
}


@end
