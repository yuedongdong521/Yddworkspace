//
//  VideoCameraView.m
//  addproject
//
//  Created by 胡阳阳 on 17/3/3.
//  Copyright © 2017年 mac. All rights reserved.
//
#import "VideoCameraView.h"
#import "GPUImageBeautifyFilter.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "EditVideoViewController.h"
#import "MBProgressHUD.h"
#import "VideoCameraManager.h"
#import "ISVideoCameraTools.h"
#import "ISCameraProgressView.h"
#import "ISVideoCountDownView.h"
#import "ISVideoCameraBeautySelecteView.h"
#import "SDAVAssetExportSession.h"
#import <libksygpulive/KSYGPUBeautifyPlusFilter.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
/**
 *  定一个弱引用的指针weakSelf指向自己
 */
#define kWeakSelf(weakSelf) __weak __typeof(&*self) weakSelf = self;

typedef NS_ENUM(NSInteger, CameraManagerDevicePosition) {
  CameraManagerDevicePositionBack,
  CameraManagerDevicePositionFront,
};

@interface VideoCameraView () <ISCameraProgressViewDelegate,
                               ISVideoCameraBeautySelecteViewDelegate> {
  NSMutableArray* urlArray;
  NSTimeInterval _currentTime;  // 当前视频长度
  MBProgressHUD* HUD;
  VideoCameraManager* videoCamera;
  GPUImageOutput<GPUImageInput>* _filter;
  GPUImageMovieWriter* movieWriter;
  NSString* _pathToMovie;
  GPUImageView* filteredVideoView;
  CALayer* _focusLayer;
  BOOL _isCountDown;  // 是否正在倒计时
  BOOL _lightCameraState;  // 闪光灯状态  只有开关两种 拍摄视频没有闪光灯
  UILongPressGestureRecognizer* _longPressGesture;  // 长按拍照的手势
  BOOL _begainTakePhoto;
  CGFloat videoMaxTime;  // 视频最大时长（不能为0）
  CGFloat videoMinTime;  // 视频最小时长
}

@property(nonatomic, strong) UIButton* camerafilterChangeButton;  // 美颜按钮
@property(nonatomic, strong)
    UIButton* cameraPositionChangeButton;  // 翻转相机button
@property(nonatomic, assign) CameraManagerDevicePosition position;
@property(nonatomic, strong) UIButton* photoCaptureButton;  // 开始录制按钮。
@property(nonatomic, strong) UIButton* videoCompleteButton;  // 完成录制按钮 √
@property(nonatomic, strong) UIButton* dleButton;  // 返回 重新录制 < x
@property(nonatomic, strong) UIButton* lightButton;  // 闪光灯 开 关

@property(nonatomic, strong, readonly) UIButton* delayShootBtn;  // 延时拍摄按钮
@property(nonatomic, strong) UILabel* delayShootTipLabel;  // 延时拍摄提示label
@property(nonatomic, strong) UIButton* backBtn;  // 退出按钮。
@property(nonatomic, strong)
    UILabel* beginTipLabel;  // 开始进入时提示label，（单击拍照，长按拍摄）

@property(nonatomic, strong)
    UIButton* inputLocalVieoBtn;  // 导入手机本地视频按钮
@property(nonatomic, strong)
    ISCameraProgressView* videoProgressView;  // 视频录制的 进度条
@property(nonatomic, strong)
    ISVideoCameraBeautySelecteView* selectedView;  // 选择美颜等级的view
@property(nonatomic, strong) ISVideoCountDownView* countDownView;  // 倒计时视图

@property(nonatomic, strong)
    GPUImageBeautifyFilter* beautifyFilter;  // 美颜滤镜

@property(nonatomic, strong) KSYGPUBeautifyPlusFilter* ksyBeautifyFilter;

