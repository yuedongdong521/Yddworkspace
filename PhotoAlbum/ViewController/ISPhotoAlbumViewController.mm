//
//  ISPhotoAlbumViewController.m
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import "ISPhotoAlbumViewController.h"
#import "ISPhotoPreviewViewController.h"
#import "ISImageLibraryViewController.h"
#import "ISAlbumListViewController.h"
#import "ISSingleImagePreviewView.h"
#import "ISCustomNavigationView.h"
#import "ISPhotoAlbumViewCell.h"
#import "ISPhotoAlbumModel.h"
#import "ISAssetsManager.h"
#import "AFNetworking.h"
#import "ISResizePicViewController.h"
#import "ISMessageCentralManager.h"

@interface ISPhotoAlbumViewController () <UICollectionViewDelegate,
                                          UICollectionViewDataSource,
                                          ISPhotoAlbumViewCellDelegate>

@property(nonatomic, strong) ISCustomNavigationView* customNavicationView;
@property(nonatomic, strong) UICollectionView* photoCollectionView;
@property(nonatomic, strong) NSArray* photoImageArray;
@property(nonatomic, strong) NSMutableArray* chooseImgArray;

@property(nonatomic, assign) int photoCount;
@property(nonatomic, assign) float imageCount;

@property(nonatomic, strong) UIView* toolbar;
@property(nonatomic, strong) UIButton* previewBtn;
@property(nonatomic, strong) UIButton* originalBtn;
@property(nonatomic, strong) UIButton* sendBtn;
@property(nonatomic, strong) UILabel* numberLable;

@end

@implementation ISPhotoAlbumViewController

#pragma mark - init
- (instancetype)init {
  self = [super init];
  if (self) {
    _albumType = 0;
    _hasImageCount = 0;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // 表示从SessionChatViewController进入TalkViewController,标识
  [AppDelegate appDelegate].ssSpeedingPushTag = SPEEDINGPUSHTAG_SCLibraryNew;
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor colorWithRed:239.0f / 255.0f
                                              green:239.0f / 255.0f
                                               blue:244.0f / 255.0f
                                              alpha:1];
  [[AppDelegate sharedAppDelegate] appcmLoadingViewShowForContext:@"正在加载..."
                                                      ForTypeShow:0
                                           ForCurrentLieEventType:0
                                                      ForFrameFlg:0];

  self.photoCount = 0;
  self.imageCount = 0.0;
  _photoImageArray = [[NSArray alloc] init];
  _chooseImgArray = [[NSMutableArray alloc] init];

  [self.view addSubview:self.customNavicationView];
  [self.view addSubview:self.photoCollectionView];

  self.customNavicationView.titleLabel.text =
      self.assetCollection.localizedTitle;
  // 聊天页|自定义表情页|发布动态页|首页发布动态页
  if (self.albumType == CONTACT_PHOTOLIST_WITH_SESSIONCHAT ||
      self.albumType == CONTACT_PHOTOLIST_WITH_EXPRESSIONS ||
      CONTACT_PHOTOLIST_WITH_DYNAMIC == self.albumType ||
      CONTACT_PHOTOLIST_WITH_HOMEPAGE == self.albumType) {
    [self createToolbarView];
  } else {
    self.photoCollectionView.frame =
        CGRectMake(0, kStatusAndNavBarHeight, ScreenWidth,
                   ScreenHeight - kStatusAndNavBarHeight);
  }
  [self getAllAlbumsPhoto];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(RemoteLogin)
                                               name:kRemoteLoginNotify
                                             object:nil];
}

