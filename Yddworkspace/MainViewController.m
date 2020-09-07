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
#import "NSString+CharacterSet.h"
#import "ISAlertController.h"
#import "TimeTools.h"
#import "CustomGradBtn.h"
#import "CustomSlider.h"
#import "UIView+Extend.h"
#import "NSString+yddSubByte.h"
#import "KXDynamicVideoPlayer.h"
#import "KXAudioAnimationView.h"
#import "KXTextScrollView.h"
#import "LoadingAnimationView.h"
#import "KXVideoLoadMoreView.h"
#import "UIImage+ydd.h"


@interface MainViewController ()

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) UIView *animView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIView *animbgView;

@property (nonatomic, strong) CustomSlider *slider;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor grayColor];
    
    UIScrollView *scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 100, 50, 50)];
    [self.view addSubview:scroller];
    scroller.zoomScale = 0;
    
    KXAudioAnimationView *audioView = [[KXAudioAnimationView alloc] initWithFrame:CGRectMake(ScreenWidth - 51, ScreenHeight - 300, 41, 36)];
    [self.view addSubview:audioView];
    [audioView startAnimation];
    
    
    [self testScrollText];
    
    [self sortArr];
    NSUInteger timeStamp = [TimeTools timeStampSincel1970];
    NSLog(@"timeStamp = %lu", (unsigned long)timeStamp);
    NSString *date = [TimeTools timeWithStyle:@"yyyy/MM/dd - HH:mm:ss" timeStamp:timeStamp];
    NSLog(@"date = %@", date);
//    NSString *dateStr = [TimeTools timeWithStyle:(nonnull NSString *) date:<#(nonnull NSDate *)#>]
    
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
  button.frame = CGRectMake(20, ScreenHeight - 180, 10, 10);
    [button setResponsEdge:UIEdgeInsetsMake(-20, -20, -20, -20)];
//    button.frame = UIEdgeInsetsInsetRect(button.frame, UIEdgeInsetsMake(-20, -20, -20, -20));
  [button setTitle:@"show" forState:UIControlStateNormal];
  [button setTitle:@"dismiss" forState:UIControlStateSelected];
  [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  
  UIButton *push = [UIButton buttonWithType:UIButtonTypeSystem];
  push.frame = CGRectMake(20, ScreenHeight - 300, 50, 50);
  [push setTitle:@"pushVC" forState:UIControlStateNormal];
  [push addTarget:self action:@selector(pushVC) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:push];

 
  int rgbValue = 0xff, alpha = 1;
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:((float)alpha)];
    
  [self testDataModel];
  
  
  NSMutableArray *mutArr = [NSMutableArray arrayWithArray:@[@"0", @"1", @"2"]];
  NSArray *arr = @[@"3", @"4"];
  [mutArr insertObjects:arr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, arr.count)]];
  
  NSLog(@"mutArr = %@", mutArr);
  
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
  
  NSString *utf8str = @"http://mongoapi.ispeak.cn/anchor/64301766/user_page_v2/0/10?act=1&client_type=2&follow_uid=104015397&relay=1&sign_type=md5&time=1551176775&ver=1000&sign=ae99107eef68866c2976be1038553d25月%";
  NSString *utf8Encode = [utf8str stringUTF8Encode];
  NSLog(@"utf8Encode : %@", utf8Encode);
  
  utf8Encode = [utf8str urlUTF8Encode];
  NSLog(@"utf8Encode : %@", utf8Encode);
  
  
  UIButton *alertButton = [UIButton buttonWithType:UIButtonTypeSystem];
  alertButton.frame = CGRectMake(20, 88, 100, 50);
  [alertButton setTitle:@"alertController" forState:UIControlStateNormal];
  alertButton.backgroundColor = [UIColor greenColor];
  [alertButton addTarget:self action:@selector(alertBtnAction:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:alertButton];
    
    // 渐变色button
    CustomGradBtn *gradBtn = [CustomGradBtn buttonWithType:UIButtonTypeCustom];
    GradLayerModel *gradModel = [[GradLayerModel alloc] init];
    [gradModel setGradColors:@[UIColorHexRGBA(0XFFA692, 1), UIColorHexRGBA(0XD15FFF, 1)]];
    gradModel.startPoint = CGPointMake(0, 1);
    gradModel.endPoint = CGPointMake(1, 1);
    gradModel.type = kCAGradientLayerAxial;
    [gradBtn setGradModel:nil gradState:NO];
    [gradBtn setGradModel:gradModel gradState:YES];
    gradBtn.backgroundColor = [UIColor cyanColor];
    [gradBtn addTarget:self action:@selector(gradBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gradBtn];
    [gradBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-80);
        make.width.height.mas_equalTo(100);
    }];
  
    _slider = [[CustomSlider alloc] initWithHeight:10];
    _slider.bgColor = [UIColor whiteColor];
    [self.view addSubview:_slider];
   
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(gradBtn.mas_top).mas_offset(-10);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(10);
    }];
    
    [_slider setNeedsLayout];
    [_slider layoutIfNeeded];
    
     _slider.progress = 0.5;
    
    CustomURLRequest *request = [[CustomURLRequest alloc] initWithUrl:@"http://pic1.win4000.com/pic/b/e9/b6c3874c76_250_350.jpg"];
    