@property(nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

@property(nonatomic, assign) BOOL isRecoding;

@end

@implementation VideoCameraView

#pragma mark - init -

- (void)dealloc {
  ISLog(@"%@释放了", self.class);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  //    [videoCamera UnInitFaceDetect];
}

- (instancetype)initWithFrame:(CGRect)frame
                  WithMaxTime:(CGFloat)maxTime
                  WithMinTime:(CGFloat)minTime {
  if (!(self = [super initWithFrame:frame])) {
    return nil;
  }
  _isCountDown = NO;
  _lightCameraState = NO;
  _begainTakePhoto = NO;
  //    _showTip = YES;
  videoMaxTime = maxTime ? maxTime : 1;
  videoMinTime = minTime;

  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationDidEnterBackground:)
             name:UIApplicationDidEnterBackgroundNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationDidBecomeActive:)
             name:UIApplicationDidBecomeActiveNotification
           object:nil];

  urlArray = [[NSMutableArray alloc] init];

  BOOL isBack = [[[NSUserDefaults standardUserDefaults]
      objectForKey:@"ISVideoCameraPositionIsBack"] boolValue];
  // ISLog(@"是后摄像头吗：%d", isBack);
  AVCaptureDevicePosition position =
      isBack ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;

  AVCaptureSessionPreset preset = SCREEN_MODE_IPHONE4
                                      ? AVCaptureSessionPreset640x480
                                      : AVCaptureSessionPreset1280x720;
  videoCamera = [[VideoCameraManager alloc] initWithSessionPreset:preset
                                                   cameraPosition:position];

  _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
  [_stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
  // 初始化人脸识别
  // [videoCamera initTestFaceDetect];

  if ([videoCamera.inputCamera lockForConfiguration:nil]) {
    // 自动对焦
    if ([videoCamera.inputCamera
            isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
      [videoCamera.inputCamera
          setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    // 自动曝光
    if ([videoCamera.inputCamera
            isExposureModeSupported:
                AVCaptureExposureModeContinuousAutoExposure]) {
      [videoCamera.inputCamera
          setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    // 自动白平衡
    if ([videoCamera.inputCamera
            isWhiteBalanceModeSupported:
                AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
      [videoCamera.inputCamera
          setWhiteBalanceMode:
              AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    }
    // 照片的输出
    if ([videoCamera.captureSession canAddOutput:_stillImageOutput]) {
      [videoCamera.captureSession addOutput:_stillImageOutput];
    }

    BOOL isflashOn = [[[NSUserDefaults standardUserDefaults]
        objectForKey:@"ISVideoCameraFlashOn"] boolValue];
    AVCaptureFlashMode model =
        isflashOn ? AVCaptureFlashModeOn : AVCaptureFlashModeOff;
    _lightCameraState = isflashOn;
    // 闪光灯
    if ([videoCamera.inputCamera isFlashModeSupported:model]) {
      [videoCamera.inputCamera setFlashMode:model];
    }

    [videoCamera.inputCamera unlockForConfiguration];
  }

  _position = isBack ? CameraManagerDevicePositionBack
                     : CameraManagerDevicePositionFront;
  ;
  videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
  [videoCamera updateOrientation];
  [videoCamera addAudioInputsAndOutputs];

  //    _filter = [[GPUImageFilter alloc]
  //    init];// self.beautifyFilter;// self.ksyBeautifyFilter;

  filteredVideoView =
      [[GPUImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  filteredVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

  UITapGestureRecognizer* singleFingerOne = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(cameraViewTapAction:)];
  singleFingerOne.numberOfTouchesRequired = 1;  // 手指数
  singleFingerOne.numberOfTapsRequired = 1;  // tap次数
  [filteredVideoView addGestureRecognizer:singleFingerOne];
  [self addSubview:filteredVideoView];

  //  [videoCamera addTarget:_filter];
  //  [_filter addTarget:filteredVideoView];
  [videoCamera addTarget:filteredVideoView];
  [videoCamera startCameraCapture];

  [self addSomeView];

  return self;
}
- (void)addSomeView {
  _beginTipLabel = [[UILabel alloc] init];
  _beginTipLabel.text = @"单击拍照，长按拍摄";
  _beginTipLabel.textAlignment = NSTextAlignmentCenter;
  _beginTipLabel.font = IS_FONT(16);
  _beginTipLabel.frame =
      CGRectMake((SCREEN_WIDTH - 200) / 2.f,
                 SCREEN_HEIGHT - 147 - IS_TABBAR_ADD_HEIGHT, 200, 25);
  _beginTipLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
  _beginTipLabel.shadowColor =
      [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
  _beginTipLabel.shadowOffset = CGSizeMake(0, 1);
  [filteredVideoView addSubview:_beginTipLabel];

  // 开始录制
  _photoCaptureButton = [[UIButton alloc]
      initWithFrame:CGRectMake(SCREEN_WIDTH / 2.f - 65 / 2.f,
                               SCREEN_HEIGHT - 112.5 - IS_TABBAR_ADD_HEIGHT, 65,
                               65)];
  [_photoCaptureButton addTarget:self
                          action:@selector(togglePhoto:)
                forControlEvents:UIControlEventTouchUpInside];
  [_photoCaptureButton
      setBackgroundImage:[UIImage imageNamed:@"icon_video_camera_start"]
                forState:UIControlStateNormal];
  [filteredVideoView addSubview:_photoCaptureButton];

  _longPressGesture = [[UILongPressGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(captureVideoToggle:)];
  _longPressGesture.cancelsTouchesInView = NO;
  [_photoCaptureButton addGestureRecognizer:_longPressGesture];

  // 完成录制按钮 √
  _videoCompleteButton = [[UIButton alloc] init];
  _videoCompleteButton.hidden = YES;
  _videoCompleteButton.frame =
      CGRectMake(SCREEN_WIDTH - 100,
                 SCREEN_HEIGHT - 105.0 - IS_TABBAR_ADD_HEIGHT, 50, 50.0);
  UIImage* img3 = [UIImage imageNamed:@"complete"];
  [_videoCompleteButton setImage:img3 forState:UIControlStateNormal];
  [_videoCompleteButton addTarget:self
                           action:@selector(completeRecording:)
                 forControlEvents:UIControlEventTouchUpInside];
  [filteredVideoView addSubview:_videoCompleteButton];

  // 删除上一段视频
  _dleButton = [[UIButton alloc] init];
  _dleButton.hidden = YES;
  _dleButton.frame =
      CGRectMake(50, SCREEN_HEIGHT - 105.0 - IS_TABBAR_ADD_HEIGHT, 50, 50.0);
  UIImage* img4 = [UIImage imageNamed:@"del"];
  [_dleButton setImage:img4 forState:UIControlStateNormal];
  UIImage* delSelectedImage = [UIImage imageNamed:@"icon_video_del_selected"];
  [_dleButton setImage:delSelectedImage forState:UIControlStateSelected];
  [_dleButton setImage:delSelectedImage forState:UIControlStateHighlighted];
  [_dleButton addTarget:self
                 action:@selector(clickDleBtn:)
       forControlEvents:UIControlEventTouchUpInside];

  [filteredVideoView addSubview:_dleButton];

  // 上传本地视频
  _inputLocalVieoBtn = [[UIButton alloc] init];
  _inputLocalVieoBtn.frame =
      CGRectMake(50, SCREEN_HEIGHT - 105.0 - IS_TABBAR_ADD_HEIGHT, 50, 50.0);
  UIImage* img5 = [UIImage imageNamed:@"record_ico_input_1"];
  [_inputLocalVieoBtn setImage:img5 forState:UIControlStateNormal];
  [_inputLocalVieoBtn addTarget:self
                         action:@selector(clickInputBtn:)
               forControlEvents:UIControlEventTouchUpInside];
  [filteredVideoView addSubview:_inputLocalVieoBtn];

  // 顶部背景图
  UIView* tool = [[UIView alloc] init];
  tool.backgroundColor = [UIColor clearColor];
  tool.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
  if (IS_IPHONE_X) {
    tool.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50 + 24);
  }
  [filteredVideoView addSubview:tool];

  CAGradientLayer* gradLayer = [CAGradientLayer layer];
  gradLayer.colors = @[
    (__bridge id)[UIColor colorWithRed:20 / 255.f
                                 green:20 / 255.f
                                  blue:20 / 255.f
                                 alpha:0.4]
        .CGColor,
    (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor
  ];
  gradLayer.frame = tool.frame;
  [tool.layer addSublayer:gradLayer];

  CGFloat offsetY = 10;
  if (IS_IPHONE_X) {
    offsetY = 34;
  }
  // 返回按钮  x
  UIButton* backBtn =
      [[UIButton alloc] initWithFrame:CGRectMake(15, offsetY, 30, 30)];
  [backBtn setImage:[UIImage imageNamed:@"BackToHome"]
           forState:UIControlStateNormal];
  [backBtn addTarget:self
                action:@selector(clickBackToHome:)
      forControlEvents:UIControlEventTouchUpInside];
  [tool addSubview:backBtn];
  _backBtn = backBtn;

  // 闪光灯
  _lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _lightButton.frame = CGRectMake(SCREEN_WIDTH - 195, offsetY, 30.0, 30.0);
  //    BOOL isflashOn = [[[NSUserDefaults standardUserDefaults]
  //    objectForKey:@"ISVideoCameraFlashOn"] boolValue];
  UIImage* flashImage = _lightCameraState
                            ? [UIImage imageNamed:@"icon_video_light_on"]
                            : [UIImage imageNamed:@"icon_video_light_off"];
  [_lightButton setImage:flashImage forState:UIControlStateNormal];
  [_lightButton addTarget:self
                   action:@selector(clickLightButton:)
         forControlEvents:UIControlEventTouchUpInside];
  [tool addSubview:_lightButton];

  // 美颜
  _camerafilterChangeButton = [[UIButton alloc] init];
  _camerafilterChangeButton.frame =
      CGRectMake(SCREEN_WIDTH - 145, offsetY, 30.0, 30.0);
  UIImage* img = [UIImage imageNamed:@"beautyON"];
  [_camerafilterChangeButton setImage:img forState:UIControlStateNormal];
  [_camerafilterChangeButton addTarget:self
                                action:@selector(changebeautifyFilterBtn:)
                      forControlEvents:UIControlEventTouchUpInside];

  [tool addSubview:_camerafilterChangeButton];

  // 翻转相机button
  _cameraPositionChangeButton = [[UIButton alloc]
      initWithFrame:CGRectMake(SCREEN_WIDTH - 95, offsetY, 30, 30)];
  UIImage* img2 = [UIImage imageNamed:@"cammera"];
  [_cameraPositionChangeButton setImage:img2 forState:UIControlStateNormal];
  [_cameraPositionChangeButton addTarget:self
                                  action:@selector(changeCameraPositionBtn:)
                        forControlEvents:UIControlEventTouchUpInside];
  [tool addSubview:_cameraPositionChangeButton];

  // 延时拍摄
  _delayShootBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  _delayShootBtn.frame = CGRectMake(SCREEN_WIDTH - 45, offsetY, 30, 30);
  [_delayShootBtn setImage:[UIImage imageNamed:@"icon_video_delay_shoot_off"]
                  forState:UIControlStateNormal];
  [_delayShootBtn addTarget:self
                     action:@selector(delayShootBtnClick:)
           forControlEvents:UIControlEventTouchUpInside];
  [tool addSubview:_delayShootBtn];

  // 录制进度条
  CGFloat orgionY = SCREEN_HEIGHT - 4;
  if (IS_IPHONE_X) {
    orgionY = orgionY - IS_TABBAR_ADD_HEIGHT;
  }
  _videoProgressView = [[ISCameraProgressView alloc]
      initWithFrame:CGRectMake(0, orgionY, SCREEN_WIDTH, 4)
        WithMaxTime:videoMaxTime
        WithMinTime:videoMinTime];
  _videoProgressView.delegate = self;
  [filteredVideoView addSubview:_videoProgressView];

  [self.selectedView recoveryBeforeState];

  // 倒计时提示视图
  _countDownView = [[ISVideoCountDownView alloc]
      initWithFrame:CGRectMake(SCREEN_WIDTH / 2.f - 52,
                               SCREEN_HEIGHT / 2.f - 52 - IS_TABBAR_ADD_HEIGHT,
                               104, 104)];
  [filteredVideoView addSubview:_countDownView];
  _countDownView.hidden = YES;
}

// 仅拍照
- (void)setVideoCameraType:(VideoCameraViewType)videoCameraType {
  _videoCameraType = videoCameraType;

  if (_videoCameraType == VideoCameraViewTypePic) {  // 仅拍照
    self.inputLocalVieoBtn.hidden = YES;
    self.videoProgressView.hidden = YES;
    //        [self removeBeginTipLabel];
    //        _beginTipLabel.hidden = YES;
    _beginTipLabel.text = @"单击拍照";
    [_photoCaptureButton removeGestureRecognizer:_longPressGesture];
  } else if (_videoCameraType == VideoCameraViewTypeVideoSession) {
    CGFloat H = (ScreenHeight - ScreenWidth) * 0.5;
    UIView* topView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, H)];
    topView.backgroundColor = [UIColor blackColor];
    [filteredVideoView insertSubview:topView atIndex:0];
    UIView* bottomView = [[UIView alloc]
        initWithFrame:CGRectMake(0, H + ScreenWidth, ScreenWidth, H)];
    bottomView.backgroundColor = [UIColor blackColor];
    [filteredVideoView insertSubview:bottomView atIndex:0];
    _beginTipLabel.text = @"长按拍摄";
  }
}

#pragma mark - ISCameraProgressViewDelegate -
/**
 视频录制进度条走完了
 */
- (void)cameraProgressViewDidFullTime {
  // 时间到了停止录制视频
  _photoCaptureButton.enabled = NO;
  [self completeRecording:_videoCompleteButton];
  ISLog(@"录制完成");
}

- (void)updateProgress:(NSTimeInterval)time {
  _currentTime = time;
  if (time > videoMinTime) {
    _videoCompleteButton.hidden = NO;
  }
}

#pragma mark - ISVideoCameraBeautySelecteViewDelegate -
- (void)selecteViewWillDismiss {
  _photoCaptureButton.hidden = NO;
  if (IS_IPHONE_X) {
    _videoProgressView.hidden = NO;
  }
  if (_videoProgressView.historyTime > videoMinTime) {  // 达到最小录制时间
    _videoCompleteButton.hidden = NO;
    _dleButton.hidden = NO;
  } else if (_videoProgressView.historyTime > 0) {
    _dleButton.hidden = NO;
  } else {
    _inputLocalVieoBtn.hidden = NO;
    _beginTipLabel.hidden = NO;
  }
}

- (void)selecteView:(ISVideoCameraBeautySelecteView*)selectView
     didSelctedItem:(NSInteger)count {
  if (count == 0) {
    // 无美颜
    //        [videoCamera openFaceDetect:NO];
    [videoCamera removeAllTargets];
    _filter = self.ksyBeautifyFilter;
    [videoCamera addTarget:_filter];
    [_filter addTarget:filteredVideoView];
    [_camerafilterChangeButton setImage:[UIImage imageNamed:@"beautyOFF"]
                               forState:UIControlStateNormal];
  } else {
    [videoCamera removeAllTargets];
    _filter = self.beautifyFilter;
    [videoCamera addTarget:_filter];
    [_filter addTarget:filteredVideoView];
    //        [videoCamera openFaceDetect:YES];
    [_camerafilterChangeButton setImage:[UIImage imageNamed:@"beautyON"]
                               forState:UIControlStateNormal];
  }
}
// 美白
- (void)selecteView:(ISVideoCameraBeautySelecteView*)selectView
    whiteSliderChanged:(UISlider*)sender {
  self.beautifyFilter.whiteness = sender.value;
}
// 磨皮
- (void)selecteView:(ISVideoCameraBeautySelecteView*)selectView
    buffingSliderChanged:(UISlider*)sender {
  self.beautifyFilter.intensity = sender.value;
}
/*
 // 大眼
 - (void)selecteView:(ISVideoCameraBeautySelecteView *)selectView
 bigEyesSliderChanged:(UISlider *)sender
 {
 // [videoCamera setBigEyesParameter:sender.value];
 }
 // 瘦脸
 - (void)selecteView:(ISVideoCameraBeautySelecteView *)selectView
 thinFaceSliderChanged:(UISlider *)sender
 {
 // [videoCamera setThinFaceParameter:sender.value];
 }
 */

#pragma mark - 延时拍摄 -
- (void)delayShootBtnClick:(UIButton*)sender {
  //    [self removeBeginTipLabel];
  _beginTipLabel.hidden = YES;
  if (sender.hidden == YES) {
    return;
  }
  _delayShootBtn.selected = !_delayShootBtn.selected;
  if (_delayShootBtn.selected) {
    // 延时拍摄开
    [_delayShootBtn setImage:[UIImage imageNamed:@"icon_video_delay_shoot_on"]
                    forState:UIControlStateNormal];
    self.delayShootTipLabel.text = @"延时3s拍摄开启";
  }
  // 延时拍摄关
  else {
    [_delayShootBtn setImage:[UIImage imageNamed:@"icon_video_delay_shoot_off"]
                    forState:UIControlStateNormal];
    self.delayShootTipLabel.text = @"延时3s拍摄关闭";
  }

  _delayShootTipLabel.hidden = NO;
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        _delayShootTipLabel.hidden = YES;
        if (_currentTime == 0 && _begainTakePhoto == NO) {
          _beginTipLabel.hidden = NO;
        }
      });
}
#pragma mark - 拍摄或录制action -
- (void)captureVideoToggle:(UIGestureRecognizer*)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    // 开始录制
    ISLog(@"开始录制");
    //        [self removeBeginTipLabel];
    _begainTakePhoto = YES;
    [self beganRecording:_photoCaptureButton];
  } else {
    if (recognizer.state == UIGestureRecognizerStateCancelled ||
        recognizer.state == UIGestureRecognizerStateFailed ||
        recognizer.state == UIGestureRecognizerStateEnded) {
      // 暂停录制
      ISLog(@"暂停录制");
      [self endRecordingVideo:_photoCaptureButton];
    }
  }
}

- (void)togglePhoto:(UIButton*)sender {
  if (_photoCaptureButton.enabled == NO) {
    return;
  }
  if (_videoCameraType == VideoCameraViewTypeVideoSession) {
    return;
  }
  // 拍照
  // 判断是否已经录制了，录制已开始则不响应
  if (_currentTime > 0) {
    return;
  }
  // 判断延时拍摄是否已开启，开启且读秒已开始，则不响应
  if (_isCountDown == YES) {
    return;
  }

  //     [self removeBeginTipLabel];
  _begainTakePhoto = YES;
  _beginTipLabel.hidden = YES;

  // 开启了延时拍摄，读秒开始，结束后直接拍摄
  if (_delayShootBtn.selected) {
    // 延时拍摄开
    _camerafilterChangeButton.hidden = YES;
    _dleButton.hidden = YES;
    _videoCompleteButton.hidden = YES;
    _cameraPositionChangeButton.hidden = YES;
    _inputLocalVieoBtn.hidden = YES;
    _delayShootBtn.hidden = YES;
    _photoCaptureButton.hidden = YES;
    _backBtn.hidden = YES;
    _lightButton.hidden = YES;

    _countDownView.hidden = NO;
    kWeakSelf(weakSelf);
    __weak ISVideoCountDownView* weakCountDown = _countDownView;
    _isCountDown = YES;
    [_countDownView startCountDown:^{
      //            _isCountDown = NO;
      //            _photoCaptureButton.hidden = NO;
      //            _backBtn.hidden = NO;
      [weakSelf takeAPicture:AVCaptureVideoOrientationPortrait];
      weakCountDown.hidden = YES;
    }];
    return;
  }
  // 没开启延时拍摄，直接开始拍摄
  [self takeAPicture:AVCaptureVideoOrientationPortrait];
}

- (void)takeAPicture:(UIDeviceOrientation)deviceOrientation {
  ISLog(@"开始拍摄");
  AVCaptureConnection* videoConnection =
      [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
  if (!videoConnection) {
    ISLog(@"拍照失败");
    return;
  }
  if ([videoConnection isVideoOrientationSupported]) {
    switch (deviceOrientation) {
      case UIDeviceOrientationPortraitUpsideDown:
        [videoConnection
            setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
        break;

      case UIDeviceOrientationLandscapeLeft:
        [videoConnection
            setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        break;

      case UIDeviceOrientationLandscapeRight:
        [videoConnection
            setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        break;

      default:
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        break;
    }
  }
  [videoConnection setVideoScaleAndCropFactor:1];

  __weak AVCaptureSession* captureSessionBlock = videoCamera.captureSession;
  kWeakSelf(weakSelf);
  [_stillImageOutput
      captureStillImageAsynchronouslyFromConnection:videoConnection
                                  completionHandler:^(
                                      CMSampleBufferRef imageDataSampleBuffer,
                                      NSError* error) {
                                    if ([captureSessionBlock isRunning]) {
                                      [captureSessionBlock stopRunning];
                                    }

                                    if (imageDataSampleBuffer != NULL) {
                                      NSData* imageData =
                                          [AVCaptureStillImageOutput
                                              jpegStillImageNSDataRepresentation:
                                                  imageDataSampleBuffer];
                                      UIImage* image = [[UIImage alloc]
                                          initWithData:imageData];
                                      UIImage* newImage;

                                      if (videoCamera.cameraPosition ==
                                          AVCaptureDevicePositionFront) {
                                        newImage = [UIImage
                                            imageWithCGImage:[image CGImage]
                                                       scale:1
                                                 orientation:
                                                     UIImageOrientationLeftMirrored];
                                      } else {
                                        newImage = [UIImage
                                            imageWithCGImage:[image CGImage]
                                                       scale:1
                                                 orientation:
                                                     [image imageOrientation]];
                                      }
                                      // 将image的方向 调为 竖屏
                                      UIGraphicsBeginImageContextWithOptions(
                                          newImage.size, false, newImage.scale);
                                      [newImage
                                          drawInRect:(CGRect){
                                                         0, 0,
                                                         newImage.size.width,
                                                         newImage.size.height}];
                                      newImage =
                                          UIGraphicsGetImageFromCurrentImageContext();
                                      UIGraphicsEndImageContext();

                                      GPUImageOutput<GPUImageInput>* filter =
                                          _filter;
                                      GPUImagePicture* pic =
                                          [[GPUImagePicture alloc]
                                              initWithImage:newImage];
                                      [pic addTarget:filter];

                                      [pic processImage];
                                      [filter useNextFrameForImageCapture];
                                      // 最终的 image
                                      UIImage* colorBlendFilterImage =
                                          [filter imageFromCurrentFramebuffer];

                                      ISLog(@"photo succeed");
                                      if ([_delegate
                                              respondsToSelector:@selector
                                              (didFinishTakePhoto:
                                                     goToNextPage:)]) {
                                        [_delegate
                                            didFinishTakePhoto:
                                                colorBlendFilterImage
                                                  goToNextPage:^{
                                                    [videoCamera
                                                        stopCameraCapture];
                                                    [weakSelf
                                                        removeFromSuperview];
                                                  }];
                                      }
                                    } else if (error) {
                                      ISLog(@"222 error");
                                    }
                                  }];
}

#pragma mark - 开始录制

- (void)beganRecording:(UIButton*)sender {
  _beginTipLabel.hidden = YES;
  self.delayShootTipLabel.hidden = YES;

  if (_delayShootBtn.selected && !sender.selected && _isCountDown == NO) {
    // 延时拍摄开
    _camerafilterChangeButton.hidden = YES;
    _dleButton.hidden = YES;
    _videoCompleteButton.hidden = YES;
    _cameraPositionChangeButton.hidden = YES;
    _inputLocalVieoBtn.hidden = YES;
    _delayShootBtn.hidden = YES;
    _backBtn.hidden = YES;
    _lightButton.hidden = YES;
    // 倒计时提示视图
    _countDownView.hidden = NO;
    kWeakSelf(weakSelf);
    __weak ISVideoCountDownView* weakCountDown = _countDownView;
    _isCountDown = YES;
    [_countDownView startCountDown:^{
      _isCountDown = NO;
      _backBtn.hidden = NO;
      [weakSelf startRecordingOrStopRecordingImmediately:sender];
      weakCountDown.hidden = YES;
    }];
    return;
  }
  // 正在倒计时 取消倒计时 取消录制
  if (_isCountDown == YES) {
    [_countDownView cancleTimer];
    _countDownView.hidden = YES;
    _backBtn.hidden = NO;
    _camerafilterChangeButton.hidden = NO;
    _cameraPositionChangeButton.hidden = NO;
    _delayShootBtn.hidden = NO;
    _lightButton.hidden = NO;

    if (_currentTime > 0) {
      _dleButton.hidden = NO;
    } else {
      _inputLocalVieoBtn.hidden = NO;
    }
    if (_currentTime > videoMinTime) {
      _videoCompleteButton.hidden = NO;
    }
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
          _isCountDown = NO;
        });
    return;
  }

  // 延时拍摄关
  [self startRecordingOrStopRecordingImmediately:sender];
}

- (void)endRecordingVideo:(UIButton*)sender {
  _beginTipLabel.hidden = YES;
  self.delayShootTipLabel.hidden = YES;
  // 正在倒计时 取消倒计时 取消录制
  if (_isCountDown == YES) {
    [_countDownView cancleTimer];
    _countDownView.hidden = YES;
    _backBtn.hidden = NO;
    _camerafilterChangeButton.hidden = NO;
    _cameraPositionChangeButton.hidden = NO;
    _delayShootBtn.hidden = NO;
    _lightButton.hidden = NO;

    if (_currentTime > 0) {
      _dleButton.hidden = NO;
    } else {
      _inputLocalVieoBtn.hidden = NO;
    }
    if (_currentTime > videoMinTime) {
      _videoCompleteButton.hidden = NO;
    }
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
          _isCountDown = NO;
        });
    return;
  }

  // 延时拍摄关
  [self startRecordingOrStopRecordingImmediately:sender];
}

- (void)startRecordingOrStopRecordingImmediately:(UIButton*)sender {
  _inputLocalVieoBtn.hidden = YES;
  if (!sender.selected) {
    // 开始录制
    sender.selected = YES;
    [_photoCaptureButton
        setBackgroundImage:[UIImage imageNamed:@"icon_video_camera_stop"]
                  forState:UIControlStateNormal];
    _camerafilterChangeButton.hidden = YES;
    _cameraPositionChangeButton.hidden = YES;
    _delayShootBtn.hidden = YES;
    _dleButton.hidden = YES;
    _lightButton.hidden = YES;
    [self startRecording];
  }
  // 暂停录制
  else {
    sender.selected = NO;
    [_photoCaptureButton
        setBackgroundImage:[UIImage imageNamed:@"icon_video_camera_start"]
                  forState:UIControlStateNormal];
    _camerafilterChangeButton.hidden = NO;
    _cameraPositionChangeButton.hidden = NO;
    _delayShootBtn.hidden = NO;
    _lightButton.hidden = NO;
    [self stopRecording];
  }
}

- (void)startRecording {
  _pathToMovie = [[ISVideoCameraTools getVideoCameraFolderPath]
      stringByAppendingPathComponent:[NSString
                                         stringWithFormat:@"Movie%lu.mov",
                                                          (unsigned long)
                                                              urlArray.count]];
  // If a file already exists, AVAssetWriter won't let you record new frames, so
  // delete the old movie
  // unlink()会删除参数pathname 指定的文件
  unlink([_pathToMovie UTF8String]);

  NSURL* movieURL = [NSURL fileURLWithPath:_pathToMovie];
  movieWriter =
      [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL
                                               size:CGSizeMake(720.0, 1280.0)];
  movieWriter.isNeedBreakAudioWhiter = YES;
  movieWriter.encodingLiveVideo = YES;
  movieWriter.shouldPassthroughAudio = YES;
  [_filter addTarget:movieWriter];
  videoCamera.audioEncodingTarget = movieWriter;
  [movieWriter startRecording];
  _isRecoding = YES;
  [_videoProgressView start];
}

- (void)stopRecording {
  videoCamera.audioEncodingTarget = nil;
  ISLog(@"Path %@", _pathToMovie);
  if (_pathToMovie == nil) {
    return;
  }
  if (_isRecoding) {
    [movieWriter finishRecording];
    [_filter removeTarget:movieWriter];
    [urlArray
        addObject:[NSURL
                      URLWithString:[NSString stringWithFormat:@"file://%@",
                                                               _pathToMovie]]];
    _isRecoding = NO;
  }
  if (urlArray.count) {
    _dleButton.hidden = NO;
  }
  [_videoProgressView stop];
}

#pragma mark - 完成录制 -
- (void)completeRecording:(UIButton*)sender {
  if (sender.hidden == YES) {
    return;
  }
  if (_dleButton.selected == YES) {
    return;
  }

  videoCamera.audioEncodingTarget = nil;
  ISLog(@"Path %@", _pathToMovie);
  if (_pathToMovie == nil) {
    return;
  }
  if (_isRecoding) {
    [movieWriter finishRecording];
    [_filter removeTarget:movieWriter];
    _isRecoding = NO;
  }

  if (_photoCaptureButton.selected == YES) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(TIMER_INTERVAL * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                     [_videoProgressView stop];
                   });
  }

  if (_photoCaptureButton.selected) {
    [urlArray
        addObject:[NSURL
                      URLWithString:[NSString stringWithFormat:@"file://%@",
                                                               _pathToMovie]]];
  }

  if ([_delegate
          respondsToSelector:@selector(didFinishVideoRecord:goToNextPage:)]) {
    kWeakSelf(weakSelf);
    [_delegate didFinishVideoRecord:urlArray
                       goToNextPage:^{
                         [videoCamera stopCameraCapture];
                         [weakSelf removeFromSuperview];
                       }];
  }
  _dleButton.hidden = YES;
  _photoCaptureButton.selected = NO;
  _videoCompleteButton.hidden = YES;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [urlArray removeAllObjects];
                   _currentTime = 0;
                 });
}
// 删除最新一段视频
- (void)clickDleBtn:(UIButton*)sender {
  if (sender.hidden == YES) {
    return;
  }
  _dleButton.selected = YES;
  [_videoProgressView deleteClick];
  UIViewController* currentController =
      [[AppDelegate appDelegate] getNewCurrentViewController];
  [ISTools showAlertViewFromController:currentController
      title:@"\n删除最新一段录制的视频？"
      message:@""
      CancleButtonTitle:@"取消"
      otherButtonTitle:@"确认"
      cancleButtonClick:^{
        [self dleButtonClickCancle];
      }
      otherButtonClick:^{
        [self dleButtonClickSure];
      }];
}

