//
//  VideoRecordViewController.m
//  iShow
//
//  Created by 胡阳阳 on 17/3/8.
//
//
#import "macros_mobile_local_defines.h"
#import "VideoRecordViewController.h"
#import "VideoCameraView.h"
#import "TZImagePickerController.h"
#import "ISVideoCameraTools.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "EditingPublishingDynamicViewController.h"
#import "MBProgressHUD.h"
#import "EditVideoViewController.h"
#import "ISEditingPhotoController.h"
#import "ISPublishDynamicViewController.h"
#import "ISActiveLabelView.h"

@interface VideoRecordViewController () <VideoCameraViewDelegate,
                                         TZImagePickerControllerDelegate> {
  MBProgressHUD* HUD;
}
// 标签视图
@property(nonatomic, strong) ISActiveLabelView* activeLabelView;

@end

@implementation VideoRecordViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    _activeId = 0;
    _actTitle = @"";
  }
  return self;
}

// 活动标签视图
- (ISActiveLabelView*)activeLabelView {
  if (!_activeLabelView) {
    _activeLabelView =
        [[ISActiveLabelView alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    [_activeLabelView setActiveBtnEnabled:NO];
    [_activeLabelView setActiveAccessImageViewHidden:YES];
    [self.view addSubview:_activeLabelView];
    [self.view bringSubviewToFront:_activeLabelView];
  }
  return _activeLabelView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor whiteColor];
  /********************异地登录与被踢出等异常频道引起，退出通知********************/
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(RemoteLogin)
                                               name:@"RemoteLogin"
                                             object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:YES];

  self.tabBarController.tabBar.hidden = YES;
  ISLog(@"%@创建了", self.class);
  [self createVideoCameraView];
  [self createActiveLabelView];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  ISLog(@"%@即将消失", self.class);
}

- (void)viewDidAppear:(BOOL)animated {
  [ISPageStatisticsManager
      pageviewStartWithName:ISPageStatisticsCommonVideoRecord];
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [ISPageStatisticsManager
      pageviewEndWithName:ISPageStatisticsCommonVideoRecord];
  [super viewDidDisappear:animated];
}

- (void)clickBackHome {
  if (self.pageFromFlg == ISPublishDynamicProgressPageHome) {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTabBarHiddenNONotification
                      object:self];
  }
  [self.navigationController popViewControllerAnimated:NO];
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
// 活动标签
- (void)createActiveLabelView {
  if (self.activeId > 0) {
    self.activeLabelView.activeBlock = nil;

    [self.activeLabelView setActiveNameWithNameString:self.actTitle];
    [self.activeLabelView mas_makeConstraints:^(MASConstraintMaker* make) {
      make.top.mas_equalTo(kStatusAndNavBarHeight + 10);
      make.left.mas_equalTo(15.0);
      make.height.mas_equalTo(25.0);
    }];
  }
}

- (void)createVideoCameraView {
  bool needNewVideoCamera = YES;
  for (UIView* subView in self.view.subviews) {
    if ([subView isKindOfClass:[VideoCameraView class]]) {
      needNewVideoCamera = NO;
    }
  }
  if (needNewVideoCamera) {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    CGRect frame = [[UIScreen mainScreen] bounds];
    VideoCameraView* videoCameraView =
        [[VideoCameraView alloc] initWithFrame:frame
                                   WithMaxTime:10.0
                                   WithMinTime:3.0];
    videoCameraView.videoCameraType = VideoCameraViewTypeVideo;
    ISLog(@"new VideoCameraView");
    videoCameraView.delegate = self;
    [self.view addSubview:videoCameraView];
  }
}

#pragma mark - delegate -
// 视频拍摄完成
- (void)didFinishVideoRecord:(NSArray<NSURL*>*)urlArr
                goToNextPage:(void (^)(void))goToNextPage;
{
  HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  HUD.labelText = @"视频生成中...";
  NSString* path = [ISVideoCameraTools getVideoMergeFilePathString];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [self mergeAndExportVideos:[urlArr copy]
                                  withOutPath:path
                                 goToNextPage:goToNextPage];
                 });
}
// 拍照完成
- (void)didFinishTakePhoto:(UIImage*)image
              goToNextPage:(void (^)(void))goToNextPage {
  ISEditingPhotoController* photoController =
      [[ISEditingPhotoController alloc] init];
  photoController.photoImage = image;
  photoController.isPrivateAlbum = _isPrivateAlbum;
  photoController.pageFromFlg = _pageFromFlg;
  photoController.activeId = _activeId;
  photoController.actTitle = _actTitle;
  self.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:photoController animated:NO];
  // _showTip = NO;
  if (goToNextPage) {
    goToNextPage();
  }
}

