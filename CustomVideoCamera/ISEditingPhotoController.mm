//
//  ISEditingPhotoController.m
//  iShow
//
//  Created by run on 2017/10/27.
//

#import "ISEditingPhotoController.h"

@interface ISEditingPhotoController ()

@property(nonatomic, strong) UIImageView* imageView;

@end

@implementation ISEditingPhotoController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];

  // 照片框
  _imageView = [[UIImageView alloc] init];
  _imageView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
  _imageView.contentMode = UIViewContentModeScaleAspectFill;
  [self.view addSubview:_imageView];

  // 顶部背景图
  UIView* tool = [[UIView alloc] init];
  tool.backgroundColor = [UIColor clearColor];
  tool.frame = CGRectMake(0, 0, ScreenWidth, 50);
  if (IS_IPHONE_X) {
    tool.frame = CGRectMake(0, 0, ScreenWidth, 50 + 24);
  }
  [self.view addSubview:tool];

  // 渐变图层
  CAGradientLayer* gradLayer = [CAGradientLayer layer];
  gradLayer.colors = @[
    (__bridge id)[UIColor colorWithRed:20 / 255.f
                                 green:20 / 255.f
                                  blue:20 / 255.f
                                 alpha:0.4]
        .CGColor,
    (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor
  ];
  gradLayer.frame = CGRectMake(0, 0, ScreenWidth, 50);
  [tool.layer addSublayer:gradLayer];

  CGFloat offsetY = 10;
  if (IS_IPHONE_X) {
    offsetY = 34;
  }

  // 左上按钮  x
  UIButton* backBtn =
      [[UIButton alloc] initWithFrame:CGRectMake(15, offsetY, 30, 30)];
  [backBtn setImage:[UIImage imageNamed:@"BackToHome"]
           forState:UIControlStateNormal];
  [backBtn addTarget:self
                action:@selector(backBtnClick:)
      forControlEvents:UIControlEventTouchUpInside];
  [tool addSubview:backBtn];

  // 返回拍照
  UIButton* bacButton = [UIButton buttonWithType:UIButtonTypeCustom];
  bacButton.frame =
      CGRectMake(50, ScreenHeight - 105.0 - IS_TABBAR_ADD_HEIGHT, 50.0, 50.0);
  [bacButton setImage:[UIImage imageNamed:@"icon_video_reset_photo"]
             forState:UIControlStateNormal];
  [bacButton addTarget:self
                action:@selector(back)
      forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:bacButton];

  // 完成
  UIButton* completeButton = [[UIButton alloc] init];
  completeButton.frame =
      CGRectMake(ScreenWidth - 100, ScreenHeight - 105.0 - IS_TABBAR_ADD_HEIGHT,
                 50.0, 50.0);
  UIImage* img3 = [UIImage imageNamed:@"complete"];
  [completeButton setImage:img3 forState:UIControlStateNormal];
  [completeButton addTarget:self
                     action:@selector(complete)
           forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:completeButton];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _imageView.image = _photoImage;
}

- (void)viewDidAppear:(BOOL)animated {
 
  [super viewDidAppear:animated];
  if (!_photoImage) {
    // 返回
    [self backControl];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
 
  [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)backBtnClick:(UIButton*)sender {

  [self back];
}
// 返回上一页
- (void)back {
  [self.navigationController popViewControllerAnimated:NO];
}

- (void)complete {
  NSMutableArray* imageArr = [NSMutableArray arrayWithCapacity:0];
  NSData* imageData = UIImagePNGRepresentation(_photoImage);

  if (!imageData) {
    [self backControl];
    return;
  }
  [self.navigationController dismissViewControllerAnimated:YES
                                                completion:nil];
}

// 返回上页面
- (void)backControl {
  [self.navigationController popViewControllerAnimated:YES];
}

@end