- (void)dleButtonClickCancle {
  [_videoProgressView deleteCancle];
  _dleButton.selected = NO;
}

- (void)dleButtonClickSure {
  _dleButton.selected = NO;
  [_videoProgressView deleteSure];
  _currentTime = _videoProgressView.historyTime;
  if (urlArray.count) {
    [urlArray removeLastObject];
    if (urlArray.count == 0) {  // 片段视频已删完
      _dleButton.hidden = YES;
      _inputLocalVieoBtn.hidden = NO;
      _beginTipLabel.hidden = NO;
      _begainTakePhoto = NO;
    }
    if (_currentTime < 3) {
      _videoCompleteButton.hidden = YES;
    }
  }
}

#pragma mark - 导入手机视频
- (void)clickInputBtn:(UIButton*)sender {
  //    [self removeBeginTipLabel];
  //    _beginTipLabel.hidden = YES;
  if (sender.hidden == YES) {
    return;
  }
  kWeakSelf(weakSelf);
  if ([_delegate
          respondsToSelector:@selector(didClickInputLocalPhotoOrVideoBtn:)]) {
    [_delegate didClickInputLocalPhotoOrVideoBtn:^{
      [videoCamera stopCameraCapture];
      [weakSelf removeFromSuperview];
    }];
  }
}