// 退出
- (void)didClickBackToHomeBtn {
  [self clickBackHome];
}
// 导入 手机视频 或者 图片
- (void)didClickInputLocalPhotoOrVideoBtn:(void (^)(void))goToNextPage {
  TZImagePickerController* imagePickerVc = [[TZImagePickerController alloc]
      initWithMaxImagesCount:DYNAMICPHOTOMAXCOUNT
                    delegate:self];
  imagePickerVc.isSelectOriginalPhoto = NO;
  imagePickerVc.allowTakePicture = NO;
  imagePickerVc.allowPickingImage = YES;
  imagePickerVc.allowPickingGif = NO;
  imagePickerVc.allowPickingVideo = YES;
  imagePickerVc.sortAscendingByModificationDate = YES;

  [imagePickerVc setDidFinishPickingPhotosWithInfosHandle:^(
                     NSArray<UIImage*>* photos, NSArray* assets,
                     BOOL isSelectOriginalPhoto,
                     NSArray<NSDictionary*>* infos) {
    NSMutableArray* imageArr = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 0; i < photos.count; i++) {
      UIImage* image = photos[i];
      NSData* imageData = UIImagePNGRepresentation(image);
      NSDictionary* dic = infos[i];
      NSString* dataUTI =
          [NSString stringWithFormat:@"%@", dic[@"PHImageFileUTIKey"]];

      PHAsset* asset = assets[i];
      NSDictionary* imageDict = @{
        KDictKeyTypeData : imageData,
        KDictKeyTypeString : dataUTI,
        KDictKeyTypeIdentifier : asset.localIdentifier
      };
      [imageArr addObject:imageDict];
    }

    ISPublishDynamicViewController* publishDynamic =
        [[ISPublishDynamicViewController alloc] init];
    publishDynamic.privateType = _isPrivateAlbum;
    publishDynamic.pageFromFlg = _pageFromFlg;
    publishDynamic.imageArray = imageArr;
    publishDynamic.activeId = _activeId;
    publishDynamic.actTitle = _actTitle;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:publishDynamic animated:YES];

    if (goToNextPage) {
      goToNextPage();
    }
  }];

  [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage* coverImage,
                                                  id asset) {
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"视频导出中...";
    if (iOS8Later) {
      PHAsset* myasset = asset;
      PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
      options.version = PHImageRequestOptionsVersionCurrent;
      options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
      PHImageManager* manager = [PHImageManager defaultManager];
      [manager
          requestAVAssetForVideo:myasset
                         options:options
                   resultHandler:^(AVAsset* _Nullable asset,
                                   AVAudioMix* _Nullable audioMix,
                                   NSDictionary* _Nullable info) {
                     ISLog(@"%@", info);

                     dispatch_async(dispatch_get_main_queue(), ^{
                       // AVComposition
                       if (![asset isKindOfClass:[AVURLAsset class]]) {
                         HUD.labelText = @"暂不支持的视频格式";
                         [HUD hide:YES afterDelay:1.5];
                         return;
                       }

                       [self
                           compressVideo:asset
                              completion:^(BOOL isSucceed, NSURL* videoUrl) {
                                if (isSucceed == NO) {
                                  HUD.labelText =
                                      @"视"
                                      @"频导入失败，请稍后重试！";
                                  [HUD hide:YES afterDelay:1.5];
                                  return;
                                }

                                NSData* videoData = [NSData
                                    dataWithContentsOfFile:
                                        [[videoUrl absoluteString]
                                            stringByReplacingOccurrencesOfString:
                                                @"file://"
                                                                      withString:
                                                                          @""]];
                                //
                                if (videoData.length > 1024 * 1024 * 20) {
                                  HUD.labelText =
                                      @"所选视频大于20M,"
                                      @"请重新选择";
                                  [HUD hide:YES afterDelay:1.5];
                                } else {
                                  EditingPublishingDynamicViewController*
                                      editingPublishVC = [
                                          [EditingPublishingDynamicViewController
                                              alloc] init];
                                  editingPublishVC.videoURL = videoUrl;
                                  editingPublishVC.pageFromFlg = _pageFromFlg;
                                  editingPublishVC.isPriveteDynamicType =
                                      _isPrivateAlbum;
                                  editingPublishVC.activeId = _activeId;
                                  editingPublishVC.actTitle = _actTitle;
                                  self.hidesBottomBarWhenPushed = YES;
                                  [self.navigationController
                                      pushViewController:editingPublishVC
                                                animated:YES];
                                  [HUD hide:YES afterDelay:0];
                                  if (goToNextPage) {
                                    goToNextPage();
                                  }
                                }
                              }];
                     });
                   }];

    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        ALAsset* myasset = asset;
        NSURL* videoURL = [myasset valueForProperty:ALAssetPropertyAssetURL];
        NSURL* url = videoURL;
        NSData* videoData =
            [NSData dataWithContentsOfFile:
                        [[url absoluteString]
                            stringByReplacingOccurrencesOfString:@"file://"
                                                      withString:@""]];
        if (videoData.length > 1024 * 1024 * 20) {
          HUD.labelText = @"所选视频大于20M,请重新选择";
          [HUD hide:YES afterDelay:1.5];
        } else {
          EditingPublishingDynamicViewController* cor =
              [[EditingPublishingDynamicViewController alloc] init];
          cor.videoURL = url;
          cor.pageFromFlg = _pageFromFlg;
          cor.isPriveteDynamicType = self.isPrivateAlbum;
          cor.activeId = _activeId;
          cor.actTitle = _actTitle;
          self.hidesBottomBarWhenPushed = YES;
          [self.navigationController pushViewController:cor animated:YES];
          [HUD hide:YES afterDelay:0];
          if (goToNextPage) {
            goToNextPage();
          }
        }
      });
    }
    ISLog(@"选择结束");
  }];

  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [[AppDelegate appDelegate] presentViewController:imagePickerVc
                                          animated:YES
                                        completion:^{
                                        }];
}

