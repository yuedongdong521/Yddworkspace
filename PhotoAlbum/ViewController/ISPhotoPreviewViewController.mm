//
//  ISPhotoPreviewViewController.m
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import "ISPhotoPreviewViewController.h"
#import "ISCustomNavigationView.h"
#import "ISPhotoAlbumModel.h"
#import "ISAssetsManager.h"
#import "ISPhotoImageViewCell.h"
#import "AFNetworking.h"

#import "ISMessageCentralManager.h"

@interface ISPhotoPreviewViewController () <UICollectionViewDelegate,
                                            UICollectionViewDataSource>

@property(nonatomic, strong) ISCustomNavigationView* customNavicationView;
@property(nonatomic, strong) UICollectionView* bigImageCollectionView;

@property(nonatomic, strong) UIView* toolbarView;
@property(nonatomic, strong) UIButton* sendBtn;
@property(nonatomic, strong) UILabel* imageSizeLable;

@property(nonatomic, assign) BOOL isSelectItem;
@property(nonatomic, assign) NSUInteger photoCount;
@property(nonatomic, assign) NSUInteger cellNumber;

@property(nonatomic, strong) NSMutableArray* scrollArray;

@end

@implementation ISPhotoPreviewViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent];

  self.isSelectItem = NO;
  self.scrollArray = [[NSMutableArray alloc] init];
  self.photoCount = self.chooseImageArray.count;
  self.cellNumber = self.cellCount;

  [self.view addSubview:self.bigImageCollectionView];
  [self.view addSubview:self.customNavicationView];

  [self createToolbarView];

  ISPhotoAlbumModel* albumMode = self.photoArray[self.cellCount];
  if ([self.chooseImageArray containsObject:albumMode]) {
    self.customNavicationView.rightButton.selected = YES;
  } else {
    self.customNavicationView.rightButton.selected = NO;
  }

  NSIndexPath* indexPath =
      [NSIndexPath indexPathForRow:self.cellCount inSection:0];
  [self.bigImageCollectionView
      scrollToItemAtIndexPath:indexPath
             atScrollPosition:UICollectionViewScrollPositionRight
                     animated:NO];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (UICollectionView*)bigImageCollectionView {
  if (!_bigImageCollectionView) {
    UICollectionViewFlowLayout* photoFlowLayout =
        [[UICollectionViewFlowLayout alloc] init];
    photoFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    photoFlowLayout.minimumInteritemSpacing = 0.1;
    photoFlowLayout.minimumLineSpacing = 0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _bigImageCollectionView = [[UICollectionView alloc]
               initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        collectionViewLayout:photoFlowLayout];
    _bigImageCollectionView.delegate = self;
    _bigImageCollectionView.dataSource = self;
    // 开启分页
    _bigImageCollectionView.pagingEnabled = YES;
    // 隐藏水平滚动条
    _bigImageCollectionView.showsHorizontalScrollIndicator = NO;
    _bigImageCollectionView.backgroundColor = [UIColor blackColor];
    [_bigImageCollectionView registerClass:[ISPhotoImageViewCell class]
                forCellWithReuseIdentifier:@"photoImageCell"];
  }
  return _bigImageCollectionView;
}

- (ISCustomNavigationView*)customNavicationView {
  if (!_customNavicationView) {
    _customNavicationView = [[ISCustomNavigationView alloc]
        initWithTitle:[NSString
                          stringWithFormat:@"%lu/%lu",
                                           (unsigned long)self.cellCount + 1,
                                           (unsigned long)self.photoArray.count]
                 left:[UIImage imageWithContentsOfFile:
                                   [[NSBundle mainBundle]
                                       pathForResource:kBSBackBtnImage
                                                ofType:kPngName]]
                right:[UIImage imageWithContentsOfFile:
                                   [[NSBundle mainBundle]
                                       pathForResource:KSelect_no
                                                ofType:kPngName]]];
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
    _customNavicationView.titleLabel.textColor = [UIColor whiteColor];
    _customNavicationView.rightButton.selected = NO;
    [_customNavicationView.rightButton
        setImage:[UIImage
                     imageWithContentsOfFile:[[NSBundle mainBundle]
                                                 pathForResource:KSelect_yes
                                                          ofType:kPngName]]
        forState:UIControlStateSelected];
  }
  return _customNavicationView;
}

