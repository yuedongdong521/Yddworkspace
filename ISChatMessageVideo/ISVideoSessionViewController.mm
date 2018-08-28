//
//  ISVideoSessionViewController.m
//  iShow
//
//  Created by ispeak on 2018/1/3.
//

#import "ISVideoSessionViewController.h"
#import "VideoCameraView.h"
#import "SDAVAssetExportSession.h"
#import "ISVideoCameraTools.h"
#import "TZImagePickerController.h"
#import <Photos/Photos.h>
#import "MBProgressHUD.h"

#define VideoWidth 360
#define VideoHeight 360
#define VideoWHRate 1.0

@interface ISVideoSessionViewController () <VideoCameraViewDelegate,
                                            TZImagePickerControllerDelegate>

@property(nonatomic, strong) NSArray<NSURL*>* videoPaths;
@property(nonatomic, strong) MBProgressHUD* hud;

@end

@implementation ISVideoSessionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor blackColor];
  _videoPaths = [NSMutableArray array];

  VideoCameraView* videoCameraView =
      [[VideoCameraView alloc] initWithFrame:self.view.bounds
                                 WithMaxTime:10.0
                                 WithMinTime:0];
  videoCameraView.videoCameraType = VideoCameraViewTypeVideoSession;
  videoCameraView.delegate = self;
  [self.view addSubview:videoCameraView];

  UIImage* image = [UIImage imageNamed:@"iSpeakWatermark"];
  UIImageView* imageView = [[UIImageView alloc]
      initWithFrame:CGRectMake(ScreenWidth - (60 + 5),
                               (ScreenHeight - ScreenWidth) * 0.5 + 5, 60,
                               image.size.height / image.size.width * 60)];
  imageView.contentMode = UIViewContentModeScaleAspectFill;
  imageView.backgroundColor = [UIColor clearColor];
  imageView.image = image;
  [self.view addSubview:imageView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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

- (void)didClickBackToHomeBtn {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didFinishTakePhoto:(UIImage*)image
              goToNextPage:(void (^)(void))goToNextPage {
}

- (void)didClickInputLocalPhotoOrVideoBtn:(void (^)())goToNextPage {
  TZImagePickerController* imagePickerVc =
      [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
  imagePickerVc.isSelectOriginalPhoto = NO;
  imagePickerVc.allowTakePicture = NO;
  imagePickerVc.allowPickingImage = NO;
  imagePickerVc.allowPickingGif = NO;
  imagePickerVc.allowPickingVideo = YES;
  imagePickerVc.sortAscendingByModificationDate = YES;

  [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage* coverImage,
                                                  id asset) {
    if (iOS8Later) {
      PHAsset* myasset = asset;
      PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
      options.version = PHVideoRequestOptionsVersionCurrent;
      options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
      PHImageManager* manager = [PHImageManager defaultManager];
      [manager requestAVAssetForVideo:myasset
                              options:options
                        resultHandler:^(AVAsset* _Nullable asset,
                                        AVAudioMix* _Nullable audioMix,
                                        NSDictionary* _Nullable info) {
                          NSLog(@"%@", info);
                          dispatch_async(dispatch_get_main_queue(), ^{
                            _hud = [MBProgressHUD showHUDAddedTo:self.view
                                                        animated:YES];
                            // AVComposition
                            if (![asset isKindOfClass:[AVURLAsset class]]) {
                              _hud.label.text = @"视频格式不支持";
                              [_hud hideAnimated:YES afterDelay:1.0];
                              return;
                            }
                            _hud.label.text = @"视频导出中...";
                            [self videoCompositionForVideoPath:nil
                                                   ForURLAsset:asset
                                                  goToNextPage:goToNextPage];
                          });
                        }];
    }
  }];
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)didFinishVideoRecord:(NSArray<NSURL*>*)urlArr
                goToNextPage:(void (^)())goToNextPage {
  _videoPaths = [urlArr copy];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [self mergeAndExportVideosAtFileURLs:_videoPaths
                                           goToNextPage:goToNextPage];
                 });
}