#pragma mark - private -
// 压缩视频
- (void)compressVideo:(AVAsset*)asset
           completion:(void (^)(BOOL isSucceed, NSURL* videoUrl))completion {
  NSInteger seconds = [ISVideoCameraTools getVideoTime:asset];
  // 武立翠规定只能传60s以内的，主要是压缩时间过长
  if (seconds > 60 * 1) {
    ISLog(@"上传的视频时过大");
    HUD.labelText = @"所选视频大于60s,请重新选择";
    [HUD hide:YES afterDelay:1.5];
    return;
  }

  CGSize naturalSize = [ISVideoCameraTools getVideoNaturalSize:asset];
  CGFloat videoWidthStandard = 360.f;
  CGFloat videoHeightStandard = 640.f;

  CGFloat videoWidth = naturalSize.width;
  CGFloat videoHeight = naturalSize.height;

  ISLog(@"视频分辨率：宽：%f * 高：%f", videoWidth, videoHeight);  // 宽高
  if (videoWidth <= videoWidthStandard || videoHeight <= videoHeightStandard) {
    // 视频分辨率已经低，不压缩，直接返回
    AVURLAsset* urlAsset = (AVURLAsset*)asset;
    if (completion) {
      completion(YES, urlAsset.URL);
    }
    return;
  }

  [ISVideoCameraTools
      compressVideoThroughSystemMehtod:asset
                            completion:^(BOOL isSucceed, NSURL* videoUrl) {
                              if (completion) {
                                completion(isSucceed, videoUrl);
                              }
                            }];
}