- (void)createToolbarView {
  self.toolbarView = [[UIView alloc]
      initWithFrame:CGRectMake(0, ScreenHeight - 44 - IS_TABBAR_ADD_HEIGHT,
                               ScreenWidth, 44 + IS_TABBAR_ADD_HEIGHT)];
  self.toolbarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
  [self.view addSubview:self.toolbarView];

  self.originalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  self.originalBtn.frame = CGRectMake(13, 7, 80, 30);
  [self.originalBtn
      setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                    pathForResource:KYselect_no
                                                             ofType:kPngName]]
      forState:UIControlStateNormal];
  [self.originalBtn
      setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                    pathForResource:KYselect_yes
                                                             ofType:kPngName]]
      forState:UIControlStateSelected];
  [self.originalBtn setTitle:@" 原图" forState:UIControlStateNormal];
  [self.originalBtn
      setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
  [self.originalBtn setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
  [self.originalBtn addTarget:self
                       action:@selector(getOriginalImageAction:)
             forControlEvents:UIControlEventTouchUpInside];

  self.imageSizeLable =
      [[UILabel alloc] initWithFrame:CGRectMake(75, 7, 120, 30)];
  self.imageSizeLable.backgroundColor = [UIColor clearColor];
  self.imageSizeLable.textColor = [UIColor whiteColor];
  if (self.isBtnSelected) {
    self.originalBtn.selected = YES;
    if (self.photoImageSize > 0.85) {
      self.imageSizeLable.text =
          [NSString stringWithFormat:@"(%.1lfM)", self.photoImageSize];
    } else {
      self.imageSizeLable.text = [NSString
          stringWithFormat:@"(%ldK)", (long)(self.photoImageSize * 1024.0)];
    }
  } else {
    self.originalBtn.selected = NO;
    self.imageSizeLable.text = @"";
  }

  // 发送按钮内容
  NSString* sendBtnTitle = @"发送";
  if (self.albumType == CONTACT_PHOTOLIST_WITH_EXPRESSIONS) {
    sendBtnTitle = @"添加";
  } else if (self.albumType == CONTACT_PHOTOLIST_WITH_DYNAMIC ||
             self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE) {
    sendBtnTitle = @"确定";
  }
  self.sendBtn = [[UIButton alloc] init];
  self.sendBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
  if (self.chooseImageArray.count > 0) {
    [self.sendBtn setFrame:CGRectMake(ScreenWidth - 105, 7, 90, 30)];
    [self.sendBtn
        setTitle:[NSString stringWithFormat:@"%@(%lu/%ld)", sendBtnTitle,
                                            (unsigned long)
                                                self.chooseImageArray.count,
                                            (long)(AbleToSelectPicCount -
                                                   self.hasImageCount)]
        forState:UIControlStateNormal];
  } else {
    [self.sendBtn setFrame:CGRectMake(ScreenWidth - 85, 7, 70, 30)];
    [self.sendBtn setTitle:sendBtnTitle forState:UIControlStateNormal];
  }
  [self.sendBtn setBackgroundColor:yellowBtnColor];
  [self.sendBtn setTitleColor:blackLableColor forState:UIControlStateNormal];
  [self.sendBtn.layer setCornerRadius:5.0];
  [self.sendBtn addTarget:self
                   action:@selector(sendPhotoImageToSessionChatView)
         forControlEvents:UIControlEventTouchUpInside];

  [self.toolbarView addSubview:self.sendBtn];
  [self.toolbarView addSubview:self.originalBtn];
  [self.toolbarView addSubview:self.imageSizeLable];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  if (self.bigImageCollectionView == scrollView) {
    CGPoint offset = scrollView.contentOffset;
    self.cellNumber = offset.x / ScreenWidth;
    ISPhotoAlbumModel* albumMode = self.photoArray[self.cellNumber];
    if ([self.chooseImageArray containsObject:albumMode]) {
      self.customNavicationView.rightButton.selected = YES;
    } else {
      self.customNavicationView.rightButton.selected = NO;
    }
    NSUInteger titleNum = self.cellNumber + 1;
    self.customNavicationView.titleLabel.text =
        [NSString stringWithFormat:@"%ld/%lu", (long)titleNum,
                                   (unsigned long)self.photoArray.count];
  }
}

#pragma mark UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.photoArray.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
  ISPhotoImageViewCell* cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:@"photoImageCell"
                                                forIndexPath:indexPath];
  cell.contentView.backgroundColor = [UIColor clearColor];

  cell.photoImageView.tag = indexPath.row + 100;
  ISPhotoAlbumModel* albumMode = self.photoArray[indexPath.row];

  PHAsset* asset = albumMode.asset;
  CGSize size = [self getSizeWithAsset:asset];
  [[ISAssetsManager sharedInstancetype]
      posterImageWithPHAsset:asset
               imageWithSize:size
                 contentMode:PHImageContentModeAspectFit
                  completion:^(UIImage* AssetImage) {
                    if (AssetImage) {
                      cell.photoImageView.image = AssetImage;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                                   });
                  }];
  return cell;
}