- (void)RemoteLogin {
  [self.navigationController popViewControllerAnimated:YES];
  [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)getAllAlbumsPhoto {
  /*if (self.assetCollection) {*/  // 图片源
  _photoImageArray = [[ISAssetsManager sharedInstancetype]
      enumerateAssetsWithAssetCollection:self.assetCollection];
  /*}else {
     PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
     _photoImageArray = [[ISAssetsManager sharedInstancetype] enumerateAssetsWithAssetCollection:cameraRoll];
     }*/
  [[AppDelegate appDelegate] cancelCmLoadingView:0.0];
  if (_photoImageArray.count > 0) {
    [self.photoCollectionView reloadData];
    // scroll to bottom
    long cellRow = [self collectionView:self.photoCollectionView
                       numberOfItemsInSection:0] -
                   1;
    if (cellRow >= 0) {
      NSIndexPath* indexPath =
          [NSIndexPath indexPathForRow:cellRow inSection:0];
      [self.photoCollectionView
          scrollToItemAtIndexPath:indexPath
                 atScrollPosition:UICollectionViewScrollPositionBottom
                         animated:NO];
    }
  } else {
    UIAlertView* alert =
        [[UIAlertView alloc] initWithTitle:@"提 示"
                                   message:@"加载出错，获取图片失败"
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil];
    [alert show];
    return;
  }
}

- (void)createToolbarView {
  self.toolbar = [[UIView alloc]
      initWithFrame:CGRectMake(0, ScreenHeight - 50 - IS_TABBAR_ADD_HEIGHT,
                               ScreenWidth, 50)];
  self.toolbar.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.toolbar];

  self.previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 70, 30)];
  self.previewBtn.enabled = NO;
  [self.previewBtn setTitle:@"预览" forState:UIControlStateNormal];
  [self.previewBtn setTitleColor:blackLableColor forState:UIControlStateNormal];
  [self.previewBtn setTitleColor:grayLableColor
                        forState:UIControlStateDisabled];
  [self.previewBtn
      setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
  self.previewBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
  [self.previewBtn addTarget:self
                      action:@selector(previewPhotoImageAction)
            forControlEvents:UIControlEventTouchUpInside];

  self.originalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  self.originalBtn.frame = CGRectMake(87, 10, 100, 30);
  self.originalBtn.enabled = NO;
  self.originalBtn.selected = NO;
  [self.originalBtn
      setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                    pathForResource:KBselect_no
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
  [self.originalBtn setTitleColor:grayLableColor forState:UIControlStateNormal];
  [self.originalBtn addTarget:self
                       action:@selector(getOriginalImageAction:)
             forControlEvents:UIControlEventTouchUpInside];
  self.numberLable =
      [[UILabel alloc] initWithFrame:CGRectMake(150, 10, 120, 30)];
  self.numberLable.backgroundColor = [UIColor clearColor];
  self.numberLable.text = @"";
  self.numberLable.textColor = blackLableColor;

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
  [self.sendBtn setFrame:CGRectMake(ScreenWidth - 80, 9, 70, 32)];
  [self.sendBtn setBackgroundColor:[UIColor colorWithRed:210.0 / 256.0
                                                   green:210.0 / 256.0
                                                    blue:210.0 / 256.0
                                                   alpha:1.0]];
  [self.sendBtn setTitle:sendBtnTitle forState:UIControlStateNormal];
  [self.sendBtn setTitleColor:blackLableColor forState:UIControlStateNormal];
  [self.sendBtn setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateDisabled];
  self.sendBtn.enabled = NO;
  [self.sendBtn.layer setCornerRadius:5.0];
  self.sendBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
  [self.sendBtn addTarget:self
                   action:@selector(sendPhotoImageToSessionChatView)
         forControlEvents:UIControlEventTouchUpInside];

  [self.toolbar addSubview:self.sendBtn];
  [self.toolbar addSubview:self.previewBtn];
  [self.toolbar addSubview:self.originalBtn];
  [self.toolbar addSubview:self.numberLable];
}

- (ISCustomNavigationView*)customNavicationView {
  if (_customNavicationView == nil) {
    _customNavicationView = [[ISCustomNavigationView alloc]
        initWithTitle:nil
                 left:[UIImage imageWithContentsOfFile:
                                   [[NSBundle mainBundle]
                                       pathForResource:@"goBackAlbumlist@2x"
                                                ofType:kPngName]]
                right:@"取消"];
    __weak __typeof(self) weakSelf = self;
    _customNavicationView.event = ^(ISCustomNavigationEventType eventType) {
      __strong __typeof(weakSelf) strongSelf = weakSelf;
      if (eventType == ISCustomNavigationLeftEvent) {
        [strongSelf leftBtnPressed];
      } else if (eventType == ISCustomNavigationRightEvent) {
        [strongSelf rightBtnPressed];
      }
    };
    [_customNavicationView.rightButton setTitleColor:blackLableColor
                                            forState:UIControlStateNormal];
    _customNavicationView.rightButton.titleLabel.font =
        [UIFont systemFontOfSize:17.0];
    _customNavicationView.frame =
        CGRectMake(0, 0, ScreenWidth, kStatusAndNavBarHeight);
  }
  return _customNavicationView;
}

- (UICollectionView*)photoCollectionView {
  if (_photoCollectionView == nil) {
    UICollectionViewFlowLayout* photoFlowLayout =
        [[UICollectionViewFlowLayout alloc] init];
    photoFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    photoFlowLayout.minimumInteritemSpacing = 0;
    photoFlowLayout.minimumLineSpacing = 2;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _photoCollectionView = [[UICollectionView alloc]
               initWithFrame:CGRectMake(0, kStatusAndNavBarHeight, ScreenWidth,
                                        ScreenHeight - 50 -
                                            kStatusAndNavBarHeight -
                                            IS_TABBAR_ADD_HEIGHT)
        collectionViewLayout:photoFlowLayout];
    _photoCollectionView.delegate = self;
    _photoCollectionView.dataSource = self;
    _photoCollectionView.backgroundColor = [UIColor clearColor];
    [_photoCollectionView registerClass:[ISPhotoAlbumViewCell class]
             forCellWithReuseIdentifier:@"photoCell"];
  }
  return _photoCollectionView;
}

#pragma mark UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return _photoImageArray.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
  ISPhotoAlbumViewCell* cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell"
                                                forIndexPath:indexPath];
  cell.delegate = self;
  cell.photoImageView.contentMode = UIViewContentModeScaleAspectFill;

  ISPhotoAlbumModel* albumMode = _photoImageArray[indexPath.row];
  PHAsset* asset = albumMode.asset;

  CGSize size = CGSizeMake((ScreenWidth - 5) / 4 * ScreenScale,
                           (ScreenWidth - 5) / 4 * ScreenScale);
  [[ISAssetsManager sharedInstancetype]
      posterImageWithPHAsset:asset
               imageWithSize:size
                 contentMode:PHImageContentModeAspectFill
                  completion:^(UIImage* AssetImage) {
                    if (AssetImage) {
                      cell.photoImageView.image = AssetImage;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^(void){

                                   });
                  }];

  cell.chooseBut.tag = indexPath.row + 100;
  // 聊天页|自定义表情页|发布动态页|首页发布动态页
  if (self.albumType == CONTACT_PHOTOLIST_WITH_SESSIONCHAT ||
      self.albumType == CONTACT_PHOTOLIST_WITH_EXPRESSIONS ||
      self.albumType == CONTACT_PHOTOLIST_WITH_DYNAMIC ||
      self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE) {
    cell.chooseBut.hidden = NO;
  } else {
    cell.chooseBut.hidden = YES;
  }
  if (albumMode.assetBool) {
    cell.chooseBut.selected = YES;
  } else {
    cell.chooseBut.selected = NO;
  }
  return cell;
}

