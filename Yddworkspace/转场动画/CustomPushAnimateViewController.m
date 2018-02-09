//
//  CustomPushAnimateViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/22.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "CustomPushAnimateViewController.h"
#import "CustomTransitionPushControlle.h"
#import "CustomPopAnimateViewController.h"

@interface CustomPushAnimateViewController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *btnArr;

@end

@implementation CustomPushAnimateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor whiteColor];
    [self addButton];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.delegate = self;
    
    [self setupButtonAnimation];
}


- (void)addButton{
    
    self.btnArr = [NSMutableArray array];
    
    CGFloat margin=50;
    CGFloat width=(self.view.frame.size.width-margin*3)/2;
    CGFloat height = width;
    CGFloat x = 0;
    CGFloat y = 0;
    //列
    NSInteger col = 2;
    for (NSInteger i = 0; i < 4; i ++) {
        
        x = margin + (i%col)*(margin+width);
        y = margin + (i/col)*(margin+height) + 150;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, y, width, height);
        button.layer.cornerRadius = width * 0.5;
        [button addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1.0];
        button.tag = i+1;
        [self.view addSubview:button];
        [self.btnArr addObject:button];
    }
    
}
/*
 CAKeyframeAnimation
 timeFunctions属性
 这是一个数组，你有几个子路径就应该传入几个元素,
 用以指定时间函数，类似于运动的加速度，有以下几种类型。
 1 kCAMediaTimingFunctionLinear//线性
 2 kCAMediaTimingFunctionEaseIn//淡入
 3 kCAMediaTimingFunctionEaseOut//淡出
 4 kCAMediaTimingFunctionEaseInEaseOut//淡入淡出
 5 kCAMediaTimingFunctionDefault//默认
 
 ************************************************
 ************************************************
 
 calculationMode属性
 该属性决定了物体在每个子路径下是跳着走还是匀速走，跟timeFunctions属性有点类似
 1 const kCAAnimationLinear//线性，默认
 2 const kCAAnimationDiscrete//离散，无中间过程，但keyTimes设置的时间依旧生效，物体跳跃地出现在各个关键帧上
 3 const kCAAnimationPaced//平均，keyTimes跟timeFunctions失效
 4 const kCAAnimationCubic//平均，同上
 5 const kCAAnimationCubicPaced//平均，同上
 */
- (void)setupButtonAnimation{
    
    [self.btnArr enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // positionAnimation
        CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        positionAnimation.calculationMode = kCAAnimationPaced;
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.repeatCount = MAXFLOAT;
        positionAnimation.autoreverses = YES;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.duration = (idx == self.btnArr.count - 1) ? 4 : 5+idx;
        
        UIBezierPath *positionPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(button.frame, button.frame.size.width/2-5, button.frame.size.height/2-5)];
        //指定整个动画所经过的路径的。需要注意的是，values与path是互斥的，当values与path同时指定 时，path会覆盖values，即values属性将被忽略。
        positionAnimation.path = positionPath.CGPath;
        [button.layer addAnimation:positionAnimation forKey:nil];
        
        // scaleXAniamtion
        CAKeyframeAnimation *scaleXAniamtion = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
        //设定关键帧位置，必须含起始与终止位置
        scaleXAniamtion.values = @[@1.0,@1.1,@1.0];
        //设定每个关键帧的时长，如果没有显式地设置，则默认每个帧的时间=总duration/(values.count - 1),首尾必须分别是0和1
        scaleXAniamtion.keyTimes = @[@0.0,@0.5,@1.0];
        scaleXAniamtion.repeatCount = MAXFLOAT;
        scaleXAniamtion.autoreverses = YES;
        scaleXAniamtion.duration = 4+idx;
        [button.layer addAnimation:scaleXAniamtion forKey:nil];
        
        // scaleYAniamtion
        CAKeyframeAnimation *scaleYAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
        scaleYAnimation.values = @[@1,@1.1,@1.0];
        scaleYAnimation.keyTimes = @[@0.0,@0.5,@1.0];
        scaleYAnimation.autoreverses = YES;
        scaleYAnimation.repeatCount = YES;
        scaleYAnimation.duration = 4+idx;
        [button.layer addAnimation:scaleYAnimation forKey:nil];
        
    }];
}


- (void)btnclick:(UIButton *)btn
{
    self.button=btn;
    CustomPopAnimateViewController *push=[CustomPopAnimateViewController new];
    push.image=[UIImage imageNamed:[NSString stringWithFormat:@"%lu",btn.tag]];
    [self.navigationController pushViewController:push animated:YES];
}


/**
 用来自定义转场动画
 要返回一个准守UIViewControllerInteractiveTransitioning协议的对象,并在里面实现动画即可
  1.创建继承自 NSObject 并且声明 UIViewControllerAnimatedTransitioning 的的动画类。
  2.重载 UIViewControllerAnimatedTransitioning 中的协议方法。
 */
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0);
{
    if (operation == UINavigationControllerOperationPush) {
        return [CustomTransitionPushControlle new];
    }else{
        return nil;
    }
}

/**
 为这个动画添加用户交互
 */

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController NS_AVAILABLE_IOS(7_0);
{
    return nil;
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
