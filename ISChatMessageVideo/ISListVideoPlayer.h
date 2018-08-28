//
//  ISListVideoPlayer.h
//  iShow
//
//  Created by ispeak on 2018/1/5.
//

#import <Foundation/Foundation.h>
#import "ISListVideoOperation.h"

@interface ISListVideoPlayer : NSObject

/**
 视频播放操作Operation存放字典，key为视频地址
 */
@property(nonatomic, strong) NSMutableDictionary* videoOperationDict;
/**
 视频播放操作Operation队列
 */
@property(nonatomic, strong) NSOperationQueue* videoOperationQueue;

/**
 播放工具单例
 */
+ (instancetype)sharedPlayer;

/**
 播放一个本地视频

 @param filePath 视频路径
 @param videoDecode 视频每一帧的图像信息回调
 @param videoId 视频id
 */
- (void)startPlayVideo:(NSString*)filePath
               VideoId:(NSInteger)videoId
       withVideoDecode:(VideoDecode)videoDecode;

/**
 循环播放视频

 @param videoStop 停止回调
 @param filePath 视频路径
 @param  videoId视频id
 */
- (void)reloadVideoPlay:(VideoStop)videoStop
           withFilePath:(NSString*)filePath
            withVideoId:(NSInteger)videoId;

/**
 取消视频播放同时从视频播放队列缓存移除
 @param videoKey 视频在cell上的index位置row
 */
- (void)cancelVideo:(NSString*)videoKey;

/**
 取消所有当前播放的视频
 */
- (void)cancelAllVideo;

@end
