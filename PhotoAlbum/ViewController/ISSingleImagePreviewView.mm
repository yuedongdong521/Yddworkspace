//
//  ISSingleImagePreviewView.m
//  iShow
//
//  Created by admin on 2017/5/25.
//
//

#import "ISSingleImagePreviewView.h"
#import "ISCustomNavigationView.h"
#import "SendMyDynamicViewController.h"
#import "ISAssetsManager.h"

@interface ISSingleImagePreviewView ()

@property(nonatomic, strong) ISCustomNavigationView* customNavicationView;

@end

@implementation ISSingleImagePreviewView

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor blackColor];

  UIImageView* photoImgView = [[UIImageView alloc]
      initWithImage:[UIImage imageNamed:kImgDownSucceedIconHD]];
  photoImgView.backgroundColor = [UIColor clearColor];
  photoImgView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
  photoImgView.contentMode = UIViewContentModeScaleAspectFit;
  [self.view addSubview:photoImgView];

  ISPhotoAlbumModel* albumModel = self.albumModel;
  CGSize size = [self getSizeWithAsset:albumModel.asset];
  [[ISAssetsManager sharedInstancetype]
      posterImageWithPHAsset:albumModel.asset
               imageWithSize:size
                 contentMode:PHImageContentModeAspectFill
                  completion:^(UIImage* AssetImage) {
                    if (AssetImage) {
                      photoImgView.image = AssetImage;
                    }
                  }];

  [self.view addSubview:self.customNavicationView];
}

#pragma mark - 获取图片尺寸
- (CGSize)getSizeWithAsset:(PHAsset*)asset {
  float scaledWidth = (float)asset.pixelWidth;
  float scaledHeight = (float)asset.pixelHeight;

  CGSize imageSize = CGSizeMake(scaledWidth, scaledHeight);
  CGSize targetSize = CGSizeMake(ScreenWidth, ScreenHeight);

  if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
    CGFloat widthRatio = targetSize.width / imageSize.width;
    CGFloat heightRatio = targetSize.height / imageSize.height;
    if (widthRatio < heightRatio) {
      scaledWidth = imageSize.width * widthRatio;
      scaledHeight = imageSize.height * widthRatio;
    } else {
      scaledWidth = imageSize.width * heightRatio;
      scaledHeight = imageSize.height * heightRatio;
    }
  }
  return CGSizeMake(scaledWidth * ScreenScale, scaledHeight * ScreenScale);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (ISCustomNavigationView*)customNavicationView {
  if (!_customNavicationView) {
    _customNavicationView = [[ISCustomNavigationView alloc]
        initWithTitle:nil
                 left:[UIImage imageWithContentsOfFile:
                                   [[NSBundle mainBundle]
                                       pathForResource:kBSBackBtnImage
                                                ofType:kPngName]]
                right:@"确定"];
    __weak typeof(&*self) weakSelf = self;
    _customNavicationView.event = ^(ISCustomNavigationEventType eventType) {
      if (eventType == ISCustomNavigationLeftEvent) {
        [weakSelf leftBtnPressed];
      } else if (eventType == ISCustomNavigationRightEvent) {
        [weakSelf rightBtnPressed];
      }
    };
    _customNavicationView.backgroundColor =
        [UIColor colorWithWhite:0.0 alpha:0.3];
    _customNavicationView.frame =
        CGRectMake(0, 0, ScreenWidth, kStatusAndNavBarHeight);
    [_customNavicationView.rightButton setTitleColor:[UIColor whiteColor]
                                            forState:UIControlStateNormal];
    _customNavicationView.rightButton.titleLabel.font =
        [UIFont systemFontOfSize:17.0];
  }
  return _customNavicationView;
}

