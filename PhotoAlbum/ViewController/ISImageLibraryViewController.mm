//
//  ISImageLibraryViewController.m
//  iShow
//
//  Created by admin on 2017/5/26.
//
//
#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f

#import "ISImageLibraryViewController.h"

@interface ISImageLibraryViewController ()

@end

@implementation ISImageLibraryViewController
@synthesize imageView;
@synthesize originalImages;

@synthesize cropFrame;
@synthesize oldFrame;
@synthesize largeFrame;
@synthesize limitRatio;
@synthesize latestFrame;

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  self.view.clipsToBounds = YES;

  [self initcontentView];

  UIPinchGestureRecognizer* pinchGestureRecognizer =
      [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(pinchView:)];
  [self.view addGestureRecognizer:pinchGestureRecognizer];

  UIPanGestureRecognizer* panGestureRecognizer =
      [[UIPanGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(panView:)];
  [self.view addGestureRecognizer:panGestureRecognizer];

  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  // Do any additional setup after loading the view.

  /********************异地登录引起，返回通知********************/
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(appdelegate_ImageLibraryTwoBack)
             name:kTopChangeLibraryTwoNotify_c
           object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  if ([AppDelegate appDelegate].ssSpeedingPushTag ==
      SPEEDINGPUSHTAG_SETIFAITop) {
    [AppDelegate appDelegate].ssSpeedingPushTag = SPEEDINGPUSHTAG_SETIFAITopTwo;
  } else if ([AppDelegate appDelegate].ssSpeedingPushTag ==
             SPEEDINGPUSHTAG_SCIFAITop) {
    [AppDelegate appDelegate].ssSpeedingPushTag = SPEEDINGPUSHTAG_SCIFAITopTwo;
  } else if ([AppDelegate appDelegate].ssSpeedingPushTag ==
             SPEEDINGPUSHTAG_FFMIFAITop) {
    [AppDelegate appDelegate].ssSpeedingPushTag = SPEEDINGPUSHTAG_FFMIFAITopTwo;
  }

  [[UIApplication sharedApplication]
      setStatusBarHidden:YES
           withAnimation:UIStatusBarAnimationSlide];
  //
  if (self.pushFlg == 1) {
    if (SCREEN_MODE_IPHONE6Plus) {
      cropFrame = CGRectMake(0, 205.0, self.view.frame.size.width,
                             self.view.frame.size.width);
    } else if (SCREEN_MODE_IPHONE6) {
      cropFrame = CGRectMake(0, 170.5, self.view.frame.size.width,
                             self.view.frame.size.width);
    } else if (SCREEN_MODE_IPHONE5) {
      cropFrame = CGRectMake(0, 121, self.view.frame.size.width,
                             self.view.frame.size.width);
    } else {
      cropFrame = CGRectMake(0, 77, self.view.frame.size.width,
                             self.view.frame.size.width);
    }
  } else {
    if (SCREEN_MODE_IPHONE6Plus) {
      cropFrame = CGRectMake(0, 133.0, self.view.frame.size.width,
                             self.view.frame.size.width);
    } else if (SCREEN_MODE_IPHONE6) {
      cropFrame = CGRectMake(0, 100, self.view.frame.size.width,
                             self.view.frame.size.width);
    } else if (SCREEN_MODE_IPHONEX) {
      cropFrame = CGRectMake(0, 181, self.view.frame.size.width,
                             self.view.frame.size.width);
    } else if (VERSION_MODE_IOS_ON_SEVEN) {
      cropFrame = CGRectMake(0, 80.0, self.view.frame.size.width,
                             self.view.frame.size.width);
    } else {
      cropFrame = CGRectMake(0, 49.0, self.view.frame.size.width,
                             self.view.frame.size.width + 34);
    }
  }
  CGFloat oriWidth = cropFrame.size.width;
  CGFloat oriHeight =
      originalImages.size.height * (oriWidth / originalImages.size.width);
  CGFloat oriX = cropFrame.origin.x + (cropFrame.size.width - oriWidth) / 2;
  CGFloat oriY = cropFrame.origin.y + (cropFrame.size.height - oriHeight) / 2;
  if (oriY < 0) {
    oriY = 0;
  }

  oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
  latestFrame = oldFrame;
  limitRatio = 3.0;
  largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width,
                          self.limitRatio * self.oldFrame.size.height);
  // ②
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.frame = oldFrame;
  [imageView setImage:self.originalImages];
  [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)initcontentView {
  int y = 0;
  imageView = [[UIImageView alloc]
      initWithFrame:CGRectMake(0, y, ScreenWidth, ScreenHeight)];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.autoresizesSubviews = YES;
  imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                               UIViewAutoresizingFlexibleTopMargin |
                               UIViewAutoresizingFlexibleHeight |
                               UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:imageView];

  UIImage* cropImage = nil;
  if (SCREEN_MODE_IPHONE5) {
    if (self.pushFlg == 1) {
      cropImage = [UIImage
          imageWithContentsOfFile:[[NSBundle mainBundle]
                                      pathForResource:kCropBoardPersonallyIamge5
                                               ofType:kPngName]];
    } else {
      cropImage = [UIImage
          imageWithContentsOfFile:[[NSBundle mainBundle]
                                      pathForResource:kCropBoardImageIphone5
                                               ofType:kPngName]];
    }
  } else if (SCREEN_MODE_IPHONE6) {
    if (self.pushFlg == 1) {
      cropImage = [UIImage
          imageWithContentsOfFile:[[NSBundle mainBundle]
                                      pathForResource:kCropBoardPersonallyIamge6
                                               ofType:kPngName]];
    } else {
      cropImage = [UIImage
          imageWithContentsOfFile:[[NSBundle mainBundle]
                                      pathForResource:kCropBoardImageIphone6
                                               ofType:kPngName]];
    }
  } else if (SCREEN_MODE_IPHONE6Plus) {
    if (self.pushFlg == 1) {
      cropImage =
          [UIImage imageWithContentsOfFile:
                       [[NSBundle mainBundle]
                           pathForResource:kCropBoardPersonallyIamge6puls
                                    ofType:kPngName]];
    } else {
      cropImage = [UIImage
          imageWithContentsOfFile:[[NSBundle mainBundle]
                                      pathForResource:kCropBoardImageIphone6plus
                                               ofType:kPngName]];
    }
  } else if (SCREEN_MODE_IPHONEX) {
    if (self.pushFlg == 1) {
      cropImage = [UIImage
          imageWithContentsOfFile:[[NSBundle mainBundle]
                                      pathForResource:kCropBoardPersonallyIamgeX
                                               ofType:kPngName]];
    } else {
      cropImage = [UIImage
          imageWithContentsOfFile:[[NSBundle mainBundle]
                                      pathForResource:kCropBoardImageIphoneX
                                               ofType:kPngName]];
    }
  } else {
    if (self.pushFlg == 1) {
      cropImage = [UIImage
          imageWithContentsOfFile:
              [[NSBundle mainBundle] pathForResource:kCropBoardPersonallyIamge4s
                                              ofType:kPngName]];
    } else {
      cropImage =
          [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                               pathForResource:kPictureCutBkg
                                                        ofType:kPngName]];
    }
  }

  UIImageView* cropImageView = [[UIImageView alloc] initWithImage:cropImage];
  if (SCREEN_MODE_IPHONE6Plus || SCREEN_MODE_IPHONE6 || SCREEN_MODE_IPHONEX) {
    cropImageView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
  } else if (VERSION_MODE_IOS_ON_SEVEN) {
    cropImageView.frame =
        CGRectMake(0, 0, cropImage.size.width, cropImage.size.height);
  } else {
    cropImageView.frame = CGRectMake(0, -27, 320, 480 + 27);
  }
  [self.view addSubview:cropImageView];

  UIView* bottomView = [[UIView alloc] initWithFrame:CGRectZero];
  if (SCREEN_MODE_IPHONE5) {
    bottomView.frame = CGRectMake(0, ScreenHeight - 73, ScreenWidth, 73);
  } else {
    bottomView.frame = CGRectMake(0, ScreenHeight - 73, ScreenWidth, 75);
  }
  bottomView.backgroundColor = [UIColor colorWithRed:0 / 256.0f
                                               green:0 / 256.0f
                                                blue:0 / 256.0f
                                               alpha:.6];  // 返回 ，选取背景
  [self.view addSubview:bottomView];

  UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  if (IS_IPHONE_X) {
    backButton.frame = CGRectMake(0, ScreenHeight - 75, 60, 45);
  } else if (SCREEN_MODE_IPHONE5) {
    backButton.frame = CGRectMake(0, 503, 60, 73);
  } else {
    backButton.frame = CGRectMake(0, ScreenHeight - 75, 60, 75);
  }
  [backButton setTitle:@"返回" forState:UIControlStateNormal];
  [backButton addTarget:self
                 action:@selector(popToDismiss)
       forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:backButton];

  UIButton* selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
  if (IS_IPHONE_X) {
    selectButton.frame =
        CGRectMake(ScreenWidth - 60, ScreenHeight - 75, 60, 45);
  } else if (SCREEN_MODE_IPHONE5) {
    selectButton.frame = CGRectMake(ScreenWidth - 60, 503, 60, 73);
  } else {
    selectButton.frame =
        CGRectMake(ScreenWidth - 60, ScreenHeight - 75, 60, 75);
  }
  [selectButton setTitle:@"选取" forState:UIControlStateNormal];
  [selectButton
             addTarget:self
                action:@selector(saveImageImageLibraryViewControllerToPressed)
      forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:selectButton];
}