- (void)collectionView:(UICollectionView*)collectionView
    didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
  self.isSelectItem = !self.isSelectItem;
  float offsetY = 0.0;
  float offsetY1 = 0.0;
  if (self.isSelectItem) {
    offsetY = -kStatusAndNavBarHeight;
    offsetY1 = ScreenHeight;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
  } else {
    offsetY = 0;
    offsetY1 = ScreenHeight - 44;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
  }
  [UIView setAnimationsEnabled:YES];
  [UIView animateWithDuration:0.3
                   animations:^{
                     self.customNavicationView.frame = CGRectMake(
                         0, offsetY, ScreenWidth, kStatusAndNavBarHeight);
                     self.toolbarView.frame =
                         CGRectMake(0, offsetY1, ScreenWidth, 44);
                   }
                   completion:^(BOOL finished){

                   }];
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                    layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath*)indexPath {
  return CGSizeMake(ScreenWidth, ScreenHeight);
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

- (void)getOriginalImageAction:(UIButton*)sender {
  self.originalBtn.selected = !self.originalBtn.selected;
  self.photoCount = 0;
  self.photoImageSize = 0.0;
  self.imageSizeLable.text = @"";
  if (self.originalBtn.selected) {
    // 选中原图
    if (self.chooseImageArray.count == 0 &&
        !_customNavicationView.rightButton.selected) {
      [self rightBtnPressed];
    } else {
      for (ISPhotoAlbumModel* albumModel in self.chooseImageArray) {
        self.photoCount++;
        [self getOriginalImageSizeWithAlbumModel:albumModel];
      }
    }
  }
}

- (void)getOriginalImageSizeWithAlbumModel:(ISPhotoAlbumModel*)albumModel {
  if (albumModel.imageSize > 0) {
    self.photoImageSize += albumModel.imageSize;
    if (self.photoCount == self.chooseImageArray.count) {
      if (self.photoImageSize > 0.85) {
        self.imageSizeLable.text =
            [NSString stringWithFormat:@"(%.1lfM)", self.photoImageSize];
      } else {
        self.imageSizeLable.text = [NSString
            stringWithFormat:@"(%ldK)", (long)(self.photoImageSize * 1024.0)];
      }
    }
  } else {
    __weak typeof(&*self) weak_self = self;
    [[ISAssetsManager sharedInstancetype]
        posterOriginalImageWithPHAsset:albumModel.asset
                            completion:^(NSData* assetData) {
                              dispatch_async(dispatch_get_main_queue(), ^(
                                                 void) {
                                float dataLength =
                                    assetData.length / (1024.0 * 1024.0);
                                weak_self.photoImageSize += dataLength;
                                albumModel.imageSize = dataLength;
                                // albumModel.originalImage = [UIImage imageWithData:assetData];
                                if (weak_self.photoCount ==
                                    weak_self.chooseImageArray.count) {
                                  if (weak_self.photoImageSize > 0.85) {
                                    self.imageSizeLable.text = [NSString
                                        stringWithFormat:@"(%.1lfM)",
                                                         weak_self
                                                             .photoImageSize];
                                  } else {
                                    self.imageSizeLable.text = [NSString
                                        stringWithFormat:
                                            @"(%ldK)",
                                            (long)(weak_self.photoImageSize *
                                                   1024.0)];
                                  }
                                }
                              });
                            }];
  }
}

// 发送或添加功能
- (void)sendPhotoImageToSessionChatView {
  if (self.albumType == CONTACT_PHOTOLIST_WITH_EXPRESSIONS) {
    // 添加到表情

    NSArray* viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 4) {
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
      [self.navigationController
          popToViewController:viewControllers[viewControllers.count - 4]
                     animated:YES];
      [self noticeAddExpressionForImageData];
    } else {
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
      [self.presentingViewController.presentingViewController
              .presentingViewController dismissViewControllerAnimated:YES
                                                           completion:nil];
      [self noticeAddExpressionForImageData];
    }

    return;
  }
  // 发布动态
  else if (self.albumType == CONTACT_PHOTOLIST_WITH_DYNAMIC) {
    NSArray* viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 4) {
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
      [self.navigationController
          popToViewController:viewControllers[viewControllers.count - 4]
                     animated:YES];
    } else {
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
      [self.presentingViewController.presentingViewController
              .presentingViewController dismissViewControllerAnimated:YES
                                                           completion:nil];
    }

    [self noticeAddPublishDynamicWithPageType:ISPublishDynamicNormal];

    return;
  }
  // 发布私密动态
  else if (self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE) {
    NSArray* viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 4) {
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
      [self.navigationController
          popToViewController:viewControllers[viewControllers.count - 4]
                     animated:YES];
    } else {
      [[UIApplication sharedApplication] setStatusBarHidden:NO];
      [self.presentingViewController.presentingViewController
              .presentingViewController dismissViewControllerAnimated:YES
                                                           completion:nil];
    }
    [self noticeAddPublishDynamicWithPageType:ISPublishDynamicPrivite];

    return;
  }

  if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus <
      AFNetworkReachabilityStatusReachableViaWWAN) {
    UIAlertView* aleatView =
        [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                   message:@"当前网络不可用，请检查您的网络设置"
                                  delegate:self
                         cancelButtonTitle:@"知道了"
                         otherButtonTitles:nil, nil];
    [aleatView show];
    return;
  }
  // 聊天逻辑

  if ([[ISMessageCentralManager manager]
          checkVersionIsIMFoundationRebuildVersion:
              IMFoundationRebuildVersion]) {
    [self notificationCenter];
    return;
  }

  [[NSNotificationCenter defaultCenter]
      postNotificationName:kTabBarHiddenYESNotification
                    object:self];
  if ([AppDelegate appDelegate].sessionViewBGView.isGlobalSession == YES) {
    [AppDelegate appDelegate].sessionBackImgView.hidden = NO;
    [AppDelegate appDelegate].sessionChatBGView.hidden = NO;
  }
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 4) {
    [self.navigationController
        popToViewController:viewControllers[viewControllers.count - 4]
                   animated:YES];
    [self notificationCenter];
  } else {
    [self.presentingViewController.presentingViewController
            .presentingViewController dismissViewControllerAnimated:YES
                                                         completion:nil];
    [self notificationCenter];
  }
}

