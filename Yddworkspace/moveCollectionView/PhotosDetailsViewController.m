//
//  PhotosDetailsViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/24.
//  Copyright © 2019 QH. All rights reserved.
//

#import "PhotosDetailsViewController.h"
#import "YYWebImage.h"
#import "NSString+yddSubByte.h"
#import "CustomTransition.h"
#define kHeadImageHeight 300

@interface PhotosDetailsViewController ()<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *headImageView;

@property (nonatomic, strong) NSArray <NSString *>*list;

@end

@implementation PhotosDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.headImageView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    self.headImageView.frame = CGRectMake(0, 0, ScreenWidth, kHeadImageHeight);
    
    [_headImageView yy_setImageWithURL:_imageUrl options:YYWebImageOptionUseNSURLCache];
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = self.list[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.list[indexPath.row] getTextSizeWithMaxSize:CGSizeMake(ScreenWidth - 30, 1000) font:[UIFont systemFontOfSize:17]].height + 20;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    self.headImageView.frame = CGRectMake(0, 0, ScreenWidth, -offsetY);
}


- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        _tableView.contentInset = UIEdgeInsetsMake(kHeadImageHeight, 0, 0, 0);
    }
    return _tableView;
}

- (UIImageView *)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.clipsToBounds = YES;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImageView;
}

- (NSArray<NSString *> *)list
{
    if (!_list) {
        _list = @[@"Flutter 1.7 已经发布，Flutter 是一种新型的方式，用于创建高性能、跨平台的移动应用。Flutter 1.7 包含对 AndroidX 和更新的 Play Store 需求的支持，一些新的和增强的组件，以及针对客户报告的问题的 bug 修复。",
                  @"AndroidX 对新应用程序的支持：Flutter 现在支持使用 AndroidX 创建新的 Flutter 项目，这减少了与 Android 生态系统其他部分集成所需的工作，当创建项目时，可以添加 --androidx 标志，以确保生成的项目目标是新的支持库",
                  @"支持 Android 应用程序包和 64位 Android 应用程序：Flutter 1.7增加了对创建 Android 应用程序 Bundles 的支持，该应用程序 Bundles 针对的是单一提交的 64 位和 32 位应用程序",
                  @"新的小部件和框架增强：此版本提供了一个新的 RangeSlider 控件，允许在单个滑块上选择一个值的范围"
                  
                ];
    }
    return _list;
}

- (UIView *)transitionAnmateView
{
    return self.headImageView;
}
///**
// 为这个动画添加用户交互
// */
//- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController NS_AVAILABLE_IOS(7_0)
//{
//
//
//    return nil;
//}
//
///**
// 用来自定义转场动画
// 要返回一个准守UIViewControllerInteractiveTransitioning协议的对象,并在里面实现动画即可
// 1.创建继承自 NSObject 并且声明 UIViewControllerAnimatedTransitioning 的的动画类。
// 2.重载 UIViewControllerAnimatedTransitioning 中的协议方法。
// */
//- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                            animationControllerForOperation:(UINavigationControllerOperation)operation
//                                                         fromViewController:(UIViewController *)fromVC
//                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0)
//{
//    CustomTransition *transition = [[CustomTransition alloc] init];
//    if (operation == UINavigationControllerOperationPush) {
//        transition.animationStatus = AnimationStatus_push;
//        return transition;
//    } else {
//        transition.animationStatus = AnimationStatus_pop;
//        return transition;
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
