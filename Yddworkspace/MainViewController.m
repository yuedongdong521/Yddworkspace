//
//  MainViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/1.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MainViewController.h"
#import "WeChatTestFloatViewController.h"
#import "Yddworkspace-Swift.h"
#import "XMLDataAnalysis.h"

#define UIColorFromRGBAalpha(rgbValue,alpha) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:((float)alpha)]

struct model {
  int a;
  int b;
};

@interface MainViewController ()

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) UIView *animView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIView *animbgView;
@property (nonatomic, strong) NSString *blockStr;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.text = self.title;
    [self.view addSubview:label];
    
    int r = (0x7b7c84 & 0xFF0000) >> 16;
    int g = (0x7b7c84 & 0x00FF00) >> 8;
    int b = (0x7b7c84 & 0x0000FF);
    NSLog(@"color r = %x, g = %x, b = %x", r, g, b);
  long long x = 4000000000;
  if (x > 3000000000ll) {
    NSLog(@"x > 3000000000ll");
  } else {
    NSLog(@"x < 3000000000ll");
  }
  
  NSLog(@"3000000000sizeof : %lu", sizeof(3000000000));
  NSLog(@"long long sizeof : %lu", sizeof(long long));
  NSLog(@"long sizeof : %lu",sizeof(1ll));
  NSLog(@"int sizeof : %lu", sizeof(2));
  
  if ([_path isEqualToString:@"ydd"]) {
    NSLog(@"_path isEqualToString:ydd");
  } else {
    NSLog(@"_path unEqualToString:ydd");
  }
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(20, ScreenHeight - 180, 50, 50);
  [button setTitle:@"show" forState:UIControlStateNormal];
  [button setTitle:@"dismiss" forState:UIControlStateSelected];
  [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  
  UIButton *push = [UIButton buttonWithType:UIButtonTypeSystem];
  push.frame = CGRectMake(20, ScreenHeight - 300, 50, 50);
  [push setTitle:@"pushVC" forState:UIControlStateNormal];
  [push addTarget:self action:@selector(pushVC) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:push];
  
  NSString *imageStr = @"1,2";
  NSArray *array = [imageStr componentsSeparatedByString:@","];
  
  NSString *imageStr2 = @"1";
  NSArray *array2 = [imageStr2 componentsSeparatedByString:@","];
  
  NSString *imageStr3 = @"1,";
  NSArray *array3 = [imageStr2 componentsSeparatedByString:@","];
  int rgbValue = 0xff, alpha = 1;
  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:((float)alpha)];
  NSLog(@"%@", array2);
  [self testDataModel];
  
  
  NSMutableArray *mutArr = [NSMutableArray arrayWithArray:@[@"0", @"1", @"2"]];
  NSArray *arr = @[@"3", @"4"];
  [mutArr insertObjects:arr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, arr.count)]];
  
  NSLog(@"mutArr = %@", mutArr);
  
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
  
  NSMutableArray *emptyArr = [NSMutableArray array];
  NSString *emptyStr = emptyArr.firstObject;
  
  NSLog(@"emptyStr : %@", emptyStr);
  
  [XMLDataAnalysis analysisXML];
  
  NSString *urlStr = @"https://h5.ispeak.cn/lingxiu?uid=142615177&partner_id=0&sub_partnerid=0&ver=1000&client_type=2&to_uid=74699911&toproomid=10000311&subroomid=118776694";
  NSData *encodeStr = [urlStr dataUsingEncoding:NSUTF8StringEncoding];
  NSString *str = [encodeStr base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  
  NSString *base64Str = [self base64Encode:urlStr];
  NSString *decodeStr = [self base64Decode:base64Str];
  
  [self oc_quzheng];
  NSLog(@"str 2 : %@", str);
  
  
  
}