- (void)leftBtnPressed {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)rightBtnPressed {
  NSMutableArray* photoImageArray = [[NSMutableArray alloc] init];
  __weak typeof(&*self) weak_self = self;
  ISPhotoAlbumModel* albumModel = self.albumModel;
  CGSize size = [self getSizeWithAsset:albumModel.asset];
  [[ISAssetsManager sharedInstancetype]
      posterImageWithPHAsset:albumModel.asset
               imageWithSize:size
                 contentMode:PHImageContentModeAspectFill
                  completion:^(UIImage* AssetImage) {
                    if (AssetImage) {
                      NSData* imageData =
                          UIImageJPEGRepresentation(AssetImage, 1);
                      float dataLength = imageData.length / (1024.0 * 1024.0);
                      if (dataLength > 5.0) {
                        UIAlertView* alertView = [[UIAlertView alloc]
                                initWithTitle:@"温馨提示"
                                      message:
                                          @"您所选取的图片大于5M,请重新选择图片"
                                     delegate:nil
                            cancelButtonTitle:@"关闭"
                            otherButtonTitles:nil, nil];
                        [alertView show];
                        return;
                      } else {
                        if (dataLength * 1024.0 < 1) {
                          UIAlertView* alertView = [[UIAlertView alloc]
                                  initWithTitle:@"温馨提示"
                                        message:
                                            @"您所选取的图片小于1k,"
                                            @"请重新选择图片"
                                       delegate:nil
                              cancelButtonTitle:@"关闭"
                              otherButtonTitles:nil, nil];
                          [alertView show];
                          return;
                        }
                      }
                      [photoImageArray addObject:AssetImage];
                      [[UIApplication sharedApplication]
                          setStatusBarStyle:UIStatusBarStyleDefault];
                      [[NSNotificationCenter defaultCenter]
                          postNotificationName:kTabBarHiddenYESNotification
                                        object:weak_self];
                      weak_self.navigationController.navigationBar.hidden = YES;
                      weak_self.hidesBottomBarWhenPushed = YES;
                      if (weak_self.albumType ==
                          CONTACT_PHOTOLIST_WITH_SETTINGWALL) {
                        NSArray* viewControllers =
                            weak_self.navigationController.viewControllers;
                        if (viewControllers.count > 1) {
                          [weak_self.navigationController
                              popToViewController:
                                  viewControllers[viewControllers.count - 4]
                                         animated:YES];
                        } else {
                          [weak_self.presentingViewController
                                  .presentingViewController
                                  .presentingViewController
                              dismissViewControllerAnimated:YES
                                                 completion:nil];
                        }
                        NSDictionary* dict = [NSDictionary
                            dictionaryWithObject:AssetImage
                                          forKey:@"AssetPhotoImage"];
                        [[NSNotificationCenter defaultCenter]
                            postNotificationName:
                                @"SendImageForSettingImagePhotoView"
                                          object:nil
                                        userInfo:dict];
                      } else if (weak_self.albumType ==
                                     CONTACT_PHOTOLIST_WITH_SIGNING ||
                                 weak_self.albumType ==
                                     CONTACT_PHOTOLIST_WITH_SIGNINGIMAGE) {
                        NSArray* viewControllers =
                            weak_self.navigationController.viewControllers;
                        if (viewControllers.count > 1) {
                          NSInteger viewCount = viewControllers.count - 4;
                          if (viewControllers.count < 4) {
                            viewCount = 0;
                          }
                          [weak_self.navigationController
                              popToViewController:viewControllers[viewCount]
                                         animated:YES];
                        } else {
                          [weak_self.presentingViewController
                                  .presentingViewController
                                  .presentingViewController
                              dismissViewControllerAnimated:YES
                                                 completion:nil];
                        }
                        NSDictionary* dict = @{
                          @"AssetPhotoImage" : AssetImage,
                          @"AlbumType" :
                              [NSNumber numberWithInteger:self.albumType]
                        };
                        [[NSNotificationCenter defaultCenter]
                            postNotificationName:
                                @"SendHostCoverImageForPrepareLiveView"
                                          object:nil
                                        userInfo:dict];
                      }
                      // 发布动态（旧的
                      /*
            else {
                SendMyDynamicViewController *sendMyDynamicView = [[SendMyDynamicViewController alloc] initWithArray:photoImageArray] ;
                if (weak_self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE) {
                    sendMyDynamicView.isfromeHomePageBtn = YES;
                }else {
                    sendMyDynamicView.isfromeHomePageBtn = NO;
                }
                sendMyDynamicView.isPhotoAlbum = YES;
                sendMyDynamicView.pushFlg = 1;
                UIViewController *currentVC = [[AppDelegate appDelegate] getNewCurrentViewController];
                if (!currentVC.navigationController) {
                    [currentVC presentViewController:sendMyDynamicView animated:YES completion:^{
                    }];
                }else{
                    [currentVC.navigationController pushViewController:sendMyDynamicView animated:NO];
                }
            }
            */
                    } else {
                      dispatch_after(
                          dispatch_time(DISPATCH_TIME_NOW,
                                        (int64_t)(0.4 * NSEC_PER_SEC)),
                          dispatch_get_main_queue(), ^{
                            [[AppDelegate appDelegate]
                                appDontCoverLoadingViewShowForContext:
                                    @"请在系统相册下载iCloud图片后重试"
                                                          ForTypeShow:1
                                               ForChangeFrameSizeType:0
                                                          ForFrameFlg:YES
                                                        ForCancelTime:2];
                          });
                      NSArray* viewControllers =
                          weak_self.navigationController.viewControllers;
                      if (viewControllers.count > 1) {
                        [weak_self.navigationController
                            popToViewController:viewControllers
                                                    [viewControllers.count - 4]
                                       animated:YES];
                      } else {
                        [weak_self.presentingViewController
                                .presentingViewController
                                .presentingViewController
                            dismissViewControllerAnimated:YES
                                               completion:nil];
                      }
                    }
                  }];
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
