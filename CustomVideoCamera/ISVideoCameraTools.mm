//
//  ISVideoCameraTools.m
//  iShow
//
//  Created by student on 2017/7/17.
//
//

#import "ISVideoCameraTools.h"
#import "ISAlbumListViewController.h"
#import "SDAVAssetExportSession.h"
#import <AVFoundation/AVFoundation.h>

#define EDIT_VIDEO_FOLDER \
  @"editVideoFolder"  // 拍摄后 合成的视频 之后的滤镜合成，音乐合成 均在此文件夹下
#define PUBLIC_VIDEO_FOLDER \
  @"publishVideoFolder"  // 导入本地小视频压缩 上传时压缩的文件夹 包括IS拍摄的小视频上传前的压缩
#define VIDEO_CAMERA_FOLDER @"VideoCameraFolder"  // 拍摄界面 记录的零碎的小视频

typedef NS_ENUM(
    NSInteger,
    VideoPathType) {  // 主要用于选择沙盒路径,仅在方法getOutPutVideoURL中使用
  VideoPathTypeCompressTempleSystem,  // 系统压缩
  VideoPathTypeCompressSD,  // SDAVAssetExportSession压缩
  VideoPathTypeMixMusic,  // 音乐合成
  VideoPathTypeMixFilter  // 滤镜合成
};

@implementation ISVideoCameraTools

/**
 将UI的坐标转换成相机坐标

 @param viewCoordinates 用户点击的位置
 @param rect 相机视图rect
 @return 点击的位置相对于相机坐标的位置
 */
+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                        videoViewFrame:(CGRect)rect {
  CGPoint pointOfInterest = CGPointMake(.5f, .5f);
  CGSize frameSize = rect.size;
  CGSize apertureSize = CGSizeMake(1280, 720);  // 设备采集分辨率
  CGPoint point = viewCoordinates;
  CGFloat apertureRatio = apertureSize.height / apertureSize.width;
  CGFloat viewRatio = frameSize.width / frameSize.height;
  CGFloat xc = .5f;
  CGFloat yc = .5f;

  if (viewRatio > apertureRatio) {
    CGFloat y2 = frameSize.height;
    CGFloat x2 = frameSize.height * apertureRatio;
    CGFloat x1 = frameSize.width;
    CGFloat blackBar = (x1 - x2) / 2;
    if (point.x >= blackBar && point.x <= blackBar + x2) {
      xc = point.y / y2;
      yc = 1.f - ((point.x - blackBar) / x2);
    }
  } else {
    CGFloat y2 = frameSize.width / apertureRatio;
    CGFloat y1 = frameSize.height;
    CGFloat x2 = frameSize.width;
    CGFloat blackBar = (y1 - y2) / 2;
    if (point.y >= blackBar && point.y <= blackBar + y2) {
      xc = ((point.y - blackBar) / y2);
      yc = 1.f - (point.x / x2);
    }
  }
  pointOfInterest = CGPointMake(xc, yc);
  return pointOfInterest;
}