- (void)collectionView:(UICollectionView*)collectionView
    didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
  // 聊天页|自定义表情页|发布动态页|首页发布动态页
  if (self.albumType == CONTACT_PHOTOLIST_WITH_SESSIONCHAT ||
      self.albumType == CONTACT_PHOTOLIST_WITH_EXPRESSIONS ||
      self.albumType == CONTACT_PHOTOLIST_WITH_DYNAMIC ||
      self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE) {
    [self pushPhotoPreviewViewWithIndexPathRow:indexPath.row
                               photoImageArray:_photoImageArray];
  } else if (self.albumType == CONTACT_PHOTOLIST_WITH_DYNAMIC_VIDEO_COVER) {
    ISPhotoAlbumModel* albumModel = _photoImageArray[indexPath.row];
    CGSize size = [self getSizeWithAsset:albumModel.asset];
    [[ISAssetsManager sharedInstancetype]
        posterImageWithPHAsset:albumModel.asset
                 imageWithSize:size
                   contentMode:PHImageContentModeAspectFit
                    completion:^(UIImage* AssetImage) {
                      if (AssetImage) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                          ISResizePicViewController* vc =
                              [[ISResizePicViewController alloc] init];
                          vc.selectedImage = AssetImage;
                          UIViewController* currentVC =
                              [[AppDelegate appDelegate]
                                  getNewCurrentViewController];
                          if (!currentVC.navigationController) {
                            [currentVC presentViewController:vc
                                                    animated:YES
                                                  completion:^{
                                                  }];
                          } else {
                            [currentVC.navigationController
                                pushViewController:vc
                                          animated:YES];
                          }
                        });
                      }
                    }];
  } else if (self.albumType == CONTACT_PHOTOLIST_WITH_HEADER ||
             self.albumType == CONTACT_PHOTOLIST_WITH_GUILDCOVER ||
             self.albumType == CONTACT_PHOTOLIST_WITH_HOSTCOVER ||
             self.albumType == CONTACT_PHOTOLIST_WITH_FRIENTINFO ||
             self.albumType == CONTACT_PHOTOLIST_WITH_VIDEO_COVER) {
    ISPhotoAlbumModel* albumModel = _photoImageArray[indexPath.row];
    CGSize size = [self getSizeWithAsset:albumModel.asset];
    [[ISAssetsManager sharedInstancetype]
        posterImageWithPHAsset:albumModel.asset
                 imageWithSize:size
                   contentMode:PHImageContentModeAspectFit
                    completion:^(UIImage* AssetImage) {
                      if (AssetImage) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                          ISImageLibraryViewController* imageLibrary =
                              [[ISImageLibraryViewController alloc] init];
                          if (self.albumType ==
                              CONTACT_PHOTOLIST_WITH_GUILDCOVER) {
                            imageLibrary.pushFlg = 1;
                          } else {
                            imageLibrary.pushFlg = 2;
                          }
                          imageLibrary.albumType = self.albumType;
                          imageLibrary.originalImages = AssetImage;
                          UIViewController* currentVC =
                              [[AppDelegate appDelegate]
                                  getNewCurrentViewController];
                          if (!currentVC.navigationController) {
                            [currentVC presentViewController:imageLibrary
                                                    animated:YES
                                                  completion:^{
                                                  }];
                          } else {
                            [currentVC.navigationController
                                pushViewController:imageLibrary
                                          animated:YES];
                          }
                        });
                      }
                    }];
  }
  // 原来动态
  else {
    ISSingleImagePreviewView* singleImgPreview =
        [[ISSingleImagePreviewView alloc] init];
    singleImgPreview.albumModel = _photoImageArray[indexPath.row];
    singleImgPreview.albumType = self.albumType;
    UIViewController* currentVC =
        [[AppDelegate appDelegate] getNewCurrentViewController];
    if (!currentVC.navigationController) {
      [currentVC presentViewController:singleImgPreview
                              animated:YES
                            completion:^{
                            }];
    } else {
      [currentVC.navigationController pushViewController:singleImgPreview
                                                animated:YES];
    }
  }
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                    layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath*)indexPath {
  return CGSizeMake((ScreenWidth - 5) / 4, (ScreenWidth - 5) / 4);
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

- (void)pushPhotoPreviewViewWithIndexPathRow:(NSInteger)row
                             photoImageArray:(NSArray*)photoImageArray {
  ISPhotoPreviewViewController* photoPreviewView =
      [[ISPhotoPreviewViewController alloc] init];
  photoPreviewView.photoArray = photoImageArray;
  photoPreviewView.chooseImageArray = _chooseImgArray;
  photoPreviewView.cellCount = row;
  photoPreviewView.photoImageSize = self.imageCount;
  photoPreviewView.isBtnSelected = self.originalBtn.selected;
  photoPreviewView.albumType = self.albumType;
  photoPreviewView.hasImageCount = self.hasImageCount;
  photoPreviewView.originalBtn.selected = self.originalBtn.selected;
  __weak typeof(&*self) weakSelf = self;
  photoPreviewView.backPhotoAlbumView =
      ^(BOOL isBtnSelect, NSMutableArray* chooseImageArray) {
        weakSelf.photoCount = 0;
        weakSelf.imageCount = 0.0;
        weakSelf.numberLable.text = @"";
        weakSelf.originalBtn.selected = isBtnSelect;
        _chooseImgArray = chooseImageArray;
        if (_chooseImgArray.count > 0) {
          if (isBtnSelect) {
            for (ISPhotoAlbumModel* albumModel in _chooseImgArray) {
              weakSelf.photoCount++;
              [weakSelf getOriginalImageSizeWithAlbumModel:albumModel];
            }
          }
        }
        [self refreshPhotoAlbumView];
        [self.photoCollectionView reloadData];
      };
  UIViewController* currentVC =
      [[AppDelegate appDelegate] getNewCurrentViewController];
  if (!currentVC.navigationController) {
    [currentVC presentViewController:photoPreviewView
                            animated:YES
                          completion:^{
                          }];
  } else {
    [currentVC.navigationController pushViewController:photoPreviewView
                                              animated:YES];
  }
}

// 选中按钮
- (void)chooseNo:(UIButton*)chooseBt {
  if (_chooseImgArray.count + self.hasImageCount == AbleToSelectPicCount &&
      !chooseBt.selected) {
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
  ISPhotoAlbumModel* albumModel = _photoImageArray[chooseBt.tag - 100];
  chooseBt.selected = !chooseBt.selected;
  if (chooseBt.selected) {
    albumModel.assetBool = YES;
    self.photoCount++;
    [_chooseImgArray addObject:albumModel];
    if (self.originalBtn.selected) {
      [self getOriginalImageSizeWithAlbumModel:albumModel];
    }
  } else {
    albumModel.assetBool = NO;
    self.photoCount--;
    [_chooseImgArray removeObject:albumModel];
    if (self.originalBtn.selected) {
      self.imageCount -= albumModel.imageSize;
      if (self.imageCount > 0.85) {
        self.numberLable.text =
            [NSString stringWithFormat:@"(%.1lfM)", self.imageCount];
      } else {
        self.numberLable.text = [NSString
            stringWithFormat:@"(%ldK)", (long)(self.imageCount * 1024.0)];
      }
    }
  }
  [self refreshPhotoAlbumView];
}

- (void)refreshPhotoAlbumView {
  // 发送按钮内容
  NSString* sendBtnTitle = @"发送";
  if (self.albumType == CONTACT_PHOTOLIST_WITH_EXPRESSIONS) {
    sendBtnTitle = @"添加";
  } else if (self.albumType == CONTACT_PHOTOLIST_WITH_DYNAMIC ||
             self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE) {
    sendBtnTitle = @"确定";
  }

  if (_chooseImgArray.count > 0) {
    self.sendBtn.enabled = YES;
    self.previewBtn.enabled = YES;
    self.originalBtn.enabled = YES;
    [self.sendBtn setFrame:CGRectMake(ScreenWidth - 100, 9, 90, 32)];
    [self.sendBtn setBackgroundColor:yellowBtnColor];
    [self.originalBtn setTitleColor:blackLableColor
                           forState:UIControlStateNormal];
    [self.previewBtn
        setTitle:[NSString
                     stringWithFormat:@"预览(%lu)",
                                      (unsigned long)_chooseImgArray.count]
        forState:UIControlStateNormal];
    [self.sendBtn
        setTitle:[NSString
                     stringWithFormat:@"%@(%lu/%ld)", sendBtnTitle,
                                      (unsigned long)_chooseImgArray.count,
                                      (long)(AbleToSelectPicCount -
                                             self.hasImageCount)]
        forState:UIControlStateNormal];
  } else {
    self.imageCount = 0.0;
    self.numberLable.text = @"";
    self.sendBtn.enabled = NO;
    self.previewBtn.enabled = NO;
    self.originalBtn.enabled = NO;
    [self.sendBtn setFrame:CGRectMake(ScreenWidth - 80, 9, 70, 32)];
    [self.sendBtn setBackgroundColor:[UIColor colorWithRed:210.0 / 256.0
                                                     green:210.0 / 256.0
                                                      blue:210.0 / 256.0
                                                     alpha:1.0]];
    [self.originalBtn setTitleColor:grayLableColor
                           forState:UIControlStateNormal];
    [self.previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [self.sendBtn setTitle:sendBtnTitle forState:UIControlStateNormal];
  }
}

- (void)previewPhotoImageAction {
  NSMutableArray* photoImgMutArray = [_chooseImgArray mutableCopy];
  [self pushPhotoPreviewViewWithIndexPathRow:0
                             photoImageArray:photoImgMutArray];
}

- (void)getOriginalImageAction:(UIButton*)sender {
  self.originalBtn.selected = !self.originalBtn.selected;
  self.photoCount = 0;
  self.imageCount = 0.0;
  self.numberLable.text = @"";
  if (self.originalBtn.selected) {
    // 选中原图
    for (ISPhotoAlbumModel* albumModel in _chooseImgArray) {
      self.photoCount++;
      [self getOriginalImageSizeWithAlbumModel:albumModel];
    }
  }
}

- (void)getOriginalImageSizeWithAlbumModel:(ISPhotoAlbumModel*)albumModel {
  if (albumModel.imageSize > 0) {
    self.imageCount += albumModel.imageSize;
    if (self.photoCount == _chooseImgArray.count) {
      if (self.imageCount > 0.85) {
        self.numberLable.text =
            [NSString stringWithFormat:@"(%.1lfM)", self.imageCount];
      } else {
        self.numberLable.text = [NSString
            stringWithFormat:@"(%ldK)", (long)(self.imageCount * 1024.0)];
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
                                weak_self.imageCount += dataLength;
                                albumModel.imageSize = dataLength;
                                // albumModel.originalImage = [UIImage imageWithData:assetData];
                                if (weak_self.photoCount ==
                                    _chooseImgArray.count) {
                                  if (weak_self.imageCount > 0.85) {
                                    self.numberLable.text = [NSString
                                        stringWithFormat:@"(%.1lfM)",
                                                         weak_self.imageCount];
                                  } else {
                                    self.numberLable.text = [NSString
                                        stringWithFormat:
                                            @"(%ldK)",
                                            (long)(weak_self.imageCount *
                                                   1024.0)];
                                  }
                                }
                              });
                            }];
  }
}

// 发送按钮事件
- (void)sendPhotoImageToSessionChatView {
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
  if (self.albumType == CONTACT_PHOTOLIST_WITH_EXPRESSIONS) {
    // 添加到表情
    NSArray* viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 3) {
      [self.navigationController
          popToViewController:viewControllers[viewControllers.count - 3]
                     animated:YES];
    } else {
      [self.presentingViewController.presentingViewController
          dismissViewControllerAnimated:YES
                             completion:nil];
    }

    [self noticeAddExpressionForImageData];

    return;
  }
  // 发布动态
  else if (self.albumType == CONTACT_PHOTOLIST_WITH_DYNAMIC) {
    NSArray* viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 3) {
      [self.navigationController
          popToViewController:viewControllers[viewControllers.count - 3]
                     animated:YES];
    } else {
      [self.presentingViewController.presentingViewController
          dismissViewControllerAnimated:YES
                             completion:nil];
    }

    [self noticeAddPublishDynamicWithPageType:ISPublishDynamicNormal];

    return;
  }
  // 发布私密动态
  else if (self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE) {
    NSArray* viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 3) {
      [self.navigationController
          popToViewController:viewControllers[viewControllers.count - 3]
                     animated:YES];
    } else {
      [self.presentingViewController.presentingViewController
          dismissViewControllerAnimated:YES
                             completion:nil];
    }

    [self noticeAddPublishDynamicWithPageType:ISPublishDynamicPrivite];

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
  if (viewControllers.count > 1) {
    [self.navigationController
        popToViewController:viewControllers[viewControllers.count - 3]
                   animated:YES];
    [self notificationCenter];
  } else {
    [self.presentingViewController.presentingViewController
        dismissViewControllerAnimated:YES
                           completion:nil];
    [self notificationCenter];
  }
}

