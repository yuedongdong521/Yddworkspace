//
//  AVCaptureSessionViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2016/11/4.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "AVCaptureSessionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+help.h"
#import "Masonry.h"
#import "AVPlayerViewController.h"


typedef enum : NSUInteger {
    VideoRecordStateInit,
    VideoRecordStateRecording,
    VideoRecordStatePause,
    VideoRecordStateFinish,
    VideoRecordStateFail,
} VideoRecordState;

@interface AVCaptureSessionViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,
    AVCaptureMetadataOutputObjectsDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    BOOL stillImageFlag; //拍照模式
    BOOL videoDataFlag; //录制视频
    BOOL metadataOutputFlag; // 扫描二维码
    UIImage *largeImage;
    UIImage *smallImage;
}
//硬件设备
@property (nonatomic, strong) AVCaptureDevice *device;

//协调输入输出流的数据
@property (nonatomic, strong) AVCaptureSession *session;
//预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
//输入流
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;//视频输入
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;//原始视频针，用于获取实时图像以及视频录制

@property (nonatomic, strong) AVCaptureDeviceInput *audioInput; //音频输入
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput; //音频输出
//输出流
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;//用于捕捉静态图片


@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput; //用于识别二维码以及人脸
//数据写入
@property (nonatomic, strong) AVAssetWriter *assetWriter;
//写入视频数据
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
//写入音频数据
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, assign) NSInteger recordState;
@property (nonatomic, assign) BOOL canWrite;

@property (nonatomic, strong) dispatch_queue_t writeQueue;

@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;


//视频输出的大小
@property (nonatomic, assign) CGSize outputSize;
//视频属性容器
@property (nonatomic, strong) NSDictionary *videoCompressionSettings;
//音频属性设置容器
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;
//闪光灯
@property (nonatomic, strong) UIButton *torchButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) UIImageView *phoneView;
@property (nonatomic, strong) UIImageView *qrCodeView;
@property (nonatomic, strong) UIImageView *qrLineView;

@property (nonatomic, strong) UIImageView *foucImageView;



@end

@implementation AVCaptureSessionViewController

- (void)viewWillAppear:(BOOL)animated
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"没有开启相机权限" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        //开始采集
        [self.session startRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initAVCapture];
    
    [self initUI];

    
}

- (void)initData
{
    stillImageFlag = YES;//照相模式
    videoDataFlag = NO; //录制模式
    metadataOutputFlag = NO;//二维码模式
    self.outputSize = CGSizeMake(ScreenWidth, ScreenHeight);
    self.writeQueue = dispatch_queue_create("writeQueue", DISPATCH_QUEUE_SERIAL);
    
    
    
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [path stringByAppendingPathComponent:@"video"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];//创建文件夹
    }
    self.videoUrl = [[NSURL alloc] initFileURLWithPath:[filePath stringByAppendingPathComponent:@"ydd.mp4"]];
}
- (void)initAVCapture
{
    //初始化视频输入设备（摄像头）
    [self initDevice];

    //初始化视频会话
    [self initCaptureSession];
    //初始化视频展示层
    [self initPreviewLayer];
}


- (void)initUI
{
    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    back.frame = CGRectMake(10, 30, 50, 30);
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    
    UIButton *qrCodeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    qrCodeBtn.frame = CGRectMake(ScreenWidth - 70, 30, 50, 50);
    [qrCodeBtn setImage:[UIImage imageNamed:@"scan_qrcode"] forState:UIControlStateNormal];
    [qrCodeBtn addTarget:self action:@selector(qrCodeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qrCodeBtn];
    
    [self.view addSubview:self.torchButton];
    [self.view addSubview:self.cameraButton];
    [self.view addSubview:self.takePhotoButton];
    
    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    videoButton.frame = CGRectMake(220, 30, 50, 30);
    [videoButton setTitle:@"视频" forState:UIControlStateNormal];
    [videoButton addTarget:self action:@selector(videoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:videoButton];
    
    
    UIImage *hbImage=[UIImage imageNamed:@"qbScanbg@2x"];
    UIImage * strectImage  = [hbImage stretchableImageWithLeftCapWidth:hbImage.size.width/2 topCapHeight:hbImage.size.height/2];
    _qrCodeView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2.0 - 120, ScreenHeight / 2.0 - 120, 240, 240)];
    _qrCodeView.image = strectImage;
    _qrCodeView.hidden = YES;
    [self.view addSubview:_qrCodeView];
    UIImage *lineImage = [UIImage imageNamed:@"qbScanLight@2x"];
    _qrLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, lineImage.size.height)];
    _qrLineView.image = lineImage;
    [_qrCodeView addSubview:_qrLineView];
    
    
    _phoneView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _phoneView.userInteractionEnabled = YES;
    _phoneView.contentMode = UIViewContentModeScaleAspectFill;
    _phoneView.hidden = YES;
    [self.view addSubview:_phoneView];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelButton.frame = CGRectMake(ScreenWidth / 4 - 25, ScreenHeight - 60, 50, 50);
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_phoneView addSubview:_cancelButton];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _saveButton.frame = CGRectMake(ScreenWidth / 4 * 3 - 25, ScreenHeight - 60, 50, 50);
    [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveButton setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_phoneView addSubview:_saveButton];
    
    _foucImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_focus_red@2x"]];
    [self.view addSubview:_foucImageView];

}