// 最后合成为 mp4
- (NSString*)getVideoFilePathStringForType:(NSString*)type
                                  FileName:(NSString*)fileName {
  NSString* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;

  NSFileManager* fileManager = [[NSFileManager alloc] init];

  NSDateFormatter* foramtter = [[NSDateFormatter alloc] init];
  foramtter.dateFormat = @"YYYY-MM-dd-HH-mm-ss";
  NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
  NSString* name = [foramtter stringFromDate:date];

  NSString* filePath = [path
      stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@",
                                                                fileName, name,
                                                                type]];
  if ([fileManager fileExistsAtPath:filePath]) {
    [fileManager removeItemAtPath:filePath error:nil];
  }
  return filePath;
}

- (void)mergeAndExportVideosAtFileURLs:(NSArray*)fileURLArray
                          goToNextPage:(void (^)())goToNextPage {
  if (fileURLArray.count < 1) {
    return;
  }
  _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  _hud.labelText = @"视频生成中";

  AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];

  // 初始化音频轨道容器
  AVMutableCompositionTrack* audioTrack = [mixComposition
      addMutableTrackWithMediaType:AVMediaTypeAudio
                  preferredTrackID:kCMPersistentTrackID_Invalid];
  // 初始化视频轨道容器
  AVMutableCompositionTrack* videoTrack = [mixComposition
      addMutableTrackWithMediaType:AVMediaTypeVideo
                  preferredTrackID:kCMPersistentTrackID_Invalid];

  CMTime totalDuration = kCMTimeZero;

  for (int i = 0; i < fileURLArray.count; i++) {
    NSURL* url = fileURLArray[i];
    AVAsset* asset =
        [AVURLAsset URLAssetWithURL:url
                            options:@{
                              AVURLAssetPreferPreciseDurationAndTimingKey : @YES
                            }];

    NSError* audioError = nil;

    // 插入音频，并指定插入时长和插入时间点
    NSArray* audioSourceArray = [asset tracksWithMediaType:AVMediaTypeAudio];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                        ofTrack:([audioSourceArray count] > 0)
                                    ? [audioSourceArray objectAtIndex:0]
                                    : nil
                         atTime:totalDuration
                          error:&audioError];
    if (audioError) {
      NSLog(@"小视屏合成 audioerror = %@", audioError);
    }
    NSError* videoError = nil;
    // 插入视频，并指定插入时长和插入时间点
    NSArray* videoSourceArray = [asset tracksWithMediaType:AVMediaTypeVideo];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                        ofTrack:([videoSourceArray count] > 0)
                                    ? [videoSourceArray objectAtIndex:0]
                                    : nil
                         atTime:totalDuration
                          error:&videoError];
    if (videoError) {
      NSLog(@"小视屏合成 audioerror = %@", videoError);
    }
    totalDuration = CMTimeAdd(totalDuration, asset.duration);
  }

  AVMutableVideoCompositionInstruction* mainInstruciton =
      [AVMutableVideoCompositionInstruction videoCompositionInstruction];
  mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
  AVAssetTrack* mixVideoTrack =
      [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
  AVMutableVideoCompositionLayerInstruction* layerInstruction =
      [AVMutableVideoCompositionLayerInstruction
          videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];

  CGSize renderSize = mixVideoTrack.naturalSize;
  CGFloat renderW = MIN(renderSize.width, renderSize.height);

  mainInstruciton.layerInstructions = @[ layerInstruction ];
  // 创建用来添加AVMutableCompositionTrack的，你可以把它想象成用来调度每个视频次序，时间的这么一个调度器。

  AVMutableVideoComposition* mainComposition =
      [AVMutableVideoComposition videoComposition];
  mainComposition.instructions = @[ mainInstruciton ];
  mainComposition.frameDuration = CMTimeMake(1, 30);
  mainComposition.renderSize = CGSizeMake(renderW, renderW);

  [self addVideoLayerFrame:CGRectMake(0, 0, renderW, renderW)
          VideoCamposition:mainComposition];

  // 视频合成路径
  NSString* path =
      [self getVideoFilePathStringForType:@".mp4" FileName:@"merge"];
  NSURL* mergeFileURL = [NSURL fileURLWithPath:path];

  AVAssetExportSession* exporter =
      [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                       presetName:AVAssetExportPreset640x480];
  exporter.videoComposition = mainComposition;
  exporter.outputURL = mergeFileURL;
  exporter.outputFileType = AVFileTypeMPEG4;
  exporter.shouldOptimizeForNetworkUse = YES;
  [exporter exportAsynchronouslyWithCompletionHandler:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self videoCompositionForVideoPath:mergeFileURL
                             ForURLAsset:nil
                            goToNextPage:goToNextPage];
    });
  }];
}