#pragma mark 手势方法 {
- (void)pinchView:(UIPinchGestureRecognizer*)pinchGestureRecognizer {
  if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
      pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
    imageView.transform = CGAffineTransformScale(imageView.transform,
                                                 pinchGestureRecognizer.scale,
                                                 pinchGestureRecognizer.scale);
    pinchGestureRecognizer.scale = 1;
  } else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    CGRect newFrame = imageView.frame;
    newFrame = [self handleScaleOverflow:newFrame];
    newFrame = [self handleBorderOverflow:newFrame];
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:BOUNDCE_DURATION
                     animations:^{
                       imageView.frame = newFrame;
                       latestFrame = newFrame;
                     }];
  }
}

- (void)panView:(UIPanGestureRecognizer*)panGestureRecognizer {
  if (panGestureRecognizer.state == UIGestureRecognizerStateBegan ||
      panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
    if (self.pushFlg == 1) {
      if (SCREEN_MODE_IPHONE6Plus) {
        cropFrame = CGRectMake(87, 205.0, self.view.frame.size.width - 87,
                               self.view.frame.size.height - 410);
      } else if (SCREEN_MODE_IPHONE6) {
        cropFrame = CGRectMake(67.5, 170.5, self.view.frame.size.width - 67.5,
                               self.view.frame.size.height - 341);
      } else if (SCREEN_MODE_IPHONEX) {
        // 分辨率 240 * 326
        CGFloat itemWidth = 240.0;
        CGFloat itemHeight = 326.0;
        CGFloat xPos = (ScreenWidth - itemWidth) / 2;
        CGFloat yPos = (ScreenHeight - itemHeight) / 2;
        cropFrame = CGRectMake(xPos, yPos, itemWidth, itemHeight);
      } else if (SCREEN_MODE_IPHONE5) {
        cropFrame = CGRectMake(40, 121, self.view.frame.size.width - 40,
                               self.view.frame.size.height - 242);
      } else {
        cropFrame = CGRectMake(40, 77, self.view.frame.size.width - 40,
                               self.view.frame.size.height - 154);
      }
    }

    CGFloat absCenterX = cropFrame.origin.x + cropFrame.size.width / 2;
    CGFloat absCenterY = cropFrame.origin.y + cropFrame.size.height / 2;
    CGFloat scaleRatio = imageView.frame.size.width / cropFrame.size.width;
    CGFloat acceleratorX =
        1 - ABS(absCenterX - imageView.center.x) / (scaleRatio * absCenterX);
    CGFloat acceleratorY =
        1 - ABS(absCenterY - imageView.center.y) / (scaleRatio * absCenterY);
    CGPoint translation =
        [panGestureRecognizer translationInView:imageView.superview];
    [imageView
        setCenter:(CGPoint){imageView.center.x + translation.x * acceleratorX,
                            imageView.center.y + translation.y * acceleratorY}];
    [panGestureRecognizer setTranslation:CGPointZero
                                  inView:imageView.superview];
  } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    CGRect newFrame = imageView.frame;
    newFrame = [self handleBorderOverflow:newFrame];
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:BOUNDCE_DURATION
                     animations:^{
                       imageView.frame = newFrame;
                       latestFrame = newFrame;
                     }];
  }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
  // bounce to original frame
  CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width / 2,
                                  newFrame.origin.y + newFrame.size.height / 2);
  if (newFrame.size.width < oldFrame.size.width) {
    newFrame = oldFrame;
  }
  if (newFrame.size.width > largeFrame.size.width) {
    newFrame = largeFrame;
  }
  newFrame.origin.x = oriCenter.x - newFrame.size.width / 2;
  newFrame.origin.y = oriCenter.y - newFrame.size.height / 2;
  return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
  if (self.pushFlg == 1) {
    if (SCREEN_MODE_IPHONE6Plus) {
      cropFrame = CGRectMake(87, 205.0, self.view.frame.size.width - 87,
                             self.view.frame.size.height - 410);
    } else if (SCREEN_MODE_IPHONE6) {
      cropFrame = CGRectMake(67.5, 170.5, self.view.frame.size.width - 67.5,
                             self.view.frame.size.height - 341);
    } else if (SCREEN_MODE_IPHONEX) {
      // 分辨率 240 * 326
      CGFloat itemWidth = 240.0;
      CGFloat itemHeight = 326.0;
      CGFloat xPos = (ScreenWidth - itemWidth) / 2;
      CGFloat yPos = (ScreenHeight - itemHeight) / 2;
      cropFrame = CGRectMake(xPos, yPos, itemWidth, itemHeight);
    } else if (SCREEN_MODE_IPHONE5) {
      cropFrame = CGRectMake(40, 121, self.view.frame.size.width - 40,
                             self.view.frame.size.height - 242);
    } else {
      cropFrame = CGRectMake(40, 77, self.view.frame.size.width - 40,
                             self.view.frame.size.height - 154);
    }
  }
  // horizontally
  if (newFrame.origin.x > cropFrame.origin.x) {
    newFrame.origin.x = cropFrame.origin.x;
  }
  if (CGRectGetMaxX(newFrame) < cropFrame.size.width) {
    newFrame.origin.x = cropFrame.size.width - newFrame.size.width;
  }
  // vertically
  if (newFrame.origin.y > cropFrame.origin.y) {
    newFrame.origin.y = cropFrame.origin.y;
  }
  if (CGRectGetMaxY(newFrame) < cropFrame.origin.y + cropFrame.size.height) {
    newFrame.origin.y =
        cropFrame.origin.y + cropFrame.size.height - newFrame.size.height;
  }
  // adapt horizontally rectangle适应水平矩形
  if (imageView.frame.size.width > imageView.frame.size.height &&
      newFrame.size.height <= cropFrame.size.height) {
    newFrame.origin.y =
        cropFrame.origin.y + (cropFrame.size.height - newFrame.size.height) / 2;
  }
  return newFrame;
}