#pragma mark -  退出 -
- (void)clickBackToHome:(UIButton*)sender {
  if (sender.hidden == YES) {
    return;
  }

  [self stopRecording];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [videoCamera stopCameraCapture];
  if (_isRecoding) {
    [movieWriter cancelRecording];
    [_filter removeTarget:movieWriter];
    _isRecoding = NO;
  }

  if ([_delegate respondsToSelector:@selector(didClickBackToHomeBtn)]) {
    [self removeFromSuperview];
    [_delegate didClickBackToHomeBtn];
  }
}
#pragma mark - 翻转摄像头
- (void)changeCameraPositionBtn:(UIButton*)sender {
  if (sender.hidden == YES) {
    return;
  }
  self.delayShootTipLabel.hidden = YES;
  switch (_position) {
    case CameraManagerDevicePositionBack: {
      if (videoCamera.cameraPosition == AVCaptureDevicePositionBack) {
        [videoCamera pauseCameraCapture];
        _position = CameraManagerDevicePositionFront;  // 改为前置摄像头

        [videoCamera rotateCamera];
        [videoCamera updateOrientation];
        [videoCamera resumeCameraCapture];

        sender.selected = YES;
        [videoCamera removeAllTargets];
        // 美颜滤镜
        _camerafilterChangeButton.selected = YES;
        [videoCamera addTarget:_filter];
        [_filter addTarget:filteredVideoView];
        [[NSUserDefaults standardUserDefaults]
            setObject:@(NO)
               forKey:@"ISVideoCameraPositionIsBack"];
        [[NSUserDefaults standardUserDefaults] synchronize];
      }
    } break;
    case CameraManagerDevicePositionFront: {
      if (videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        [videoCamera pauseCameraCapture];
        _position = CameraManagerDevicePositionBack;

        [videoCamera rotateCamera];
        [videoCamera updateOrientation];
        [videoCamera resumeCameraCapture];

        sender.selected = NO;
        _camerafilterChangeButton.selected = NO;
        //        [videoCamera removeAllTargets];
        //        [videoCamera addTarget:_filter];
        //        [_filter addTarget:filteredVideoView];
        [[NSUserDefaults standardUserDefaults]
            setObject:@(YES)
               forKey:@"ISVideoCameraPositionIsBack"];
        [[NSUserDefaults standardUserDefaults] synchronize];
      }
    } break;
    default:
      break;
  }

  if ([videoCamera.inputCamera lockForConfiguration:nil]) {
    if ([videoCamera.inputCamera
            isExposureModeSupported:
                AVCaptureExposureModeContinuousAutoExposure]) {
      [videoCamera.inputCamera
          setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }

    AVCaptureFlashMode mode;
    if (_lightCameraState == YES) {
      // 开启闪光灯
      mode = AVCaptureFlashModeOn;
    } else {
      // 关闭闪光灯
      mode = AVCaptureFlashModeOff;
    }

    if ([videoCamera.inputCamera isFlashModeSupported:mode]) {
      [videoCamera.captureSession beginConfiguration];
      [videoCamera.inputCamera setFlashMode:mode];
      [videoCamera.captureSession commitConfiguration];
      [videoCamera.captureSession startRunning];
    }

    [videoCamera.inputCamera unlockForConfiguration];
  }
}
// 闪光灯
- (void)clickLightButton:(UIButton*)sender {
  _lightCameraState = !_lightCameraState;

  AVCaptureFlashMode mode;
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  if (_lightCameraState == YES) {
    // 开启闪光灯
    mode = AVCaptureFlashModeOn;
    [_lightButton setImage:[UIImage imageNamed:@"icon_video_light_on"]
                  forState:UIControlStateNormal];
    [userDefaults setObject:@(YES) forKey:@"ISVideoCameraFlashOn"];
    [userDefaults synchronize];
  } else {
    // 关闭闪光灯
    mode = AVCaptureFlashModeOff;
    [_lightButton setImage:[UIImage imageNamed:@"icon_video_light_off"]
                  forState:UIControlStateNormal];
    [userDefaults setObject:@(NO) forKey:@"ISVideoCameraFlashOn"];
    [userDefaults synchronize];
  }
  AVCaptureDevice* device = videoCamera.inputCamera;
  if ([device isFlashModeSupported:mode]) {
    [videoCamera.captureSession beginConfiguration];
    [device lockForConfiguration:nil];
    [device setFlashMode:mode];
    [device unlockForConfiguration];
    [videoCamera.captureSession commitConfiguration];
    [videoCamera.captureSession startRunning];
  }
}
#pragma mark - 美颜
- (void)changebeautifyFilterBtn:(UIButton*)sender {
  if (sender.hidden == YES) {
    return;
  }

  self.delayShootTipLabel.hidden = YES;
  [videoCamera resumeCameraCapture];
  [self.selectedView showInView:self
                     completion:^{
                       _dleButton.hidden = YES;
                       _videoCompleteButton.hidden = YES;
                       _photoCaptureButton.hidden = YES;
                       _inputLocalVieoBtn.hidden = YES;
                       _beginTipLabel.hidden = YES;
                       if (IS_IPHONE_X) {
                         _videoProgressView.hidden = YES;
                       }
                     }];
}

- (void)setfocusImage {
  UIImage* focusImage = [UIImage imageNamed:@"96"];
  UIImageView* imageView =
      [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width,
                                                    focusImage.size.height)];
  imageView.image = focusImage;
  CALayer* layer = imageView.layer;
  layer.hidden = YES;
  [filteredVideoView.layer addSublayer:layer];
  _focusLayer = layer;
}

