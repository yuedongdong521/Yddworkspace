//
//  GraffitiViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/2/7.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "GraffitiViewController.h"

typedef enum : NSUInteger {
    HBDrawingShapeCurve = 0,//曲线
    HBDrawingShapeLine,//直线
    HBDrawingShapeEllipse,//椭圆
    HBDrawingShapeRect,//矩形
} HBDrawingShapeType;

@interface TouchPath : NSObject

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat pathWidth;
@property (nonatomic, assign) NSInteger shapeType;

+(instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth;

@end

@implementation TouchPath

+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth
{
    TouchPath *path = [[TouchPath alloc] init];
    path.beginPoint = beginPoint;
    path.pathWidth = pathWidth;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = pathWidth;
    bezierPath.lineJoinStyle = kCGLineJoinRound;//线条终点处理
    bezierPath.lineCapStyle = kCGLineCapRound;  //线条拐角处理
    [bezierPath moveToPoint:beginPoint];
    path.bezierPath = bezierPath;
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = pathWidth;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.path = bezierPath.CGPath;
    path.shapeLayer = shapeLayer;
    
    
    return path;
}

//HBDrawingShapeCurve = 0,//曲线
//HBDrawingShapeLine,//直线
//HBDrawingShapeEllipse,//椭圆
//HBDrawingShapeRect,//矩形
- (void)pathLineToPoint:(CGPoint)movePoint WithType:(HBDrawingShapeType)shapeType
{
    //判断绘图类型
    _shapeType = shapeType;
    switch (shapeType) {
        case HBDrawingShapeCurve:
        {
            [self.bezierPath addLineToPoint:movePoint];
            [self.bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
        }
            break;
        case HBDrawingShapeLine:
        {
            self.bezierPath = [UIBezierPath bezierPath];
            self.bezierPath.lineCapStyle = kCGLineCapRound;
            self.bezierPath.lineJoinStyle = kCGLineJoinRound;
            self.bezierPath.lineWidth = self.pathWidth;
            [self.bezierPath moveToPoint:self.beginPoint];
            [self.bezierPath addLineToPoint:movePoint];
        }
            break;
        case HBDrawingShapeEllipse:
        {
            self.bezierPath = [UIBezierPath bezierPathWithRect:[self getRectWithStartPoint:self.beginPoint endPoint:movePoint]];
            self.bezierPath.lineCapStyle = kCGLineCapRound;
            self.bezierPath.lineJoinStyle = kCGLineJoinRound;
            self.bezierPath.lineWidth = self.pathWidth;
        }
            break;
        case HBDrawingShapeRect:
        {
            self.bezierPath = [UIBezierPath bezierPathWithOvalInRect:[self getRectWithStartPoint:self.beginPoint endPoint:movePoint]];
            self.bezierPath.lineCapStyle = kCGLineCapRound;
            self.bezierPath.lineJoinStyle = kCGLineJoinRound;
            self.bezierPath.lineWidth = self.pathWidth;
        }
            break;
        default:
            break;
    }
    self.shapeLayer.path = self.bezierPath.CGPath;
}

- (CGRect)getRectWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGPoint orignal = startPoint;
    if (startPoint.x > endPoint.x) {
        orignal = endPoint;
    }
    CGFloat width = fabs(startPoint.x - endPoint.x);
    CGFloat height = fabs(startPoint.y - endPoint.y);
    return CGRectMake(orignal.x , orignal.y , width, height);
}


@end


@interface GraffitiViewController ()
//涂鸦view
@property (nonatomic, strong)UIView *graffitiView;
@property (nonatomic, strong)NSMutableArray *mtbArray;
@end

@implementation GraffitiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    _graffitiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 100)];
    _graffitiView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_graffitiView];
    
    _mtbArray = [NSMutableArray array];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.graffitiView];
    
    TouchPath *path = [TouchPath pathToPoint:point pathWidth:5.0];
    path.shapeLayer.strokeColor = [UIColor redColor].CGColor;
    [self.mtbArray addObject:path];
    
    [self.graffitiView.layer addSublayer:path.shapeLayer];

    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:_graffitiView];
    TouchPath *path = [self.mtbArray lastObject];
    
    [path pathLineToPoint:point WithType:0];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