- (void)videoButtonAction
{
    videoDataFlag = !videoDataFlag;
    if (videoDataFlag) {
        stillImageFlag = NO;
        metadataOutputFlag = NO;
    } else {
        stillImageFlag = YES;
        metadataOutputFlag = NO;
    }
    
    
}

- (void)cancelBtnAction
{
    _phoneView.hidden = YES;
}

- (BOOL)judgelibrary
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
        [self openSetting];
        return NO;
    }
    return YES;
}

- (void)openSetting
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"打开访问系统权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString]];
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancleAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)saveButtonAction
{
    if ([self judgelibrary]) {
        [self saveImageToPhonoAlbum:_phoneView.image];
        _phoneView.hidden = YES;
    }
}

- (void)qrCodeBtnAction:(UIButton *)btn
{
    metadataOutputFlag = !metadataOutputFlag;
    if (metadataOutputFlag) {
        stillImageFlag = NO;
        videoDataFlag = NO;
        [btn setImage:[UIImage imageNamed:@"scan_qrcode1"] forState:UIControlStateNormal];
        [self qrLineAnimate];
        _qrCodeView.hidden = NO;
    }  else {
        stillImageFlag = YES;
        videoDataFlag = NO;
        [btn setImage:[UIImage imageNamed:@"scan_qrcode"] forState:UIControlStateNormal];
        _qrCodeView.hidden = YES;
    }
}

- (void)qrLineAnimate
{
    _qrLineView.frame = CGRectMake(0, 0, 240, _qrLineView.frame.size.height);
    [UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationOptionRepeat animations:^{
        _qrLineView.frame = CGRectMake(0, 240 - _qrLineView.frame.size.height, 240, _qrLineView.frame.size.height);
    } completion:nil];
}
- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark 初始化摄像头
- (void)initDevice
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([_device lockForConfiguration:nil]) {
        //自定义闪光灯
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自定义白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自定义对焦
        if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [_device unlockForConfiguration];
    }
}

#pragma mark 初始化视频输入输出流
- (void)initVideoDataOutput
{
    //1.1创建视频输入源
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_device error:nil];
    //1.2将视频输入源添加到会话
    if ([_session canAddInput:self.videoInput]) {
        [_session addInput:self.videoInput];
    }
    
    //1.3将视频输出源添加到会话
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    //立即丢弃旧帧，节省内存，默认YES
    _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    [_videoDataOutput setSampleBufferDelegate:self queue:self.writeQueue];
    //设置像素格式，否则CMSampleBufferRef转换NSImage的时候CGContextRef初始化会出问题
//    [_videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    //1.4将视频输出源添加到会话
    if ([_session canAddOutput:self.videoDataOutput]) {
        [_session addOutput:self.videoDataOutput];
    }

}

#pragma mark 初始化音频输入输出
- (void)initAudioData
{
    // 1.1 获取音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    // 1.2 创建音频输入源
    NSError *error = nil;
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    // 1.3 添加音频输入源到会话
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
    
    // 1.4 创建音频输出源
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.writeQueue];
    // 1.5 添加音频输出源到会话
    if ([self.session canAddOutput:self.audioDataOutput]) {
        [self.session addOutput:self.audioDataOutput];
    }
    
}

#pragma mark 初始化静态图片扑捉
- (void)initStillImageOutput
{
    //2.1创建静态图片捕捉(用于拍照)
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //2.2将静态图片扑捉添加到会话
    if ([_session canAddOutput:_stillImageOutput]) {
        [_session addOutput:_stillImageOutput];
    }
}

#pragma mark 初始化二维码扫描输出流
- (void)initMetadataOutput
{
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置扫描区域
    _metadataOutput.rectOfInterest = self.view.bounds;
    
    //3.1将视频扫描输出源添加到会话
    if ([_session canAddOutput:self.metadataOutput]) {
        [_session addOutput:_metadataOutput];
        self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
        return ;
#ifndef FACE
        //设置扫码格式
        self.metadataOutput.metadataObjectTypes = @[
                                                    AVMetadataObjectTypeQRCode,
                                                    AVMetadataObjectTypeEAN13Code,
                                                    AVMetadataObjectTypeEAN8Code,
                                                    AVMetadataObjectTypeCode128Code
                                                    ];
#else
        self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
#endif
    }
}

