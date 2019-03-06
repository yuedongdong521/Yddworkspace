//
//  PageViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/11.
//  Copyright © 2019 QH. All rights reserved.
//

#import "PageViewController.h"
#import "MyPageItemViewController.h"

@interface PageViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSMutableArray *controllerArray;

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor whiteColor];
  
  [self addChildViewController:self.pageViewController];
  [self.view addSubview:self.pageViewController.view];
  
  
}

#pragma mark UIPageViewControllerDelegate & UIPageViewControllerDataSource {
#pragma mark 返回上一个 ViewController
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
  if (![viewController isKindOfClass:[MyPageItemViewController class]]) {
    return nil;
  }
  MyPageItemViewController *itemViewController = (MyPageItemViewController *)viewController;
  NSUInteger index = itemViewController.index;
  if (index == 0 || index == NSNotFound) {
    return nil;
  }
  index--;
  if (index >= self.controllerArray.count) {
    return nil;
  }
  // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
  // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法,自动来维护次序
  // 不用我们去操心每个ViewController的顺序问题
  return self.controllerArray[index];
}
#pragma mark 返回下一个 ViewController
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
  if (![viewController isKindOfClass:[MyPageItemViewController class]]) {
    return nil;
  }
  MyPageItemViewController *itemViewController = (MyPageItemViewController *)viewController;
  NSUInteger index = itemViewController.index;
  if (index == NSNotFound) {
    return nil;
  }
  index++;
  if (index >= self.controllerArray.count) {
    return nil;
  }
  NSLog(@"next viewController index = %lu", (unsigned long)index);
  return self.controllerArray[index];
}
// pageViewController 开始滚动或者翻页时触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
  
}
// pageViewController 滚动或者翻页结束时触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
  
}
/*
// 当 pageViewController 的是翻页模式并且是横竖屏状态变化时触发， 返回书脊的位置
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
  if (orientation == UIInterfaceOrientationPortrait) {
    return UIPageViewControllerSpineLocationMin;
  }
  return UIPageViewControllerSpineLocationMid;
}
// 返回 pageViewController 支持的屏幕类型
- (UIInterfaceOrientationMask)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController
{
  return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController
{
  return UIInterfaceOrientationPortrait;
}
*/

#pragma mark }



/**
 style: 这个参数是UIPageViewController翻页的过渡样式,系统提供了两种过度样式,分别是
 UIPageViewControllerTransitionStylePageCurl : 卷曲样式类似翻书效果
 UIPageViewControllerTransitionStyleScroll : UIScrollView滚动效果
 navigationOrientation: 这个参数是UIPageViewController导航方向,系统提供了两种方式,分别是
 UIPageViewControllerNavigationOrientationHorizontal : 水平导航方式
 UIPageViewControllerNavigationOrientationVertical : 垂直导航方式
 options: 这个参数是可选的,传入的是对UIPageViewController的一些配置组成的字典,不过这个参数只能以UIPageViewControllerOptionSpineLocationKey和UIPageViewControllerOptionInterPageSpacingKey这两个key组成的字典.
 UIPageViewControllerOptionSpineLocationKey 这个key只有在style是翻书效果UIPageViewControllerTransitionStylePageCurl的时候才有作用, 它定义的是书脊的位置,值对应着UIPageViewControllerSpineLocation这个枚举项,不要定义错了哦.
 UIPageViewControllerOptionInterPageSpacingKey这个key只有在style是UIScrollView滚动效果UIPageViewControllerTransitionStyleScroll的时候才有作用, 它定义的是两个页面之间的间距(默认间距是0).
 */
- (UIPageViewController *)pageViewController
{
  if (!_pageViewController) {
    UIPageViewControllerTransitionStyle style = UIPageViewControllerTransitionStylePageCurl;
    // 设置UIPageViewController的配置项
    NSDictionary *options;
    if (style == UIPageViewControllerTransitionStylePageCurl) {
      options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationNone)};
    } else {
      options = @{UIPageViewControllerOptionInterPageSpacingKey : @(20)};
    }
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:style navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    _pageViewController.doubleSided = YES;
    [_pageViewController setViewControllers:@[self.controllerArray.firstObject] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    _pageViewController.view.frame = self.view.bounds;
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
  }
  return _pageViewController;
}


- (NSMutableArray *)controllerArray
{
  if (!_controllerArray) {
    _controllerArray = [NSMutableArray arrayWithCapacity:3];
    NSArray *array = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor]];
    for (int i = 0; i < 3; i++) {
      MyPageItemViewController *viewController = [[MyPageItemViewController alloc] init];
      viewController.title = [NSString stringWithFormat:@"ViewController %d", i];
      viewController.view.backgroundColor = array[i];
      viewController.index = i;
      [_controllerArray addObject:viewController];
    }
  }
  return _controllerArray;
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