- (void)addVideoLayerFrame:(CGRect)frame
          VideoCamposition:(AVMutableVideoComposition*)videoComposition {
  CALayer* backgroundLayer = [CALayer layer];
  UIImage* image = [UIImage imageNamed:@"iSpeakWatermark"];
  backgroundLayer.contents = (__bridge id _Nullable)image.CGImage;
  backgroundLayer.frame = CGRectMake(
      frame.size.width - (120 + 10),
      frame.size.height - 10 - (image.size.height / image.size.width * 120),
      120, image.size.height / image.size.width * 120);
  backgroundLayer.masksToBounds = YES;

  CALayer* videoLayer = [CALayer layer];
  videoLayer.frame = frame;

  CALayer* parentLayer = [CALayer layer];
  parentLayer.frame = frame;
  [parentLayer addSublayer:videoLayer];
  [parentLayer addSublayer:backgroundLayer];

  videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                                              inLayer:
                                                                  parentLayer];
}

- (void)videoCompositionForVideoPath:(NSURL*)pathUrl
                         ForURLAsset:(AVAsset*)urlAsset
                        goToNextPage:(void (^)())goToNextPage {
  NSDictionary* options =
      @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
  AVAsset* anAsset;
  if (urlAsset) {
    anAsset = urlAsset;
  } else {
    anAsset = [AVURLAsset URLAssetWithURL:pathUrl options:options];
  }
  CGFloat videoWidth = VideoWidth;
  CGFloat videoHeight = VideoHeight;
  NSArray* videoTrackArr = [anAsset tracksWithMediaType:AVMediaTypeVideo];
  if (videoTrackArr.count > 0) {
    AVAssetTrack* track = videoTrackArr.firstObject;
    if (track.naturalSize.width > 0 && track.naturalSize.height > 0) {
      videoWidth = MIN(videoWidth, track.naturalSize.width);
      videoHeight =
          videoWidth * (track.naturalSize.height / track.naturalSize.width);
    }
  }
  NSArray* keys = @[ @"tracks", @"duration", @"commonMetadata" ];
  [anAsset
      loadValuesAsynchronouslyForKeys:keys
                    completionHandler:^{
                      SDAVAssetExportSession* encoder = [
                          [SDAVAssetExportSession alloc] initWithAsset:anAsset];
                      encoder.outputFileType = AVFileTypeMPEG4;
                      // 视频压缩后输出路径
                      encoder.outputURL = [NSURL
                          fileURLWithPath:
                              [self getVideoFilePathStringForType:@".mp4"
                                                         FileName:@"outVideo"]];
                      encoder.videoSettings = @{
                        AVVideoCodecKey : AVVideoCodecH264,
                        AVVideoWidthKey : [NSNumber numberWithFloat:videoWidth],
                        AVVideoHeightKey :
                            [NSNumber numberWithFloat:videoHeight],
                        AVVideoCompressionPropertiesKey : @{
                          AVVideoAverageBitRateKey : @2000000,
                          AVVideoProfileLevelKey :
                              AVVideoProfileLevelH264HighAutoLevel,
                          AVVideoAverageNonDroppableFrameRateKey : @20
                        },
                      };
                      encoder.audioSettings = @{
                        AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                        AVNumberOfChannelsKey : @2,
                        AVSampleRateKey : @44100,
                        AVEncoderBitRateKey : @128000,
                      };

                      [encoder exportAsynchronouslyWithCompletionHandler:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                          if (pathUrl) {
                            NSString* mergePath = pathUrl.absoluteString;
                            if ([mergePath hasPrefix:@"file://"]) {
                              mergePath = [mergePath
                                  stringByReplacingOccurrencesOfString:
                                      @"file://"
                                                            withString:@""];
                            }
                            if ([[NSFileManager defaultManager]
                                    fileExistsAtPath:mergePath]) {
                              [[NSFileManager defaultManager]
                                  removeItemAtPath:mergePath
                                             error:nil];
                            }
                          }
                          if (encoder.status ==
                              AVAssetExportSessionStatusCompleted) {
                            [_hud hide:YES];
                            NSLog(@"Video export succeeded");
                            [self
                                outPutResultVideoForVideoPath:encoder.outputURL
                                                 goToNextPage:goToNextPage];
                          } else {
                            _hud.labelText = @"视频导出失败";
                            [_hud hide:YES afterDelay:1.0];
                            NSLog(@"Video export failed with error: %@ (%ld)",
                                  encoder.error.localizedDescription,
                                  (long)encoder.error.code);
                          }
                        });
                      }];
                    }];
}