// 发布动态
- (void)noticeAddPublishDynamicWithPageType:(NSInteger)pageType {
  // 预览选中图片
  if (self.chooseImageArray.count > 0) {
    // 不区分原图缩略图
    NSMutableArray* chooseImageDataArray = [NSMutableArray arrayWithCapacity:0];
    for (ISPhotoAlbumModel* albumModel in self.chooseImageArray) {
      // 暂时用data，也可以用image
      [[ISAssetsManager sharedInstancetype]
          judgeImageWithPHAsset:albumModel.asset
                     completion:^(NSData* imageData, NSString* dataUTI) {
                       if (imageData && dataUTI) {
                         NSDictionary* imageDict = @{
                           KDictKeyTypeData : imageData,
                           KDictKeyTypeString : dataUTI,
                           KDictKeyTypeIdentifier :
                               albumModel.asset.localIdentifier
                         };
                         [chooseImageDataArray addObject:imageDict];
                         if (chooseImageDataArray.count ==
                             self.chooseImageArray.count) {
                           dispatch_async(dispatch_get_main_queue(), ^(void) {
                             [[NSNotificationCenter defaultCenter]
                                 postNotificationName:@"NotifyAddDynamicPhoto"
                                               object:[chooseImageDataArray
                                                          copy]];
                           });
                         }
                       } else {
                         [[AppDelegate appDelegate]
                             appDontCoverLoadingViewShowForContext:
                                 @"请在系统相册下载iCloud图片后重试"
                                                       ForTypeShow:1
                                            ForChangeFrameSizeType:0
                                                       ForFrameFlg:0
                                                     ForCancelTime:2.0];
                       }
                     }];
    }
  }
  // 预览未选中图片
  else {
    if (self.cellNumber < self.photoArray.count) {
      ISPhotoAlbumModel* albumModel = self.photoArray[self.cellNumber];
      // 暂时用data，也可以用image
      [[ISAssetsManager sharedInstancetype]
          judgeImageWithPHAsset:albumModel.asset
                     completion:^(NSData* imageData, NSString* dataUTI) {
                       if (imageData && dataUTI) {
                         NSDictionary* imageDict = @{
                           KDictKeyTypeData : imageData,
                           KDictKeyTypeString : dataUTI,
                           KDictKeyTypeIdentifier :
                               albumModel.asset.localIdentifier
                         };
                         NSArray* chooseImageArray =
                             [NSArray arrayWithObject:imageDict];
                         dispatch_async(dispatch_get_main_queue(), ^(void) {
                           [[NSNotificationCenter defaultCenter]
                               postNotificationName:@"NotifyAddDynamicPhoto"
                                             object:chooseImageArray.copy];
                         });
                       } else {
                         [[AppDelegate appDelegate]
                             appDontCoverLoadingViewShowForContext:
                                 @"请在系统相册下载iCloud图片后重试"
                                                       ForTypeShow:1
                                            ForChangeFrameSizeType:0
                                                       ForFrameFlg:0
                                                     ForCancelTime:2.0];
                       }
                     }];
    }
  }
}