#pragma mark 初始session
- (void)initCaptureSession
{
    _session = [[AVCaptureSession alloc] init];
    //设置分辨率
    if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
    //添加视频输入输出源
    [self initVideoDataOutput];
    
    //添加音频输入输出
    [self initAudioData];
    
    //添加静态图片捕捉
    [self initStillImageOutput];
    
    //添加视频数据输出源（用于二维码）
    [self initMetadataOutput];
    
}

#pragma mark 初始化预览层
- (void)initPreviewLayer
{
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:_previewLayer];
}


#pragma mark - 手电筒
- (UIButton *)torchButton
{
    if (_torchButton == nil) {
        _torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _torchButton.frame = CGRectMake(80.0f, 30.0f, 50.0f, 30.0f);
        [_torchButton setImage:[UIImage imageNamed:@"flash_icon"] forState:UIControlStateNormal];
        [_torchButton setImage:[UIImage imageNamed:@"flash_icon1"] forState:UIControlStateSelected];
        [_torchButton addTarget:self action:@selector(openTorch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _torchButton;
}
-(void)openTorch:(UIButton*)button{
    button.selected = !button.selected;
    [self turnTorchOn:button.selected];
}

- (void)turnTorchOn:(BOOL)on{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        if ([self.device hasTorch] && [self.device hasFlash]){
            [self.device lockForConfiguration:nil];
            if (on) {
                [self.device setTorchMode:AVCaptureTorchModeOn];
                
            } else {
                [self.device setTorchMode:AVCaptureTorchModeOff];
            }
            [self.device unlockForConfiguration];
        }
    }
}
#pragma mark - 切换前后摄像头
- (UIButton *)cameraButton
{
    if (_cameraButton == nil) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraButton.frame = CGRectMake(150, 30.0f, 50.0f, 30.0f);
        [_cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (void)switchCamera
{
    NSInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[self.videoInput device] position];
        if (position == AVCaptureDevicePositionFront) {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.videoInput = newInput;
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
#pragma mark - 拍照
- (UIButton *)takePhotoButton
{
    if (_takePhotoButton == nil) {
        _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _takePhotoButton.frame = CGRectMake(ScreenWidth / 2.0 - 35, ScreenHeight - 80, 70, 70);
        _takePhotoButton.layer.cornerRadius = 35;
        _takePhotoButton.layer.masksToBounds = YES;
        _takePhotoButton.layer.borderWidth = 2;
        _takePhotoButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _takePhotoButton.backgroundColor = [UIColor redColor];
        [_takePhotoButton setTitle:@"拍照" forState:UIControlStateNormal];
        [_takePhotoButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
        [_takePhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _takePhotoButton;
}

- (void)takePhoto
{
    if (stillImageFlag) {
        [self screenShot];
    }  else if (videoDataFlag) {
        if (self.recordState != VideoRecordStateRecording) {
            [self startRecordVideo];
        } else {
            [self stopRecord];
        }
        
    }
}

//开始写入数据
- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType
{
    if (sampleBuffer == NULL){
        NSLog(@"empty sampleBuffer");
        return;
    }
    
    @synchronized(self){
        if (self.recordState < VideoRecordStateRecording){
            NSLog(@"not ready yet");
            return;
        }
    }
    
    CFRetain(sampleBuffer);
    dispatch_async(self.writeQueue, ^{
        @autoreleasepool {
            @synchronized(self) {
                if (self.recordState > VideoRecordStateRecording){
                    CFRelease(sampleBuffer);
                    return;
                }
            }
            if (!self.canWrite && mediaType == AVMediaTypeVideo) {
                [self.assetWriter startWriting];
                [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                self.canWrite = YES;
            }
            
//            if (!_timer) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
//                });
//                
//            }
            //写入视频数据
            if (mediaType == AVMediaTypeVideo) {
                if (self.assetWriterVideoInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        @synchronized (self) {
                            [self stopRecord];
                            [self destroyWrite];
                        }
                    }
                }
            }
            
            //写入音频数据
            if (mediaType == AVMediaTypeAudio) {
                if (self.assetWriterAudioInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        @synchronized (self) {
                            [self stopRecord];
                            [self destroyWrite];
                        }
                    }
                }
            }
            
            CFRelease(sampleBuffer);
        }
    } );
}



- (void)startRecordVideo
{
    self.recordState = VideoRecordStateInit;
    if (self.assetWriter) {
        return;
    }

    NSError *error;

    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoUrl.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.videoUrl.path error:nil];
    }
    self.assetWriter = [AVAssetWriter assetWriterWithURL:self.videoUrl fileType:AVFileTypeMPEG4 error:&error];
    //写入视频大小
    NSInteger numPixels = self.outputSize.width * self.outputSize.height;
    //每像素比特
    CGFloat bitsPerPixel = 6.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(30),
                                             AVVideoMaxKeyFrameIntervalKey : @(30),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
    
    //视频属性
    self.videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                       AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                       AVVideoWidthKey : @(self.outputSize.height),
                                       AVVideoHeightKey : @(self.outputSize.width),
                                       AVVideoCompressionPropertiesKey : compressionProperties };
    
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoCompressionSettings];
    //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    _assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    
    
    // 音频设置
    self.audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
                                       AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                       AVNumberOfChannelsKey : @(1),
                                       AVSampleRateKey : @(22050) };
    
    
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioCompressionSettings];
    _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    
    
    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    }else {
        NSLog(@"AssetWriter videoInput append Failed");
    }
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    }else {
        NSLog(@"AssetWriter audioInput Append Failed");
    }
    self.recordState = VideoRecordStateRecording;
}



