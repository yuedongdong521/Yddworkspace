//
//  CustomTabBarController.m
//  TestThirdFrameworks
//
//  Created by ydd on 2019/6/26.
//  Copyright © 2019 ydd. All rights reserved.
//

#import "CustomTabBarController.h"
#import "ViewController.h"
#import "MainViewController.h"
#import "UIImage+ydd.h"

@interface CustomTabBar : UITabBar
@property (nonatomic, strong) UIButton *centerBtn;
@end

@implementation CustomTabBar


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.centerBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemW = screenWidth / 3.0;
    __block NSInteger index = 0;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (index == 1) {
                self.centerBtn.center = CGPointMake(screenWidth * 0.5, obj.center.y - 10);
                index++;
            }
            CGRect rect = obj.frame;
            rect.origin.x =  itemW * index;
            rect.size.width = itemW;
            obj.frame = rect;
            index++;
        }
    }];
    
    
}

- (UIButton *)centerBtn
{
    if (!_centerBtn) {
        _centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerBtn.layer.masksToBounds = YES;
        _centerBtn.layer.cornerRadius = 32;
        _centerBtn.frame = CGRectMake(0, 0, 64, 64);
        _centerBtn.imageEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
        [_centerBtn setBackgroundImage:[UIImage imageNamed:@"0.jpg"] forState:UIControlStateNormal];
        [_centerBtn setBackgroundImage:[UIImage imageNamed:@"1.jpg"] forState:UIControlStateSelected];
        
    }
    return _centerBtn;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.isHidden) {
        if (CGRectContainsPoint(self.centerBtn.frame, point)) {
            return self.centerBtn;
        }
    }
    return [super hitTest:point withEvent:event];
}


@end


static CustomTabBarController *_tabBar;

@interface CustomTabBarController ()



@end

@implementation CustomTabBarController


+ (instancetype)shareTabBar
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tabBar = [[CustomTabBarController alloc] init];
    });
    return _tabBar;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        CustomTabBar *customTabBar = [[CustomTabBar alloc] init];
        [customTabBar.centerBtn addTarget:self action:@selector(centerAction:) forControlEvents:UIControlEventTouchUpInside];
   
        [self setValue:customTabBar forKey:@"tabBar"];
        
        ViewController *homeVC = [[ViewController alloc] init];
         MainViewController *settingVC = [[MainViewController alloc] init];
        UIImage *image = [UIImage imageNamed:@"0.jpg"];
        UIImage *selectedImage = [UIImage imageNamed:@"1yasuo.jpg"];
        image = [image scallImageWidthScallSize:CGSizeMake(20, 20)];
        selectedImage = [selectedImage scallImageWidthScallSize:CGSizeMake(20, 20)];
        
        [self addChildVc:homeVC title:@"首页" normalImg:image selectImg:selectedImage];

        [self addChildVc:settingVC title:@"设置" normalImg:image selectImg:selectedImage];
        
        [self setViewControllers:@[homeVC, settingVC]];
        
    }
    return self;
}




- (void)centerAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    NSLog(@"tabBar conter clicked");
    
}



- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title normalImg:(UIImage *)normalImg selectImg:(UIImage *)selectImg
{
    childVc.tabBarItem.image =  [normalImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = [selectImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.title = title;
    [childVc.tabBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor blackColor]} forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor redColor]} forState:UIControlStateSelected];
    childVc.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -4);
    childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
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