// 添加表情功能
- (void)noticeAddExpressionForImageData {
  // 预览选中图片
  if (self.chooseImageArray.count > 0) {
    // 不区分原图缩略图
    NSMutableArray* chooseImageDataArray = [[NSMutableArray alloc] init];
    for (ISPhotoAlbumModel* albumModel in self.chooseImageArray) {
      [[ISAssetsManager sharedInstancetype]
          judgeImageWithPHAsset:albumModel.asset
                     completion:^(NSData* imageData, NSString* dataUTI) {
                       if (imageData && dataUTI) {
                         NSDictionary* imageDict = @{
                           KDictKeyTypeData : imageData,
                           KDictKeyTypeString : dataUTI,
                           KDictKeyTypeIdentifier :
                               albumModel.asset.localIdentifier
                         };
                         [chooseImageDataArray addObject:imageDict];
                         if (chooseImageDataArray.count ==
                             self.chooseImageArray.count) {
                           dispatch_async(dispatch_get_main_queue(), ^(void) {
                             [[AppDelegate appDelegate]
                                 appcmLoadingViewShowForContext:@"正在添加.."
                                                    ForTypeShow:0
                                         ForCurrentLieEventType:0
                                                    ForFrameFlg:0];
                             [[NSNotificationCenter defaultCenter]
                                 postNotificationName:
                                     @"NotifyAddExpressionsImage"
                                               object:[chooseImageDataArray
                                                          copy]];
                           });
                         }
                       } else {
                         [[AppDelegate appDelegate]
                             appDontCoverLoadingViewShowForContext:
                                 @"请在系统相册下载iCloud图片后重试"
                                                       ForTypeShow:1
                                            ForChangeFrameSizeType:0
                                                       ForFrameFlg:0
                                                     ForCancelTime:2.0];
                       }
                     }];
    }
  }
  // 预览未选中图片
  else {
    if (self.cellNumber < self.photoArray.count) {
      // 不区分原图缩略图
      NSMutableArray* chooseImageDataArray = [[NSMutableArray alloc] init];
      ISPhotoAlbumModel* albumModel = self.photoArray[self.cellNumber];
      // CGSize size = [self getSizeWithAsset:albumModel.asset];
      [[ISAssetsManager sharedInstancetype]
          judgeImageWithPHAsset:albumModel.asset
                     completion:^(NSData* imageData, NSString* dataUTI) {
                       if (imageData && dataUTI) {
                         NSDictionary* imageDict = @{
                           KDictKeyTypeData : imageData,
                           KDictKeyTypeString : dataUTI,
                           KDictKeyTypeIdentifier :
                               albumModel.asset.localIdentifier
                         };
                         [chooseImageDataArray addObject:imageDict];

                         dispatch_async(dispatch_get_main_queue(), ^(void) {
                           [[AppDelegate appDelegate]
                               appcmLoadingViewShowForContext:@"正在添加.."
                                                  ForTypeShow:0
                                       ForCurrentLieEventType:0
                                                  ForFrameFlg:0];
                           [[NSNotificationCenter defaultCenter]
                               postNotificationName:@"NotifyAddExpressionsImage"
                                             object:[chooseImageDataArray
                                                        copy]];
                         });
                       } else {
                         [[AppDelegate appDelegate]
                             appDontCoverLoadingViewShowForContext:
                                 @"请在系统相册下载iCloud图片后重试"
                                                       ForTypeShow:1
                                            ForChangeFrameSizeType:0
                                                       ForFrameFlg:0
                                                     ForCancelTime:2.0];
                       }
                     }];
    }
  }
}