- (void)stopRecord
{
    self.recordState = VideoRecordStateFinish;
    __weak AVCaptureSessionViewController *weakself = self;
    if (_assetWriter && _assetWriter.status == AVAssetWriterStatusWriting) {
        dispatch_async(self.writeQueue, ^{
            [_assetWriter finishWritingWithCompletionHandler:^{
                if ([self judgelibrary]) {
                    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
                    [lib writeVideoAtPathToSavedPhotosAlbum:weakself.videoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
                        [weakself destroyWrite];
                        NSLog(@"video存入相册 %@", error);
                        if (!error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                AVPlayerViewController *player = [[AVPlayerViewController alloc] init];
                                player.playerUrl = self.videoUrl;
                                [self presentViewController:player animated:YES completion:nil];
                                
                            });
                        }
                    }];
                }
            }];
        });
    }
    
}


- (void)screenShot
{
    AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"拍照失败");
        return;
    }
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        _phoneView.image = image;
        _phoneView.hidden = NO;
    }];
}

- (void)saveImageToPhonoAlbum:(UIImage *)savedimage {
    UIImageWriteToSavedPhotosAlbum(savedimage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

//指定回调方法
- (void)image: (UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (image == nil) {
        return;
    }
    NSString *msg = @"保存图片成功";
    if(error != NULL){
        msg = @"保存图片失败" ;
    }
    NSLog(@"%@",msg);
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate / AVCaptureAudioDataOutputSampleBufferDelegate
//AVCaptureVideoDataOutput获取实时图像，这个代理方法的回调频率很快，几乎与手机屏幕的刷新频率一样快
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

//    //设置图像方向，否则largeImage取出来是反的
//    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//    largeImage = [self imageFromSampleBuffer:sampleBuffer];
//    smallImage = [largeImage imageCompressTargetSize:CGSizeMake(512.0f, 512.0f)];
    
    @autoreleasepool {
        
        //视频
        if (connection == [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo]) {
            
            if (!self.outputVideoFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.outputVideoFormatDescription = formatDescription;
                }
            } else {
                @synchronized(self) {
                    if (self.recordState == VideoRecordStateRecording) {
                        [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
                    }
                    
                }
            }
            
            
        }
        
        //音频
        if (connection == [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio]) {
            if (!self.outputAudioFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.outputAudioFormatDescription = formatDescription;
                }
            }
            @synchronized(self) {
                
                if (self.recordState == VideoRecordStateRecording) {
                    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
                }
                
            }
            
        }
    }

    
}



//CMSampleBufferRef转NSImage
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context); CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return (image);
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (!metadataOutputFlag) {
        if (metadataObjects.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self metadataFaceForArray:metadataObjects];
            });
        }
        return;
    }
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex :0];
#ifndef FACE
        [self.session stopRunning];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"识别结果" message:metadataObject.stringValue preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.session startRunning];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
#else
        AVMetadataObject *faceData = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        NSLog(@"faceData is : %@",faceData);
#endif
    }
}

- (void)metadataFaceForArray:(NSArray *)array
{
    AVMetadataMachineReadableCodeObject *metadataObject = [array objectAtIndex :0];
    if (metadataObject.type == AVMetadataObjectTypeFace) {
        AVMetadataObject *objec = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        NSLog(@"************face: %@",objec);
        _foucImageView.frame = objec.bounds;
    }
}


- (void)destroyWrite
{
    self.assetWriter = nil;
    self.assetWriterAudioInput = nil;
    self.assetWriterVideoInput = nil;
//    self.videoUrl = nil;
//    self.recordTime = 0;
//    [self.timer invalidate];
//    self.timer = nil;
    
}


- (void)dealloc
{
    NSLog(@"AVCaptureSessionViewController dealloc");
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