// 发布动态
- (void)noticeAddPublishDynamicWithPageType:(NSInteger)pageType {
  // 不区分原图缩略图
  NSMutableArray* chooseImageDataArray = [NSMutableArray arrayWithCapacity:0];
  for (ISPhotoAlbumModel* albumModel in self.chooseImgArray) {
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
                           self.chooseImgArray.count) {
                         dispatch_async(dispatch_get_main_queue(), ^(void) {
                           // [[AppDelegate appDelegate] appcmLoadingViewShowForContext:@"正在添加.." ForTypeShow:0 ForCurrentLieEventType:0 ForFrameFlg:0];
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

// 添加表情功能
- (void)noticeAddExpressionForImageData {
  // 不区分原图缩略图
  NSMutableArray* chooseImageDataArray = [NSMutableArray arrayWithCapacity:0];
  for (ISPhotoAlbumModel* albumModel in self.chooseImgArray) {
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
                           self.chooseImgArray.count) {
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

- (void)notificationCenter {
  if (self.originalBtn.selected) {
    NSMutableArray* photoImageArray = [[NSMutableArray alloc] init];
    for (ISPhotoAlbumModel* albumModel in _chooseImgArray) {
      [[ISAssetsManager sharedInstancetype]
          posterImageWithPHAsset:albumModel.asset
                   imageWithSize:PHImageManagerMaximumSize
                     contentMode:PHImageContentModeAspectFill
                      completion:^(UIImage* AssetImage) {
                        if (AssetImage) {
                          [photoImageArray addObject:AssetImage];
                          if (photoImageArray.count == _chooseImgArray.count) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                              [[NSNotificationCenter defaultCenter]
                                  postNotificationName:@"sendPho"
                                                object:[photoImageArray copy]];
                            });
                          }
                        }
                      }];
    }
  } else {
    NSMutableArray* photoImageArray = [[NSMutableArray alloc] init];
    for (ISPhotoAlbumModel* albumModel in _chooseImgArray) {
      CGSize size = [self getSizeWithAsset:albumModel.asset];
      [[ISAssetsManager sharedInstancetype]
          posterImageWithPHAsset:albumModel.asset
                   imageWithSize:size
                     contentMode:PHImageContentModeAspectFit
                      completion:^(UIImage* AssetImage) {
                        if (AssetImage) {
                          [photoImageArray addObject:AssetImage];
                          if (photoImageArray.count == _chooseImgArray.count) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                              [[NSNotificationCenter defaultCenter]
                                  postNotificationName:@"sendPho"
                                                object:[photoImageArray copy]];
                            });
                          }
                        }
                      }];
    }
  }
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
  if (self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE) {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTabBarHiddenNONotification
                      object:self];
  } else {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTabBarHiddenYESNotification
                      object:self];
  }

  // TODO:zhanglei 此处消失代码需要多处使用，删除时需要慎重
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count == 2) {
    // 聊天逻辑
    if ([[ISMessageCentralManager manager]
            checkVersionIsIMFoundationRebuildVersion:
                IMFoundationRebuildVersion]) {
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"dismissNotification"
                        object:nil];
      return;
    }

    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
  }

  if ([AppDelegate appDelegate].sessionViewBGView.isGlobalSession == YES) {
    [AppDelegate appDelegate].sessionBackImgView.hidden = NO;
    [AppDelegate appDelegate].sessionChatBGView.hidden = NO;
  }
  if (viewControllers.count > 4) {
    [self.navigationController
        popToViewController:viewControllers[viewControllers.count - 3]
                   animated:YES];
  } else {
    [self.presentingViewController.presentingViewController
        dismissViewControllerAnimated:YES
                           completion:nil];
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