//    [request addConstructingBodyBlock];
    [request startRequestCompletionBlock:^(ResponseModel * _Nonnull responseModel) {
        if (!responseModel.error || responseModel.error.code == 0) {
            UIImage *image = [UIImage imageWithData:responseModel.data];
            NSLog(@"size : %@", NSStringFromCGSize(image.size));
        }
        
    }];
  
    NSDictionary *dic = @{@"name":@"ydd", @"num":@(2)};
       NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingFragmentsAllowed error:nil];
       NSString *dicstr = [[NSString alloc] initWithUTF8String:data.bytes];
       NSLog(@"str = %@", dicstr);
       UILabel *diclabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 400, 200, 100)];
    diclabel.numberOfLines = 0;
       diclabel.text = dicstr;
       [self.view addSubview:diclabel];
    
    NSString *nickName = @"(*￣︶￣)123😊ydd_123Daf_*&^%$#@!~wer";
    NSString *nickName0 = [nickName filterStringSpecialStr];
    NSString *nickName1 = [nickName filterSpecialCharactor];
    NSLog(@"nickName0 = %@\nnickName = %@", nickName0,nickName1);
    
//    [nickName componentsSeparatedByString:@";"];
    
    
    LoadingAnimationView *loadView = [[LoadingAnimationView alloc] init];
    [self.view addSubview:loadView];
    [loadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(200);
    }];
    
    
    KXVideoLoadMoreView *loadMoreView = [[KXVideoLoadMoreView alloc] initWithFrame:CGRectMake(20, 200, 300, 5)];
    [self.view addSubview:loadMoreView];
    
    
    [loadMoreView startAnimation];
    
    UITextView *text = [[UITextView alloc] init];
    for (UIGestureRecognizer *ges in text.gestureRecognizers) {
        NSLog(@"textView ges description : %@", ges.description);
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *orignImage = [UIImage imageNamed:@"0.jpg"];
        orignImage = [orignImage scallImageWidthScallSize:CGSizeMake(20, 20)];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:orignImage];
            [self.view addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.view);
                make.height.width.mas_equalTo(20);
            }];
        });
    });
    
    
}

- (void)gradBtnAction:(CustomGradBtn *)btn
{
    btn.gradLayerSelected = !btn.gradLayerSelected;

    _slider.progress = arc4random() % 1000 * 0.001;
    
}

- (void)alertBtnAction:(UIButton *)btn
{
    [KXDynamicVideoPlayer showPlayerWithVideoURl:@"" startTime:0 image:[UIImage imageNamed:@"0.jpg"] dismissBlock:^{
        
    }];
    
//  [self alertShowFlag:0];
//    [self alertShowFlag:0];
//    [self alertShowFlag:0];
}

- (void)alertShowFlag:(int)flag
{
  /*
  if (flag == 0) {
    ISAlertController *alert = [ISAlertController alertTextFieldsWithTitle:@"提示" message:@"解锁" textFieldsPlaceholder:@[@"请输入密码"] cancelTitle:@"取消" otherTitle:@"确定" cancelBlock:^{
      
    } actionBlock:^(NSArray<UITextField *> * _Nonnull textValues) {
      NSLog(@"密码： %@", textValues.firstObject.text);
    }];
    
    
    [alert showInWindow];
  } else {
    [[ISAlertController alertWithTitle:@"提示" message:@"我好帅！" cancelTitle:@"是" otherTitle:@"确定" cancelBlock:nil actionBlock:nil] showInWindow];
  }
  */
  
  UITextField *textField = [[UITextField alloc] init];
  ISAlertController *alert = [ISAlertController alertCustomTextFieldWithTitle:@"提示" message:@"解锁" customTextField:&textField cancelTitle:@"取消" otherTitle:@"确定" cancelBlock:^{
    
  } actionBlock:^(NSString * _Nonnull text) {
    NSLog(@"密码：%@",text);
  }];
  alert.textFields.firstObject.placeholder = @"请输入密码";
//  textField.placeholder = @"请输入密码";
  [alert showInWindow];
 
  if (flag == 0) {
    return;
  }
  [self alertShowFlag:flag + 1];
}

- (void)testScrollText
{
    
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(20, ScreenHeight - 250, 100, 30)];
    [self.view addSubview:textView];
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = textView.bounds;
    id color1 = (id)[UIColor colorWithWhite:0 alpha:0].CGColor;
    id color2 = (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor;
    id color3 = (id)[UIColor colorWithWhite:0 alpha:1].CGColor;
    gradientLayer.colors = @[color1, color2, color3, color3, color2, color1];
    gradientLayer.locations = @[@0, @0.1f, @0.2f, @0.8f, @0.9f, @1];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    textView.layer.mask = gradientLayer;
    
    
    KXTextScrollView *textScrollView = [[KXTextScrollView alloc] initWithFrame:textView.bounds inteval:20 fontSize:[UIFont systemFontOfSize:17]];
    [textView addSubview:textScrollView];
    [textScrollView updataArray:@[@"测试文本首位相接无线循环滚动"]];
    [textScrollView startTimer];
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


- (void)testDataModel
{
  DataModel *model = [[DataModel alloc] init];
  [model dateString];
}

- (void)pushVC
{
  WeChatTestFloatViewController *vc = [[WeChatTestFloatViewController alloc] init];
    vc.isNeedCustomTransition = YES;
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
  NSArray *titles = @[@"很帅", @"非常帅"];

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

/** 仿微信红包计算方法 */
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


- (void)sortArr
{
    NSArray <NSString *>*arr = @[@"agrnee", @"agreen123"];
    NSArray *newarr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSForcedOrderingSearch];
    }];
    NSLog(@"new arr = %@", newarr);
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
