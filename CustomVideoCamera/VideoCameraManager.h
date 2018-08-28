//
//  VideoCameraManager.h
//  iShow
//
//  Created by student on 2017/7/3.
//
//

#import <GPUImage/GPUImage.h>

@interface VideoCameraManager : GPUImageVideoCamera

@property(nonatomic, assign) BOOL haveDoneFaceDetectInit;  //

// 重写的 父类的初始化方法
- (id)initWithSessionPreset:(NSString*)sessionPreset
             cameraPosition:(AVCaptureDevicePosition)cameraPosition;

/**
 更正 摄像头输出的图片方向
 
 @param isBeautifyFilter 是否 美颜
 */
- (void)updateOrientation;

/**
 初始化人脸识别sdk
 */
// - (void)initTestFaceDetect;
// - (void)openFaceDetect:(BOOL)open;
// - (void)setThinFaceParameter:(CGFloat)parameter;
// - (void)setBigEyesParameter:(CGFloat)parameter;
// - (void)UnInitFaceDetect;
@end
