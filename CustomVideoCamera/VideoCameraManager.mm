//
//  VideoCameraManager.m
//  iShow
//
//  Created by student on 2017/7/3.
//
//

#import "VideoCameraManager.h"
// #import "testfacedetect_oc.h"
// #import <opencv2/opencv.hpp>

@implementation VideoCameraManager

#pragma mark - 人脸识别 -
/**
 初始化人脸识别sdk
 */
- (void)initTestFaceDetect {
  //    _haveDoneFaceDetectInit = NO;
  //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
  //
  //        NSString *location = [[NSBundle mainBundle] resourcePath];
  //        NSString *pathStr = [location stringByAppendingString:@"/config"];
  //        const char *c_path = [pathStr UTF8String];
  //        uint8_t *u_path = (uint8_t *)c_path;
  //        ISLog(@"start init FaceDetect");
  //        //这里面初始化人脸识别的SDK，时间有点长。
  //        BOOL faceDetect = [testfacedetect_oc InitFaceDetect_OC:u_path];
  //        ISLog(@"initFaceDetectSucceed:------->:%d",faceDetect);
  //        dispatch_async(dispatch_get_main_queue(), ^{
  //            _haveDoneFaceDetectInit = faceDetect;
  //        });
  //
  //    });
}

- (void)openFaceDetect:(BOOL)open {
  //    if (_haveDoneFaceDetectInit == NO && open == YES) {
  //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
  //            [self openFaceDetect:open];
  //        });
  //        return;
  //    }
  //    // 眼睛
  //    [testfacedetect_oc SetEyesEnable_OC:open];
  //    // 颧骨
  //    [testfacedetect_oc SetCheekboneEnable_OC:open];
  //    // 面颊
  //    [testfacedetect_oc SetCheeksEnable_OC:open];
  //    // 下巴
  //    [testfacedetect_oc SetChinEnable_OC:open];
}

- (void)setBigEyesParameter:(CGFloat)parameter {
  //    if (_haveDoneFaceDetectInit == NO ) {
  //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
  //            [self setBigEyesParameter:parameter];
  //        });
  //        return;
  //    }
  //
  //    [testfacedetect_oc setEyesRange_OC:parameter * 0.5];
}

- (void)setThinFaceParameter:(CGFloat)parameter {
  //    if (_haveDoneFaceDetectInit == NO ) {
  //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
  //            [self setThinFaceParameter:parameter];
  //        });
  //        return;
  //    }
  //    [testfacedetect_oc setCheekboneRange_OC:parameter];
  //    [testfacedetect_oc setCheeksRange_OC:parameter];
  //    [testfacedetect_oc setChinRange_OC:parameter];
}

- (void)UnInitFaceDetect {
  //    [testfacedetect_oc UnInitFaceDetect_OC];
}

#pragma mark -

- (id)initWithSessionPreset:(NSString*)sessionPreset
             cameraPosition:(AVCaptureDevicePosition)cameraPosition {
  self =
      [super initWithSessionPreset:sessionPreset cameraPosition:cameraPosition];
  if (self) {
    /*  // 人脸识别 需要更改的rgb的数据，所以需要打开此处，否则返回的samplebuffer是YUV的格式
        [videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                                  forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        BOOL isFullYUVRange = [self valueForKey:@"isFullYUVRange"];
        isFullYUVRange = NO;
        captureAsYUV = NO;
        self.horizontallyMirrorFrontFacingCamera = YES;
        self.horizontallyMirrorRearFacingCamera = YES;
         */
  }
  return self;
}

/** Process a video sample
 @param sampleBuffer Buffer to process
 */
// - (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
// {
//    @autoreleasepool {
//        if (self.cameraPosition == AVCaptureDevicePositionFront) {  // 前置摄像头
//            // 实现预览效果不断设置Image
//            CVImageBufferRef cvImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
//            // 转换类型
//            CVPixelBufferRef cvPixelBufferRef = cvImageBufferRef;
//            // 如果想要对数据进行修改就必须对向前数据进行锁定
//            CVPixelBufferLockBaseAddress(cvPixelBufferRef, kCVPixelBufferLock_ReadOnly);
//            // 处理图像数据
//            // 图像出来的原始数据是 R G R A 每个像素 4 个字节 32 位的数据
//            // 获取宽高
//            size_t width = CVPixelBufferGetWidth(cvPixelBufferRef);
//            size_t height = CVPixelBufferGetHeight(cvPixelBufferRef);
//            // 获取指向数据内容的指针
//            unsigned char *pImageData = (unsigned char *)CVPixelBufferGetBaseAddress(cvPixelBufferRef);
//            [testfacedetect_oc DetectImage_OC:pImageData width:(int)width height:(int)height];
//
//            CVPixelBufferUnlockBaseAddress(cvPixelBufferRef, kCVPixelBufferLock_ReadOnly);

//        }
//        [super processVideoSampleBuffer:sampleBuffer];
//    }
// }

/**
 更正 摄像头输出的图片方向

 @param isBeautifyFilter 是否 美颜
 */
- (void)updateOrientation {
  if ([self cameraPosition] == AVCaptureDevicePositionBack) {  // 后摄像头
    //        [videoOutput connectionWithMediaType:AVMediaTypeVideo].videoMirrored = NO;
    AVCaptureConnection* conn = videoOutput.connections.firstObject;
    if ([conn isVideoOrientationSupported]) {
      conn.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }

  } else  // 前置摄像头
  {
    [videoOutput connectionWithMediaType:AVMediaTypeVideo].videoMirrored = YES;
    AVCaptureConnection* conn = videoOutput.connections.firstObject;
    if ([conn isVideoOrientationSupported]) {
      conn.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    //
  }
}

@end