- (void)notificationCenter {
  // 预览选中图片
  if (self.chooseImageArray.count > 0) {
    if (self.originalBtn.selected) {
      NSMutableArray* chooseImageArray = [[NSMutableArray alloc] init];
      for (ISPhotoAlbumModel* albumModel in self.chooseImageArray) {
        [[ISAssetsManager sharedInstancetype]
            posterImageWithPHAsset:albumModel.asset
                     imageWithSize:PHImageManagerMaximumSize
                       contentMode:PHImageContentModeAspectFill
                        completion:^(UIImage* AssetImage) {
                          if (AssetImage) {
                            [chooseImageArray addObject:AssetImage];
                            if (chooseImageArray.count ==
                                self.chooseImageArray.count) {
                              dispatch_async(
                                  dispatch_get_main_queue(), ^(void) {
                                    [[NSNotificationCenter defaultCenter]
                                        postNotificationName:@"sendPho"
                                                      object:[chooseImageArray
                                                                 copy]];
                                  });
                            }
                          }
                        }];
      }
    } else {
      NSMutableArray* chooseImageArray = [[NSMutableArray alloc] init];
      for (ISPhotoAlbumModel* albumModel in self.chooseImageArray) {
        CGSize size = [self getSizeWithAsset:albumModel.asset];
        [[ISAssetsManager sharedInstancetype]
            posterImageWithPHAsset:albumModel.asset
                     imageWithSize:size
                       contentMode:PHImageContentModeAspectFit
                        completion:^(UIImage* AssetImage) {
                          if (AssetImage) {
                            [chooseImageArray addObject:AssetImage];
                            if (chooseImageArray.count ==
                                self.chooseImageArray.count) {
                              dispatch_async(
                                  dispatch_get_main_queue(), ^(void) {
                                    [[NSNotificationCenter defaultCenter]
                                        postNotificationName:@"sendPho"
                                                      object:[chooseImageArray
                                                                 copy]];
                                  });
                            }
                          }
                        }];
      }
    }
  }
  // 预览未选中图片
  else {
    if (self.cellNumber < self.photoArray.count) {
      ISPhotoAlbumModel* albumModel = self.photoArray[self.cellNumber];
      CGSize size = [self getSizeWithAsset:albumModel.asset];
      [[ISAssetsManager sharedInstancetype]
          posterImageWithPHAsset:albumModel.asset
                   imageWithSize:size
                     contentMode:PHImageContentModeAspectFit
                      completion:^(UIImage* AssetImage) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                          if (AssetImage) {
                            NSArray* photoImageArray =
                                [NSArray arrayWithObject:AssetImage];
                            [[NSNotificationCenter defaultCenter]
                                postNotificationName:@"sendPho"
                                              object:photoImageArray];
                          }
                        });
                      }];
    }
  }
}