#pragma mark }
#pragma mark 一些操作 {
// 返回
- (void)popToDismiss {
  [[UIApplication sharedApplication]
      setStatusBarHidden:NO
           withAnimation:UIStatusBarAnimationSlide];
  if ([AppDelegate appDelegate].ssSpeedingPushTag ==
      SPEEDINGPUSHTAG_SETIFAITopTwo) {
    [AppDelegate appDelegate].ssSpeedingPushTag = SPEEDINGPUSHTAG_SETIFAITop;
  } else if ([AppDelegate appDelegate].ssSpeedingPushTag ==
             SPEEDINGPUSHTAG_SCIFAITopTwo) {
    [AppDelegate appDelegate].ssSpeedingPushTag = SPEEDINGPUSHTAG_SCIFAITop;
  } else if ([AppDelegate appDelegate].ssSpeedingPushTag ==
             SPEEDINGPUSHTAG_FFMIFAITopTwo) {
    [AppDelegate appDelegate].ssSpeedingPushTag = SPEEDINGPUSHTAG_FFMIFAITop;
  }
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}
- (void)saveImageImageLibraryViewControllerToPressed {
  [[UIApplication sharedApplication]
      setStatusBarHidden:NO
           withAnimation:UIStatusBarAnimationSlide];
  if (self.pushFlg == 1) {
    UIImage* croppedImage = nil;
    UIImage* letterPressImage = [MTImageSize getImageFromView:self.view];
    CGFloat scale = [UIScreen mainScreen].scale;
    if (SCREEN_MODE_IPHONE6Plus) {
      croppedImage = [MTImageSize
          interceptingImage:CGRectMake(87 * scale, 205 * scale,
                                       (ScreenWidth - 174) * scale,
                                       (ScreenHeight - 410) * scale)
              completeImage:letterPressImage];
    } else if (SCREEN_MODE_IPHONE6) {
      croppedImage = [MTImageSize
          interceptingImage:CGRectMake(67.5 * scale, 170.5 * scale,
                                       (ScreenWidth - 135) * scale,
                                       (ScreenHeight - 340) * scale)
              completeImage:letterPressImage];
    } else if (SCREEN_MODE_IPHONEX) {
      // 分辨率 240 * 326
      CGFloat itemWidth = 240.0;
      CGFloat itemHeight = 326.0;
      CGFloat xPos = (ScreenWidth - itemWidth) / 2;
      CGFloat yPos = (ScreenHeight - itemHeight) / 2;
      croppedImage = [MTImageSize
          interceptingImage:CGRectMake(xPos * scale, yPos * scale,
                                       itemWidth * scale, itemHeight * scale)
              completeImage:letterPressImage];
    } else if (SCREEN_MODE_IPHONE5) {
      croppedImage = [MTImageSize
          interceptingImage:CGRectMake(40 * scale, 121 * scale,
                                       (ScreenWidth - 80) * scale,
                                       (ScreenHeight - 242) * scale)
              completeImage:letterPressImage];
    } else {
      croppedImage = [MTImageSize
          interceptingImage:CGRectMake(40 * scale, 77 * scale,
                                       (ScreenWidth - 80) * scale,
                                       (ScreenHeight - 154) * scale)
              completeImage:letterPressImage];
    }
    NSArray* viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
      [self.navigationController
          popToViewController:viewControllers[viewControllers.count - 4]
                     animated:YES];
    } else {
      [self.presentingViewController.presentingViewController
              .presentingViewController dismissViewControllerAnimated:YES
                                                           completion:nil];
    }
    NSDictionary* dict =
        [NSDictionary dictionaryWithObject:croppedImage forKey:@"MyCoverImage"];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"SendMyCoverImageWithImage"
                      object:nil
                    userInfo:dict];
  } else {
    UIImage* letterPressImage = [MTImageSize getImageFromView:self.view];
    CGFloat scale = [UIScreen mainScreen].scale;
    UIImage* croppedImage = nil;
    if (SCREEN_MODE_IPHONE6Plus) {
      croppedImage = [MTImageSize
          interceptingImage:CGRectMake(0, 134.0 * scale - 2,
                                       ScreenWidth * scale, ScreenWidth * scale)
              completeImage:letterPressImage];
    } else if (SCREEN_MODE_IPHONE6) {
      croppedImage = [MTImageSize
          interceptingImage:CGRectMake(0, 101 * scale - 1, ScreenWidth * scale,
                                       ScreenWidth * scale)
              completeImage:letterPressImage];
    } else if (SCREEN_MODE_IPHONEX) {
      croppedImage = [MTImageSize
          interceptingImage:CGRectMake(0, 181 * scale, ScreenWidth * scale,
                                       ScreenWidth * scale)
              completeImage:letterPressImage];
    } else {
      croppedImage = [MTImageSize
          interceptingImage:CGRectMake(0, 80 * scale, 320 * scale, 320 * scale)
              completeImage:letterPressImage];
    }
    NSArray* viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
      [self.navigationController
          popToViewController:viewControllers[viewControllers.count - 4]
                     animated:YES];
    } else {
      [self.presentingViewController.presentingViewController
              .presentingViewController dismissViewControllerAnimated:YES
                                                           completion:nil];
    }
    if (self.albumType == CONTACT_PHOTOLIST_WITH_HOSTCOVER) {
      NSDictionary* dict = @{
        @"AssetPhotoImage" : croppedImage,
        @"AlbumType" : [NSNumber numberWithInteger:self.albumType]
      };
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"SendHostCoverImageForPrepareLiveView"
                        object:nil
                      userInfo:dict];
    } else if (self.albumType == CONTACT_PHOTOLIST_WITH_VIDEO_COVER) {
      NSDictionary* dict = @{
        @"AssetPhotoImage" : croppedImage,
        @"AlbumType" : [NSNumber numberWithInteger:self.albumType]
      };
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"IS_EDIT_VIDEO_CHANGE_COVER"
                        object:nil
                      userInfo:dict];
    } else if (self.albumType == CONTACT_PHOTOLIST_WITH_FRIENTINFO) {
      NSDictionary* dict = @{
        @"AssetPhotoImage" : croppedImage,
        @"AlbumType" : [NSNumber numberWithInteger:self.albumType]
      };
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"IS_FRIENTINFO_CHANGE_HEADER"
                        object:nil
                      userInfo:dict];
    } else {
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"SendAlbumImageForHeadImage"
                        object:nil
                      userInfo:[NSDictionary
                                   dictionaryWithObject:croppedImage
                                                 forKey:@"HeadImage"]];
    }
  }
  if ([AppDelegate appDelegate].sessionViewBGView.isGlobalSession == YES) {
    [[AppDelegate appDelegate] showSessionViewTempSessionChatVIew];
  }
}
#pragma mark }
- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)appdelegate_ImageLibraryTwoBack {
  [self popToDismiss];
}

