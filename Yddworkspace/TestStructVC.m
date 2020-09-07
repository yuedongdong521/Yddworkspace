//
//  TestStructVC.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/30.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TestStructVC.h"
#import "UILabel+YDDExtend.h"


typedef struct model Model;

struct model {
    int a;
    int b;
    void (^testAction)(const Model *model);
};



@interface TestStructVC ()<CAAnimationDelegate>

@property (nonatomic, strong) NSString *blockStr;
@property (nonatomic, strong) CAGradientLayer *gradLayer;
@end

@implementation TestStructVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSArray *array = @[NSStringFromSelector(@selector(test1)),
                       NSStringFromSelector(@selector(test2))];
    NSMutableArray <UIButton *>*btnArr = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button addTarget:self action:NSSelectorFromString(array[i]) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor cyanColor];
        [self.view addSubview:button];
        [btnArr addObject:button];
    }
    [btnArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:20 tailSpacing:20];
    [btnArr enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(kNavBarHeight + 20);
        }];
    }];
    
    
    [self testMaskLayer];
    
    
}

- (void)testMaskLayer
{
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.frame = CGRectMake(20, 200, 200, 300);
    //    label.layer.backgroundColor = [UIColor whiteColor].CGColor;
    label.text = @"景甜爱很简单，就是天天带你飞, 此刻的精彩，愿与你一起共享！";
    
    
    CAGradientLayer *layer = [[CAGradientLayer alloc] init];
    layer.frame = CGRectMake(20, 200, 200, 50);
    layer.colors = @[(__bridge id)[UIColor greenColor].CGColor, (__bridge id)[UIColor blueColor].CGColor,(__bridge id)[UIColor redColor].CGColor];
    layer.startPoint = CGPointMake(0, 1);
    layer.endPoint = CGPointMake(1, 1);
    layer.locations = @[@(0), @(0.5), @(1)];
    
    [self.view addSubview:label];
    [self.view.layer addSublayer:layer];
    
    layer.mask = label.layer;
    label.frame = layer.bounds;
    
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(20, 300, 100, 50);
    [self.view addSubview:label2];
    label2.text = @"景甜爱很简单";
    [label2 setFontGradColors:@[[UIColor greenColor], [UIColor redColor], [UIColor greenColor]]];
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(20, 400, 100, 50);
    [self.view addSubview:label3];
    label3.text = @"景甜爱很简单";
    
    label3.fontGradLayer = layer;
    
    
    UILabel *label4= [[UILabel alloc] init];
    label4.frame = CGRectMake(20, 500, 200, 50);
    label4.textColor = UIColorHexRGBA(0x00ff00, 0.5);
    //    label4.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self.view addSubview:label4];
    label4.text = @"景甜爱很简单,景甜爱很简单";
    
    CAShapeLayer *layer4 = [CAShapeLayer layer];
    layer4.frame = CGRectMake(0, 0, 50, 50);
    
    //    layer4.backgroundColor = UIColorHexRGBA(0xffffff, 1).CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 50, 50)];
    [path moveToPoint:CGPointMake(25, 0)];
    [path addLineToPoint:CGPointMake(50, 0)];
    [path addLineToPoint:CGPointMake(25, 50)];
    [path addLineToPoint:CGPointMake(0, 50)];
    //    [path addLineToPoint:CGPointMake(25, 0)];
    [path closePath];
    [path stroke];
    layer4.path = path.CGPath;
    layer4.fillColor = UIColorHexRGBA(0xff0000, 1).CGColor;

    layer4.strokeColor = [UIColor clearColor].CGColor;

    
    
    CAShapeLayer *layer5 = [CAShapeLayer layer];
    layer5.frame = label4.bounds;
    
    layer5.backgroundColor = UIColorHexRGBA(0x00ff00, 0.5).CGColor;
  
    layer5.mask = layer4;
    
    [label4.layer addSublayer:layer5];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.fromValue = @[@(0)];
    animation.toValue = @[@(label4.frame.size.width)];
    animation.duration = 1;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [layer5 addAnimation:animation forKey:@"AnimationMoveX"];
    
    
    UILabel *label5 = [UILabel labelWithFont:[UIFont systemFontOfSize:20] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter];
    
    label5.text = @"第一序列";
    [self.view addSubview:label5];
    
    [label5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.equalTo(self.view.mas_centerY);
        make.height.mas_equalTo(40);
    }];
    
    label5.fontGradLayer = layer;
    
    
    
}

- (void)animationStart
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.gradLayer.transform = CATransform3DMakeTranslation(200, 0, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            self.gradLayer.transform = CATransform3DMakeTranslation(-200, 0, 0);
            [self animationStart];
        }
    }];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    NSLog(@"animationDidStart");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"animationDidStop: flag = %d", flag);
}



- (void)test1
{
    _blockStr = @"1";
    __weak typeof(self) weakself = self;
    
    struct model model = {1, 2};
    for (int i = 0; i < 2; i++) {
        model.a = i;
        NSLog(@"model a = %d", model.a);
        [[self class] testStr:_blockStr block:^(NSString *str) {
            NSLog(@"str : %@, blockStr: %@, model.a : %d", str, weakself.blockStr, model.a);
        }];
    }
    model.a = 3;
    
    _blockStr = @"2";
}

- (void)test2
{
    void (^block)(const Model *model) = ^(const Model *model) {
        NSLog(@"Modle 地址: %p", model);
    };
    Model model = {1, 2, block};

    Model model1 = model;
    Model *model2 = &model;
    model.testAction = nil;
    if (model1.testAction) {
        model1.testAction(&model1);
    }
    if (model2->testAction) {
        model2->testAction(model2);
    }
    
    
    NSLog(@"%p, %p, %p ", &model, &model1, model2);
    
}

+ (void)testStr:(NSString *)str block:(void(^)(NSString * str))blcok
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            blcok(str);
        });
    });
}

- (void)dealloc
{
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
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