- (NSString *)base64Encode:(NSString *)str
{
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  NSData *base64Data = [data base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  return [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
}

- (NSString *)base64Decode:(NSString *)str
{
  NSData *data = [[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
  NSString *decodeStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return decodeStr;
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

- (void)testDataModel
{
  DataModel *model = [[DataModel alloc] init];
  [model dateString];
}

- (void)pushVC
{
  WeChatTestFloatViewController *vc = [[WeChatTestFloatViewController alloc] init];
  [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)animbgView
{
  if (!_animbgView) {
    _animbgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _animbgView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismss)];
    [_animbgView addGestureRecognizer:tap];
  }
  return _animbgView;
}

- (void)buttonAction:(UIButton *)button
{
  [self show];
}

- (void)dismss
{
  [self.animator removeAllBehaviors];
  [UIView animateWithDuration:0.5 animations:^{
    _animView.alpha = 0.0;
    CGAffineTransform roat = CGAffineTransformMakeRotation(0.9 * M_PI);
    CGAffineTransform scale = CGAffineTransformMakeScale(0.1, 0.1);
    _animView.transform = CGAffineTransformConcat(roat, scale);
  } completion:^(BOOL finished) {
    [_animbgView removeFromSuperview];
    _animbgView = nil;
    [_animView removeFromSuperview];
    _animView = nil;
  }];
  
}

- (void)show {
//  UIView* keywindow = [[UIApplication sharedApplication] keyWindow];
//
//  [keywindow addSubview:self.view];
  [self.view addSubview:self.animbgView];
  self.animView.frame = CGRectMake(0, 0, 200, 200);
  self.animView.alpha = 1;
  _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.animbgView];
  UISnapBehavior* sanp = [[UISnapBehavior alloc] initWithItem:self.animView
                                                  snapToPoint:self.animbgView.center];
  sanp.damping = 0.7;
  [self.animator addBehavior:sanp];
}

- (UIView *)animView
{
  if (!_animView) {
    _animView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _animView.layer.masksToBounds = YES;
    _animView.layer.cornerRadius = 10;
    _animView.backgroundColor = [UIColor redColor];
    [self.animbgView addSubview:_animView];
  }
  return _animView;
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    NSLog(@"MainViewController.view.frame2 = %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"MainViewController.view.bounds2 = %@", NSStringFromCGRect(self.view.bounds));
     NSLog(@"MainViewController.edgesForExtendedLayout = %lu", (unsigned long)self.edgesForExtendedLayout);
    NSLog(@"MainViewController.translucent = %d", self.navigationController.navigationBar.translucent);
  
  [self wechatRedPackage:0.1 num:10];
  
  [self wechatRedPackage:10 num:10];
}

#pragma mark 取整
- (void)oc_quzheng
{
  // 向上取整
  CGFloat x = 1.6;
  int a = (int)ceilf(x);
  
  // 向下取整
  int b = (int)floor(x);
  NSLog(@"a = %d, b = %d", a, b);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)wechatRedPackage:(CGFloat)total num:(NSInteger)num
{
  static CGFloat minValue = 0.01;
  NSInteger totalInt = total * 100;
  NSMutableArray *mutArr = [NSMutableArray array];
  CGFloat sum = 0;
  NSInteger average = 0;
  NSInteger value = 0;
  NSInteger maxValue = 0;
  while (num > 0) {
    if (num == 1) {
      [mutArr addObject:@(totalInt * minValue)];
      sum += totalInt;
      break;
    }
    NSInteger arc = arc4random();
    average = totalInt / num;
    if (average <= 1) {
      value = 1;
    } else {
      maxValue = average * 2;
      if (num <= 2 || maxValue <= num) {
        maxValue = totalInt;
      }
      value = arc % (maxValue - num) + 1;
    }
    totalInt -= value;
    num--;
    [mutArr addObject:@(value * minValue)];
    sum += value;
  }
  
  NSLog(@"mutArr = %@, sum = %f", mutArr, sum * minValue);
  
  
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