- (void)mergeAndExportVideos:(NSArray*)videosPathArray
                 withOutPath:(NSString*)outpath
                goToNextPage:(void (^)(void))goToNextPage {
  //    http://blog.csdn.net/ismilesky/article/details/51920113  视频与音乐合成
  //    http://www.jianshu.com/p/0f9789a6d99a 视频与音乐合成

  if (videosPathArray.count == 0) {
    if (HUD.hidden == NO) {
      [HUD hide:YES];
    }
    return;
  }
  AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
  AVMutableCompositionTrack* audioTrack = [mixComposition
      addMutableTrackWithMediaType:AVMediaTypeAudio
                  preferredTrackID:kCMPersistentTrackID_Invalid];
  AVMutableCompositionTrack* videoTrack = [mixComposition
      addMutableTrackWithMediaType:AVMediaTypeVideo
                  preferredTrackID:kCMPersistentTrackID_Invalid];

  //    UIImage *waterImg = [UIImage imageNamed:@"LDWatermark"];
  CMTime totalDuration = kCMTimeZero;
  for (int i = 0; i < videosPathArray.count; i++) {
    //        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL
    //        URLWithString:videosPathArray[i]]];
    NSDictionary* options =
        @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    AVAsset* asset =
        [AVURLAsset URLAssetWithURL:videosPathArray[i] options:options];

    NSError* erroraudio = nil;
    // 获取AVAsset中的音频 或者视频
    AVAssetTrack* assetAudioTrack =
        [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    // 向通道内加入音频或者视频
    BOOL ba =
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetAudioTrack
                             atTime:totalDuration
                              error:&erroraudio];

    ISLog(@"erroraudio:%@%d", erroraudio, ba);
    NSError* errorVideo = nil;
    AVAssetTrack* assetVideoTrack =
        [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    BOOL bl =
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetVideoTrack
                             atTime:totalDuration
                              error:&errorVideo];

    ISLog(@"errorVideo:%@%d", errorVideo, bl);
    totalDuration = CMTimeAdd(totalDuration, asset.duration);
  }
  ISLog(@"%@", NSHomeDirectory());

  // 视频水印
  CGSize videoSize = [videoTrack naturalSize];
  /*
   CALayer *aLayer = [CALayer layer];
   aLayer.contents = (id)waterImg.CGImage;
   aLayer.frame = CGRectMake(videoSize.width - waterImg.size.width - 30,
   videoSize.height - waterImg.size.height*3, waterImg.size.width,
   waterImg.size.height);
   aLayer.opacity = 0.9;
   */
  CALayer* parentLayer = [CALayer layer];
  CALayer* videoLayer = [CALayer layer];
  parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
  videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
  [parentLayer addSublayer:videoLayer];
  /*
   [parentLayer addSublayer:aLayer];
   */
  AVMutableVideoComposition* videoComp =
      [AVMutableVideoComposition videoComposition];
  videoComp.renderSize = videoSize;

  videoComp.frameDuration = CMTimeMake(1, 30);
  videoComp.animationTool = [AVVideoCompositionCoreAnimationTool
      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                                              inLayer:
                                                                  parentLayer];
  AVMutableVideoCompositionInstruction* instruction =
      [AVMutableVideoCompositionInstruction videoCompositionInstruction];

  instruction.timeRange =
      CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
  AVAssetTrack* mixVideoTrack =
      [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
  AVMutableVideoCompositionLayerInstruction* layerInstruction =
      [AVMutableVideoCompositionLayerInstruction
          videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
  instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
  videoComp.instructions = [NSArray arrayWithObject:instruction];

  NSURL* mergeFileURL = [NSURL fileURLWithPath:outpath];
  // 压缩
  AVAssetExportSession* exporter =
      [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                       presetName:AVAssetExportPreset1280x720];
  exporter.videoComposition = videoComp;
  /*
   exporter.progress
   导出进度
   This property is not key-value observable.
   不支持kvo 监听
   只能用定时器监听了  NStimer
   */
  exporter.outputURL = mergeFileURL;
  exporter.outputFileType = AVFileTypeQuickTimeMovie;
  exporter.shouldOptimizeForNetworkUse = YES;
  [exporter exportAsynchronouslyWithCompletionHandler:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      EditVideoViewController* editVC = [[EditVideoViewController alloc] init];
      editVC.videoURL = [NSURL fileURLWithPath:outpath];
      ;
      editVC.pageFromFlg = _pageFromFlg;
      editVC.isPrivateAlbum = _isPrivateAlbum;
      editVC.activeId = _activeId;
      editVC.actTitle = _actTitle;
      self.hidesBottomBarWhenPushed = YES;
      [self.navigationController pushViewController:editVC animated:YES];
      if (HUD.hidden == NO) {
        [HUD hide:YES];
      }
      if (goToNextPage) {
        goToNextPage();
      }
    });
  }];
}

#pragma mark - other -
- (void)RemoteLogin {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kTabBarHiddenNONotification
                    object:self];
  [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  ISLog(@"%@释放了", self.class);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
