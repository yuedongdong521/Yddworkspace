//
//  BezierPathViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/7/7.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "BezierPathViewController.h"

@interface BezierPathViewController ()

@property (nonatomic, strong) UIView *sinView;
@property (nonatomic, strong) UIBezierPath *sinPath;
@property (nonatomic, strong) CAShapeLayer *sinLayer;

@property (nonatomic, strong) UIView *cosView;
@property (nonatomic, strong) UIBezierPath *cosPath;
@property (nonatomic, strong) CAShapeLayer *cosLayer;

@property (nonatomic, strong) UIView *tanView;
@property (nonatomic, strong) UIBezierPath *tanPath;
@property (nonatomic, strong) CAShapeLayer *tanLayer;
@end

@implementation BezierPathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sinView = [self creatBezierPathViewWithFrame:CGRectMake(20, 80, 30 * 2 * M_PI, 60) WithBankgroundColor:[UIColor grayColor]];
    
    _cosView = [self creatBezierPathViewWithFrame:CGRectMake(20, 200, 30 * 2 * M_PI, 60) WithBankgroundColor:[UIColor grayColor]];
    
    _tanView = [self creatBezierPathViewWithFrame:CGRectMake(20, 300, 30 * 2 * M_PI, 60) WithBankgroundColor:[UIColor grayColor]];
    
    [self drawSinLayer];
    [self drawCosLayer];
    [self drawTanLayer];
}

- (UIView *)creatBezierPathViewWithFrame:(CGRect)frame WithBankgroundColor:(UIColor *)color
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = color;
    view.layer.masksToBounds = YES;
    [self.view addSubview:view];
    return view;
}

- (UIBezierPath *)drawSinPathForStartPoint:(CGPoint)startPoint ForA:(CGFloat)A ForWidth:(CGFloat)width ForType:(BezierPathType)type
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:startPoint];
    for (int i = 0; i < width; i++) {
        CGFloat y = 0;
        if (type == BezierPathType_sin) {
            y = A * sinf(i * 2 * M_PI / width) + A;
        } else if (type == BezierPathType_cos) {
            y = A * cosf(i * 2 * M_PI / width) + A;
        } else if (type == BezierPathType_tan) {
            y = A * tanf(i * 2 * M_PI / width) + A;
        }
        
        [bezierPath addLineToPoint:CGPointMake(i, y)];
    }
//    [bezierPath closePath];
    return bezierPath;
}

- (void)drawSinLayer
{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor cyanColor].CGColor;
    shapeLayer.shouldRasterize = YES;
    shapeLayer.frame = _sinView.bounds;
    shapeLayer.path = [self drawSinPathForStartPoint:CGPointMake(0, _sinView.frame.size.height / 2.0) ForA:_sinView.frame.size.height / 2.0 ForWidth:_sinView.frame.size.width ForType:BezierPathType_sin].CGPath;
    [_sinView.layer addSublayer:shapeLayer];
}

- (void)drawCosLayer
{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor cyanColor].CGColor;
    shapeLayer.shouldRasterize = YES;
    shapeLayer.frame = _cosView.bounds;
    shapeLayer.path = [self drawSinPathForStartPoint:CGPointMake(0, _cosView.frame.size.height / 2.0) ForA:_cosView.frame.size.height / 2.0 ForWidth:_cosView.frame.size.width ForType:BezierPathType_cos].CGPath;
    [_cosView.layer addSublayer:shapeLayer];
}

- (void)drawTanLayer
{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor cyanColor].CGColor;
    shapeLayer.shouldRasterize = YES;
    shapeLayer.frame = _tanView.bounds;
    shapeLayer.path = [self drawSinPathForStartPoint:CGPointMake(0, _tanView.frame.size.height / 2.0) ForA:_tanView.frame.size.height / 2.0 ForWidth:_tanView.frame.size.width ForType:BezierPathType_tan].CGPath;
    [_tanView.layer addSublayer:shapeLayer];
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
