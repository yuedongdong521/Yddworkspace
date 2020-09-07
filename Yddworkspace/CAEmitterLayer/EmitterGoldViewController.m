//
//  EmitterGoldViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/3/18.
//  Copyright © 2020 QH. All rights reserved.
//

#import "EmitterGoldViewController.h"

@interface EmitterGoldViewController ()

@property (nonatomic, strong) CAEmitterLayer *emitterLayer;

@end

@implementation EmitterGoldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
       dispatch_get_main_queue(), ^{
        [self sendCombinationAnimation];
      
    });
    
}


// 例如下新年节日组合的福袋、彩带、元宝等（全屏）
- (void)sendCombinationAnimation
{
    // 初始化粒子动画Layer对象
    CAEmitterLayer* emitterLayer = [CAEmitterLayer layer];
    // 发射源坐标
    emitterLayer.emitterPosition = CGPointMake(ScreenWidth / 2, -70);
    emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    // 发射源size
    emitterLayer.emitterSize = CGSizeMake(100, 50);
    // 渲染方式
    emitterLayer.renderMode = kCAEmitterLayerLine;
    self.emitterLayer = emitterLayer;
    [self.view.layer addSublayer:self.emitterLayer];
    //
    NSMutableArray *mtbArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 30; i++) {
        UIImage *giftimage = [UIImage imageNamed:@"snow"];
        // 初始化粒子单元
        CAEmitterCell* emitterCell = [CAEmitterCell emitterCell];
        emitterCell.name = [NSString stringWithFormat:@"%d", i];
        // 粒子的生产率
        emitterCell.birthRate = 0.0;
        // cell的生命周期
        emitterCell.lifetime = 4.0;
        // cell的内容
        emitterCell.contents = (id)giftimage.CGImage;
        emitterCell.yAcceleration = 70.0;  // 给Y方向一个加速度70
        emitterCell.xAcceleration = 20.0;  // x方向一个加速度20
        emitterCell.velocity = 20.0;  // 初始速度
        emitterCell.emissionLongitude = -M_PI;  // 向左
        emitterCell.velocityRange = 200.0;  // 随机速度 -200+20 --- 200+20
        emitterCell.emissionRange = M_PI_2;  // 随机方向 -pi/2 --- pi/2
        // emitterCell.color = UIColor(red: 0.9, green: 1.0, blue: 1.0,alpha: 1.0).CGColor // 指定颜色
        emitterCell.scale = 0.5;
        emitterCell.scaleRange = 0.5;  // 0 - 1.6
        emitterCell.scaleSpeed = -0.1;  // 逐渐变小
        emitterCell.alphaRange = 0.9;  // 随机透明度
        emitterCell.alphaSpeed = -0.1;  // 逐渐消失
        // emitterCell.spin = 0.5; // 自旋转速度
        // emitterCell.spinRange = M_PI;  // slow spin
        //
        [mtbArray addObject:emitterCell];
        
                CABasicAnimation* snowBurst =
                [CABasicAnimation animationWithKeyPath:[NSString stringWithFormat:@"emitterCells.%d.birthRate",i]];
                snowBurst.fromValue = [NSNumber numberWithFloat:2];
                snowBurst.toValue = [NSNumber numberWithFloat:0.0];
                snowBurst.duration = 4.0;
                snowBurst.timingFunction =
                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                snowBurst.removedOnCompletion = YES;
        
//        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:[NSString stringWithFormat:@"emitterCell.%d.position", i]];
//        // 设置动画的路径为心形路径
//
//        CGFloat x = 100;
//        if (i < 10) {
//            x = 100 + arc4random() % 50;
//        } else {
//            x = 150 + arc4random() % 50;
//        }
//        CGRect itemFrame = CGRectMake(x, 400, 15, 15);
//        CGFloat endX = 0;
//        CGFloat midX = 0;
//        if (x > 150) {
//            endX = arc4random() % ((int)ScreenWidth - 150) + 150;
//        } else {
//            endX = arc4random() % 150;
//        }
//
//        CGFloat centerX = CGRectGetMidX(itemFrame);
//        if (centerX < endX) {
//            midX = (endX - centerX) * 0.5 + centerX;
//        } else {
//            midX = (centerX - endX) * 0.5 + endX;
//        }
//
//        UIBezierPath *path = [self pathWithStartPoint:CGPointMake(centerX, CGRectGetMidY(itemFrame)) midPoint:CGPointMake(midX, arc4random() % 100) endPoint:CGPointMake(endX, ScreenHeight)];
//        animation.path = path.CGPath;
//        // 动画时间间隔
//        animation.duration = 2.0f;
//        animation.speed = 2;
//        // 重复次数为最大值
//        animation.repeatCount = FLT_MAX;
//        animation.removedOnCompletion = YES;
//        animation.fillMode = kCAFillModeForwards;
//        animation.timingFunction =
//        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//
        [emitterLayer addAnimation:snowBurst forKey:[NSString stringWithFormat:@"%d", i]];
    }
    emitterLayer.emitterCells = mtbArray;
    
}

- (UIBezierPath *)pathWithStartPoint:(CGPoint)startPoint
                            midPoint:(CGPoint)midPoint
                            endPoint:(CGPoint)endPoint
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:midPoint];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    return path;
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
