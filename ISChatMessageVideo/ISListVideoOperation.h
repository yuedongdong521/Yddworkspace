//
//  ISListVideoOperation.h
//  iShow
//
//  Created by ispeak on 2018/1/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 视频文件解析回调
 @param videoImageRef 视频每帧截图的CGImageRef图像信息
 @param videoFilePath 视频路径地址
 */
typedef void (^VideoDecode)(CGImageRef videoImageRef, NSString* videoFilePath);

/**
 视频停止播放
 @param videoFilePath 视频路径地址
 */
typedef void (^VideoStop)(NSString* videoFilePath);

@interface ISListVideoOperation : NSBlockOperation

@property(nonatomic, copy) VideoDecode videoDecodeBlock;
@property(nonatomic, copy) VideoStop videoStopBlock;

- (void)videoPlayTask:(NSString*)videoFilePath;

@end