// 最后合成为 mp4
+ (NSString*)getVideoMergeFilePathString {
  // 沙盒中Temp路径
  NSString* path = [self getEditVideofolderPath];
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyyMMddHHmmss";
  NSString* nowTimeStr =
      [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
  NSString* fileName = [[path stringByAppendingPathComponent:nowTimeStr]
      stringByAppendingString:@"merge.mov"];

  return fileName;
}

+ (NSInteger)getVideoTime:(AVAsset*)asset {
  @autoreleasepool {
    CMTime time = [asset duration];
    NSInteger seconds = ceil(time.value / time.timescale);
    ISLog(@"视频时长:seconds--->>%ld秒", (long)seconds);
    return seconds;
  }
}

+ (CGSize)getVideoNaturalSize:(AVAsset*)asset {
  @autoreleasepool {
    NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (tracks.count > 0) {
      AVAssetTrack* videoTrack = [tracks objectAtIndex:0];
      // 这里的矩阵有旋转角度，转换一下即可
      CGAffineTransform videoTransform = videoTrack.preferredTransform;

      // UIImageOrientation videoAssetOrientation_ = UIImageOrientationUp;
      BOOL isVideoAssetPortrait = NO;

      if (videoTransform.a == 0 && videoTransform.b == 1.0 &&
          videoTransform.c == -1.0 && videoTransform.d == 0) {
        // videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait = YES;
      } else if (videoTransform.a == 0 && videoTransform.b == -1.0 &&
                 videoTransform.c == 1.0 && videoTransform.d == 0) {
        // videoAssetOrientation_ = UIImageOrientationLeft;
        isVideoAssetPortrait = YES;
      }
      /*
      else if (videoTransform.a == 1.0 && videoTransform.b == 0 &&
                 videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ = UIImageOrientationUp;
      } else if (videoTransform.a == -1.0 && videoTransform.b == 0 &&
                 videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
      }
      */

      CGSize naturalSize;
      if (isVideoAssetPortrait) {
        naturalSize = CGSizeMake(videoTrack.naturalSize.height,
                                 videoTrack.naturalSize.width);
      } else {
        naturalSize = videoTrack.naturalSize;
      }
      return naturalSize;
    } else {
      return CGSizeMake(360, 640);
    }
  }
}

+ (void)compressVideo:(AVAsset*)asset
            finalSize:(CGSize)size
           completion:(void (^)(BOOL isSucceed, NSURL* videoUrl))completion {
  NSURL* outputVideoUrl =
      [ISVideoCameraTools getOutPutVideoURL:VideoPathTypeCompressSD];
  NSArray* keys = @[ @"tracks", @"duration", @"commonMetadata" ];
  [asset
      loadValuesAsynchronouslyForKeys:keys
                    completionHandler:^{
                      // provide inputVideo Url Here
                      SDAVAssetExportSession* compressionEncoder =
                          [[SDAVAssetExportSession alloc] initWithAsset:asset];

                      compressionEncoder.outputFileType = AVFileTypeMPEG4;
                      compressionEncoder.outputURL =
                          outputVideoUrl;  // Provide output video Url here
                      compressionEncoder.shouldOptimizeForNetworkUse = YES;
                      compressionEncoder.videoSettings = @{
                        AVVideoCodecKey : AVVideoCodecH264,
                        AVVideoWidthKey : @(size.width),
                        AVVideoHeightKey : @(size.height),
                        AVVideoCompressionPropertiesKey : @{
                          AVVideoAverageBitRateKey : @2500000,
                          AVVideoProfileLevelKey :
                              AVVideoProfileLevelH264HighAutoLevel,
                          AVVideoAverageNonDroppableFrameRateKey : @30,
                        },
                      };
                      compressionEncoder.audioSettings = @{
                        AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                        AVNumberOfChannelsKey : @2,
                        AVSampleRateKey : @44100,
                        AVEncoderBitRateKey : @128000,
                      };
                      [compressionEncoder
                          exportAsynchronouslyWithCompletionHandler:^{
                            ISLog(@" 当前线程  %@", [NSThread currentThread]);
                            dispatch_async(dispatch_get_main_queue(), ^{
                              // 更新UI操作
                              if (compressionEncoder.status ==
                                  AVAssetExportSessionStatusCompleted) {
                                ISLog(
                                    @"Compression Export Completed "
                                    @"Successfully");
                                if (completion) {
                                  completion(YES, outputVideoUrl);
                                }
                              } else {
                                ISLog(@"Compression Failed");
                                if (completion) {
                                  completion(NO, outputVideoUrl);
                                }
                              }
                            });
                          }];
                    }];
}
// 系统的压缩方法
+ (void)compressVideoThroughSystemMehtod:(AVAsset*)asset
                              completion:(void (^)(BOOL isSucceed,
                                                   NSURL* videoUrl))completion {
  // NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
  NSURL* outputVideoUrl =
      [ISVideoCameraTools getOutPutVideoURL:VideoPathTypeCompressTempleSystem];
  NSArray* keys = @[ @"tracks", @"duration", @"commonMetadata" ];
  [asset
      loadValuesAsynchronouslyForKeys:keys
                    completionHandler:^{
                      AVAssetExportSession* exporter =
                          [[AVAssetExportSession alloc]
                              initWithAsset:asset
                                 presetName:AVAssetExportPreset640x480];
                      exporter.outputURL = outputVideoUrl;
                      exporter.outputFileType = AVFileTypeMPEG4;
                      exporter.shouldOptimizeForNetworkUse = YES;
                      [exporter exportAsynchronouslyWithCompletionHandler:^{
                        if (exporter.status ==
                            AVAssetExportSessionStatusCompleted) {  // 导出成功
                          dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                              completion(YES, outputVideoUrl);
                            }
                          });
                        } else {  // 导出失败
                          dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                              completion(NO, outputVideoUrl);
                            }
                          });
                        }
                      }];
                    }];
}