- (void)layerAnimationWithPoint:(CGPoint)point {
  if (_focusLayer) {
    CALayer* focusLayer = _focusLayer;
    focusLayer.hidden = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [focusLayer setPosition:point];
    focusLayer.transform = CATransform3DMakeScale(2.0f, 2.0f, 1.0f);
    [CATransaction commit];

    CABasicAnimation* animation =
        [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue
        valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)];
    animation.duration = 0.3f;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [focusLayer addAnimation:animation forKey:@"animation"];

    // 0.5秒钟延时
    [self performSelector:@selector(focusLayerNormal)
               withObject:self
               afterDelay:0.5f];
  }
}

- (void)focusLayerNormal {
  filteredVideoView.userInteractionEnabled = YES;
  _focusLayer.hidden = YES;
}

- (void)cameraViewTapAction:(UITapGestureRecognizer*)tgr {
  if (tgr.state == UIGestureRecognizerStateRecognized &&
      (_focusLayer == NO || _focusLayer.hidden)) {
    CGPoint location = [tgr locationInView:filteredVideoView];
    [self setfocusImage];
    [self layerAnimationWithPoint:location];
    AVCaptureDevice* device = videoCamera.inputCamera;
    CGPoint pointOfInterest = [ISVideoCameraTools
        convertToPointOfInterestFromViewCoordinates:location
                                     videoViewFrame:filteredVideoView.frame];
    NSError* error;
    if ([device lockForConfiguration:&error]) {
      if ([device isFocusPointOfInterestSupported] &&
          [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [device setFocusPointOfInterest:pointOfInterest];
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
      }

      if ([device isExposurePointOfInterestSupported] &&
          [device isExposureModeSupported:
                      AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposurePointOfInterest:pointOfInterest];
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
      }

      [device unlockForConfiguration];

      ISLog(@"FOCUS OK");
    } else {
      ISLog(@"ERROR = %@", error);
    }
  }
}

#pragma mark - lazy load -

- (UILabel*)delayShootTipLabel {
  if (_delayShootTipLabel == nil) {
    _delayShootTipLabel = [[UILabel alloc] init];
    _delayShootTipLabel.frame =
        CGRectMake(SCREEN_WIDTH / 2.f - 65,
                   SCREEN_HEIGHT - 170 - IS_TABBAR_ADD_HEIGHT, 130, 35);
    _delayShootTipLabel.layer.cornerRadius = 4;
    _delayShootTipLabel.clipsToBounds = YES;
    _delayShootTipLabel.textColor = [UIColor whiteColor];
    _delayShootTipLabel.font = [UIFont systemFontOfSize:16];
    _delayShootTipLabel.backgroundColor = [UIColor colorWithRed:0 / 255.f
                                                          green:0 / 255.f
                                                           blue:0 / 255.f
                                                          alpha:0.7];
    _delayShootTipLabel.textAlignment = NSTextAlignmentCenter;
    [filteredVideoView addSubview:_delayShootTipLabel];
    _delayShootTipLabel.hidden = YES;
  }
  return _delayShootTipLabel;
}

- (ISVideoCameraBeautySelecteView*)selectedView {
  if (_selectedView == nil) {
    _selectedView = [[ISVideoCameraBeautySelecteView alloc] init];
    _selectedView.delegate = self;
  }
  return _selectedView;
}

- (GPUImageBeautifyFilter*)beautifyFilter {
  if (_beautifyFilter == nil) {
    _beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
  }
  return _beautifyFilter;
}

- (KSYGPUBeautifyPlusFilter*)ksyBeautifyFilter {
  if (_ksyBeautifyFilter == nil) {
    _ksyBeautifyFilter = [[KSYGPUBeautifyPlusFilter alloc] init];
    [_ksyBeautifyFilter setBeautylevel:5];
  }
  return _ksyBeautifyFilter;
}

#pragma mark - Notification

- (void)applicationDidEnterBackground:(NSNotification*)notification {
  if (_photoCaptureButton.selected == YES) {  // 正在录制
    _photoCaptureButton.selected = NO;
    [_photoCaptureButton
        setBackgroundImage:[UIImage imageNamed:@"icon_video_camera_start"]
                  forState:UIControlStateNormal];
    _camerafilterChangeButton.hidden = NO;
    _cameraPositionChangeButton.hidden = NO;
    _delayShootBtn.hidden = NO;
    [self stopRecording];
  }

  [videoCamera pauseCameraCapture];
  [videoCamera removeAllTargets];
  //  _filter = nil;
  [videoCamera stopCameraCapture];
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
  ISLog(@"applicationDidBecomeActive");
  //  _filter = self.beautifyFilter;
  [videoCamera addTarget:_filter];
  [_filter addTarget:filteredVideoView];
  [videoCamera resumeCameraCapture];
  [videoCamera startCameraCapture];
}

@end
