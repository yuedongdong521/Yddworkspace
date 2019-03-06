//
//  TestVideoCaptureViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/14.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TestVideoCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ISH264Player.h"
#import "VideoFilter.h"
@interface TestVideoCaptureViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
  dispatch_queue_t _playerQueue;
}
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic, strong) ISH264Player *player;


@end

@implementation TestVideoCaptureViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  AVAuthorizationStatus status =
  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  if (status == AVAuthorizationStatusDenied) {
    UIAlertController* alertController = [UIAlertController
                                          alertControllerWithTitle:@"温馨提示"
                                          message:@"没有开启相机权限"
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController
     addAction:[UIAlertAction
                actionWithTitle:@"确定"
                style:UIAlertActionStyleDefault
                handler:^(UIAlertAction* _Nonnull action) {
                  [self dismissViewControllerAnimated:YES
                                           completion:nil];
                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
  } else {
    //开始采集
    [self.captureSession startRunning];
  }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  _player = [[ISH264Player alloc] initWithFrame:self.view.bounds];
  [self.view.layer addSublayer:_player];
  
  _playerQueue = dispatch_queue_create("com.ydd.playerQueue", DISPATCH_QUEUE_SERIAL);
  
  [self initVideoSession];
  [VideoFilter lookupFilter];
}

- (void)initVideoSession
{
  _captureSession = [[AVCaptureSession alloc] init];
  [_captureSession beginConfiguration];
  [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
  AVCaptureDevice *inputCamera = [self getCaptureDeviceForCaptureDevicePosition:AVCaptureDevicePositionFront];
  if (!inputCamera) {
    return;
  }

  _deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
  if ([_captureSession canAddInput:_deviceInput]) {
    [_captureSession addInput:_deviceInput];
  }
  // 设置输出数据
  _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
  [_videoDataOutput setAlwaysDiscardsLateVideoFrames:NO];
  
  [_videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
  [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
  
  if ([_captureSession canAddOutput:_videoDataOutput]) {
    [_captureSession addOutput:_videoDataOutput];
  }
  [_captureSession commitConfiguration];
  
  // 获取连接并设置视频方向为竖屏方向
  _videoConnection = [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
  _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
  
  // 设置是否为镜像，前置摄像头采集到的数据本来就是翻转的，这里设置为镜像把画面转回来
  if (_deviceInput.device.position == AVCaptureDevicePositionFront && _videoConnection.supportsVideoMirroring)
  {
    _videoConnection.videoMirrored = YES;
  }
}

- (AVCaptureDevice *)getCaptureDeviceForCaptureDevicePosition:(AVCaptureDevicePosition)postion
{
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  for (AVCaptureDevice *device in devices) {
    if (device.position == postion) {
      return device;
    }
  }
  return nil;
}

- (void)changeCurCaptureDevice
{
  AVCaptureDevice *changeDevice = nil;
  if (_deviceInput.device.position == AVCaptureDevicePositionFront) {
    changeDevice = [self getCaptureDeviceForCaptureDevicePosition:AVCaptureDevicePositionBack];
  } else {
    changeDevice = [self getCaptureDeviceForCaptureDevicePosition:AVCaptureDevicePositionFront];
  }
  if (!changeDevice) {
    return;
  }
  AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:changeDevice error:nil];
  if (!deviceInput) {
    return;
  }
  [self.captureSession beginConfiguration];
  [_captureSession removeInput:_deviceInput];
  if ([_captureSession canAddInput:deviceInput]) {
    [_captureSession addInput:deviceInput];
    _deviceInput = deviceInput;
  } else {
    [_captureSession addInput:_deviceInput];
  }
  [self.captureSession commitConfiguration];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
  CFRetain(sampleBuffer);
  dispatch_async(_playerQueue, ^{
    if (output == self.videoDataOutput) {
      CVPixelBufferRef pixelbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
      
//      _player.pixelBuffer = [self useGPUCupPixelBuffer:pixelbuffer];
      _player.pixelBuffer = [VideoFilter addFilterForPixelbuffer:pixelbuffer];
    }
    CFRelease(sampleBuffer);
  });
}

- (CVPixelBufferRef)useGPUCupPixelBuffer:(CVPixelBufferRef)buffer
{
  static CVPixelBufferRef pixbuffer = NULL;
  static OSStatus status;
  static CGRect rect;
  /*
   如果要进行页面渲染，需要一个和OpenGL缓冲兼容的图像。用相机API创建的图像已经兼容，您可以马上映射他们进行输入。假设你从已有画面中截取一个新的画面，用作其他处理，你必须创建一种特殊的属性用来创建图像。对于图像的属性必须有kCVPixelBufferIOSurfacePropertiesKey 作为字典的Key.因此以下步骤不可省略
   */
  if (pixbuffer == NULL) {
    CGFloat h = CVPixelBufferGetHeight(buffer);
    CGFloat w = CVPixelBufferGetWidth(buffer);
    rect = CGRectMake(0, 0, w, h);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:rect.size.width], kCVPixelBufferWidthKey, [NSNumber numberWithInt:rect.size.height], kCVPixelBufferHeightKey, nil];
    status = CVPixelBufferCreate(kCFAllocatorSystemDefault, rect.size.width, rect.size.height, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, (__bridge CFDictionaryRef)options, &pixbuffer);
    if (status != noErr) {
      NSLog(@"Crop CVPixelBufferCreate error %d",(int)status);
      return NULL;
    }
  }
  CIImage *ciImage = [CIImage imageWithCVPixelBuffer:buffer];
  ciImage = [ciImage imageByCroppingToRect:rect];
  ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y)];
  static CIContext *ciContext = nil;
  if (ciContext == nil) {
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    ciContext = [CIContext contextWithEAGLContext:eaglContext options:nil];
  }
  [ciContext render:ciImage toCVPixelBuffer:pixbuffer];
//  buffer = CVPixelBufferRetain(pixbuffer);
//  CVPixelBufferRelease(pixbuffer);
  return pixbuffer;
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