+ (void)createFolderIfNotExistAtPath:(NSString*)path {
  // 沙盒中文件夹路径
  NSString* folderPath = path;

  NSFileManager* fileManager = [NSFileManager defaultManager];
  BOOL isDir = NO;
  BOOL isDirExist =
      [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];

  if (!(isDirExist && isDir)) {
    BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:nil];
    if (!bCreateDir) {
      ISLog(@"创建保存视频文件夹失败");
    }
  }
}

#pragma mark - 获取路径
+ (NSString*)getVideoCameraFolderPath {
  // 沙盒中Temp路径
  NSString* tempPath = NSTemporaryDirectory();
  NSString* folderPath =
      [tempPath stringByAppendingPathComponent:VIDEO_CAMERA_FOLDER];
  [self createFolderIfNotExistAtPath:folderPath];
  return folderPath;
}

+ (NSString*)getEditVideofolderPath {
  // 沙盒中Temp路径
  NSString* tempPath = NSTemporaryDirectory();
  NSString* folderPath =
      [tempPath stringByAppendingPathComponent:EDIT_VIDEO_FOLDER];
  [self createFolderIfNotExistAtPath:folderPath];
  return folderPath;
}

+ (NSString*)getPublicVideofolderPath {
  // 沙盒中Temp路径
  NSString* tempPath = NSTemporaryDirectory();
  NSString* folderPath =
      [tempPath stringByAppendingPathComponent:PUBLIC_VIDEO_FOLDER];
  [self createFolderIfNotExistAtPath:folderPath];
  return folderPath;
}

+ (NSURL*)getMixMusicOutPutVideoURL {
  return [self getOutPutVideoURL:VideoPathTypeMixMusic];
}

+ (NSURL*)getMixFilterOutPutVideoURL {
  return [self getOutPutVideoURL:VideoPathTypeMixFilter];
}

+ (NSURL*)getOutPutVideoURL:(VideoPathType)type {
  @autoreleasepool {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString* nowTimeStr =
        [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];

    NSString* finalVideoURLString;
    switch (type) {
      case VideoPathTypeCompressTempleSystem: {
        NSString* tempString =
            [NSString stringWithFormat:@"compressedVideoSys%@.mp4", nowTimeStr];
        NSString* publicVideoFolder = [self getPublicVideofolderPath];
        finalVideoURLString =
            [publicVideoFolder stringByAppendingPathComponent:tempString];
      } break;
      case VideoPathTypeCompressSD: {
        NSString* tempString =
            [NSString stringWithFormat:@"compressedVideoSD%@.mp4", nowTimeStr];
        NSString* publicVideoFolder = [self getPublicVideofolderPath];
        finalVideoURLString =
            [publicVideoFolder stringByAppendingPathComponent:tempString];
      } break;

      case VideoPathTypeMixMusic: {
        NSString* tempString =
            [NSString stringWithFormat:@"MixAudioMovie%@.mp4", nowTimeStr];
        NSString* editVideoFolder = [self getEditVideofolderPath];
        finalVideoURLString =
            [editVideoFolder stringByAppendingPathComponent:tempString];
      } break;
      case VideoPathTypeMixFilter: {
        NSString* tempString =
            [NSString stringWithFormat:@"MixFilterMovie%@.mp4", nowTimeStr];
        NSString* editVideoFolder = [self getEditVideofolderPath];
        finalVideoURLString =
            [editVideoFolder stringByAppendingPathComponent:tempString];
      } break;
    }

    // Url Should be a file Url, so here we check and convert it into a file Url
    if ([[NSURL URLWithString:finalVideoURLString] isFileURL] == 1) {
      return [NSURL URLWithString:finalVideoURLString];
    } else {
      return [NSURL fileURLWithPath:finalVideoURLString];
    }
  }
}

#pragma mark -
// 清除path文件夹下缓存
+ (BOOL)clearCacheWithFilePath:(NSString*)path {
  // 拿到path路径的下一级目录的子文件夹
  NSArray* subPathArr =
      [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];

  NSString* filePath = nil;

  NSError* error = nil;

  for (NSString* subPath in subPathArr) {
    filePath = [path stringByAppendingPathComponent:subPath];

    // 删除子文件夹
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error) {
      return NO;
    }
  }
  return YES;
}

+ (BOOL)clearTmpVideoCache {
  BOOL a = [self clearCacheWithFilePath:[self getEditVideofolderPath]];
  BOOL b = [self clearCacheWithFilePath:[self getPublicVideofolderPath]];
  BOOL c = [self clearCacheWithFilePath:[self getVideoCameraFolderPath]];
  if (a == YES && b == YES && c == YES) {
    ISLog(@"清理小视频缓存数据成功");
    return YES;
  }
  return NO;
}

@end