- (void)leftBtnPressed {
  self.backPhotoAlbumView(self.originalBtn.selected, self.chooseImageArray);
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)rightBtnPressed {
  if (self.chooseImageArray.count ==
          AbleToSelectPicCount - self.hasImageCount &&
      !_customNavicationView.rightButton.selected) {
    NSString* tips = [NSString
        stringWithFormat:@"你最多只能选择%ld张照片",
                         (long)(AbleToSelectPicCount - self.hasImageCount)];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:tips
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
    return;
  }
  _customNavicationView.rightButton.selected =
      !_customNavicationView.rightButton.selected;
  ISPhotoAlbumModel* albumModel = self.photoArray[self.cellNumber];
  if (_customNavicationView.rightButton.selected) {
    // 选中
    albumModel.assetBool = YES;
    self.photoCount++;
    [self.chooseImageArray addObject:albumModel];
    if (self.originalBtn.selected) {
      [self getOriginalImageSizeWithAlbumModel:albumModel];
    }
  } else {
    albumModel.assetBool = NO;
    self.photoCount--;
    [self.chooseImageArray removeObject:albumModel];
    if (self.originalBtn.selected) {
      self.photoImageSize -= albumModel.imageSize;
      if (self.photoImageSize > 0.85) {
        self.imageSizeLable.text =
            [NSString stringWithFormat:@"(%.1lfM)", self.photoImageSize];
      } else {
        self.imageSizeLable.text = [NSString
            stringWithFormat:@"(%ldK)", (long)(self.photoImageSize * 1024.0)];
      }
    }
  }

  // 发送按钮内容
  NSString* sendBtnTitle = @"发送";
  if (self.albumType == CONTACT_PHOTOLIST_WITH_EXPRESSIONS) {
    sendBtnTitle = @"添加";
  } else if (self.albumType == CONTACT_PHOTOLIST_WITH_DYNAMIC ||
             self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE) {
    sendBtnTitle = @"确定";
  }
  if (self.chooseImageArray.count > 0) {
    self.sendBtn.frame = CGRectMake(ScreenWidth - 105, 7, 90, 30);
    [self.sendBtn
        setTitle:[NSString stringWithFormat:@"%@(%lu/%ld)", sendBtnTitle,
                                            (unsigned long)
                                                self.chooseImageArray.count,
                                            (long)(AbleToSelectPicCount -
                                                   self.hasImageCount)]
        forState:UIControlStateNormal];
  } else {
    self.photoCount = 0;
    self.photoImageSize = 0.0;
    self.imageSizeLable.text = @"";
    self.sendBtn.frame = CGRectMake(ScreenWidth - 85, 7, 70, 30);
    [self.sendBtn setTitle:sendBtnTitle forState:UIControlStateNormal];
  }
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