- (void)outPutResultVideoForVideoPath:(NSURL*)videoUrl
                         goToNextPage:(void (^)())goToNextPage {
  NSFileManager* fileManager = [NSFileManager defaultManager];
  NSString* videoPath = videoUrl.absoluteString;
  // url中存在空格，使用utf8解码
  videoPath = [videoUrl.absoluteString
      stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  if ([videoPath hasPrefix:@"file://"]) {
    videoPath = [videoPath stringByReplacingOccurrencesOfString:@"file://"
                                                     withString:@""];
  }
  CGFloat movSize = 0;
  for (NSInteger i = 0; i < _videoPaths.count; i++) {
    NSURL* tempURL = _videoPaths[i];
    NSData* videoData = [NSData dataWithContentsOfURL:tempURL];
    movSize = movSize + videoData.length / 1024.0 / 1024.0 / 8.0;
    NSString* path = [tempURL absoluteString];
    if ([path hasPrefix:@"file://"]) {
      path =
          [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    if ([fileManager fileExistsAtPath:path]) {
      [fileManager removeItemAtPath:path error:nil];
    }
  }

  NSData* mp4Data = [NSData dataWithContentsOfURL:videoUrl];
  CGFloat mp4Size = mp4Data.length / 1024.0 / 1024.0 / 8.0;
  NSLog(@"视频大小 mov = %f, mp4 = %f", movSize, mp4Size);
  _videoPaths = nil;

  UIImage* image = [self thumbnailImageForVideo:videoUrl atTime:0];
  NSString* imagePath = @"";
  if (image) {
    imagePath =
        [self getVideoFilePathStringForType:@".jpeg" FileName:@"outImage"];
    [UIImageJPEGRepresentation(image, 1) writeToFile:imagePath atomically:YES];
  }
  if ([_delegate respondsToSelector:@selector
                 (recordFinishWithVideoPath:WithThumbnailPath:)]) {
    [_delegate recordFinishWithVideoPath:videoPath WithThumbnailPath:imagePath];
  }

  [self dismissViewControllerAnimated:YES completion:nil];
  if (goToNextPage) {
    goToNextPage();
  }
}

- (UIImage*)thumbnailImageForVideo:(NSURL*)videoURL
                            atTime:(NSTimeInterval)time {
  AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
  NSParameterAssert(asset);
  AVAssetImageGenerator* assetImageGenerator =
      [[AVAssetImageGenerator alloc] initWithAsset:asset];
  assetImageGenerator.appliesPreferredTrackTransform = YES;
  assetImageGenerator.apertureMode =
      AVAssetImageGeneratorApertureModeEncodedPixels;

  CGImageRef thumbnailImageRef = NULL;
  CFTimeInterval thumbnailImageTime = time;
  NSError* thumbnailImageGenerationError = nil;
  thumbnailImageRef =
      [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                                  actualTime:NULL
                                       error:&thumbnailImageGenerationError];

  if (!thumbnailImageRef)
    NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);

  UIImage* thumbnailImage =
      thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
                        : nil;

  return thumbnailImage;
}

@end