#pragma mark 触摸方法 {
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  if ([AppDelegate appDelegate].ssSpeedingPushTag ==
      SPEEDINGPUSHTAG_SChatLibraryT) {
    [self showAndHiddenBar];
  }
}

- (void)showAndHiddenBar {
  // a.
  CGRect rect = self.navigationController.navigationBar.frame;
  if (rect.origin.y >= 0) {
    self.navigationController.navigationBarHidden = YES;
    rect.origin.y = -kStatusAndNavBarHeight;
  } else {
    self.navigationController.navigationBarHidden = NO;
    rect.origin.y = 0;
  }
  [UIView beginAnimations:nil context:nil];  // 动画开始
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];  // 动画时间曲线
      // EaseInOut效果
  [UIView setAnimationDuration:0.3];  // 动画时间
  self.navigationController.navigationBar.frame = rect;
  [UIView commitAnimations];  // 动画结束（或者用提交也不错）
  // b.
  if (VERSION_MODE_IOS_ON_SIX) {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
      [[UIApplication sharedApplication]
          setStatusBarHidden:NO
               withAnimation:UIStatusBarAnimationSlide];
    } else {
      [[UIApplication sharedApplication]
          setStatusBarHidden:YES
               withAnimation:UIStatusBarAnimationSlide];
    }
  } else {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
      [[UIApplication sharedApplication]
          setStatusBarHidden:NO
               withAnimation:UIStatusBarAnimationSlide];
    } else {
      [[UIApplication sharedApplication]
          setStatusBarHidden:YES
               withAnimation:UIStatusBarAnimationSlide];
    }
  }
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little
 preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
