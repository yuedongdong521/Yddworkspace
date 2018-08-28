//
//  ISVideoCameraTools.h
//  iShow
//
//  Created by student on 2017/7/17.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ISVideoCameraTools : NSObject
/**
 将UI的坐标转换成相机坐标
 
 @param viewCoordinates 用户点击的位置
 @param rect 相机视图rect
 @return 点击的位置相对于相机坐标的位置
 */
+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                        videoViewFrame:(CGRect)rect;

/**
 创建 路径下 的文件夹，如果这个文件夹不存在

 @param path 文件夹路径
 */
+ (void)createFolderIfNotExistAtPath:(NSString*)path;

+ (NSString*)getVideoCameraFolderPath;
+ (NSString*)getEditVideofolderPath;
+ (NSString*)getPublicVideofolderPath;
// 合成IS拍摄的视频的路径
+ (NSString*)getVideoMergeFilePathString;
// 音乐合成后的视频路径
+ (NSURL*)getMixMusicOutPutVideoURL;
// 滤镜合成后的视频路径
+ (NSURL*)getMixFilterOutPutVideoURL;

/**
 获取视频时长 单位是s

 @param asset AVAsset
 @return 秒
 */
+ (NSInteger)getVideoTime:(AVAsset*)asset;

/**
 获取视频的宽高

 @param asset
 @return cgsize
 */
+ (CGSize)getVideoNaturalSize:(AVAsset*)asset;

/**
 压缩视频到指定分辨率

 @param asset
 @param size 指定的分辨率尺寸
 @param completion 压缩完成后的回调，videoUrl为导出的视频的路径。
 */
+ (void)compressVideo:(AVAsset*)asset
            finalSize:(CGSize)size
           completion:(void (^)(BOOL isSucceed, NSURL* videoUrl))completion;

/**
 压缩视频，采用系统方法

 @param asset
 @param completion 完成后的回调。
 */
+ (void)compressVideoThroughSystemMehtod:(AVAsset*)asset
                              completion:(void (^)(BOOL isSucceed,
                                                   NSURL* videoUrl))completion;

/**
 清除小视频模块的视频缓存

 @return 清除是否 成功
 */
+ (BOOL)clearTmpVideoCache;
@end
