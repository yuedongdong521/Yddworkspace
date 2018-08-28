//
//  ISListVideoPlayer.m
//  iShow
//
//  Created by ispeak on 2018/1/5.
//

#import "ISListVideoPlayer.h"

@implementation ISListVideoPlayer

static ISListVideoPlayer* _instance;
+ (instancetype)sharedPlayer {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];

    // 初始化一个视频操作缓存字典
    _instance.videoOperationDict = [NSMutableDictionary dictionary];
    // 初始化一个视频播放操作队列
    _instance.videoOperationQueue = [[NSOperationQueue alloc] init];
    _instance.videoOperationQueue.maxConcurrentOperationCount = 10;
  });
  return _instance;
}

- (void)startPlayVideo:(NSString*)filePath
               VideoId:(NSInteger)videoId
       withVideoDecode:(VideoDecode)videoDecode {
  [self checkVideoPath:filePath VideoId:videoId withBlock:videoDecode];
}

- (ISListVideoOperation*)checkVideoPath:(NSString*)filePath
                                VideoId:(NSInteger)videoId
                              withBlock:(VideoDecode)videoBlock {
  // 视频播放操作Operation队列，就初始化队列，
  if (!self.videoOperationQueue) {
    self.videoOperationQueue = [[NSOperationQueue alloc] init];
    self.videoOperationQueue.maxConcurrentOperationCount = 1000;
  }
  // 视频播放操作Operation存放字典，初始化视频操作缓存字典
  if (!self.videoOperationDict) {
    self.videoOperationDict = [NSMutableDictionary dictionary];
  }
  // 视频在cell上的index位置作为key
  NSString* videoKey = [NSString stringWithFormat:@"%ld", (long)videoId];
  // 初始化了一个自定义的NSBlockOperation对象，它是用一个Block来封装需要执行的操作
  ISListVideoOperation* videoOperation;

  // 如果这个视频已经在播放，就先取消它，再次进行播放
  [self cancelVideo:videoKey];

  videoOperation = [[ISListVideoOperation alloc] init];
  __weak ISListVideoOperation* weakVideoOperation = videoOperation;
  videoOperation.videoDecodeBlock = videoBlock;
  // 并发执行一个视频操作任务
  [videoOperation addExecutionBlock:^{
    [weakVideoOperation videoPlayTask:filePath];
  }];
  // 执行完毕后停止操作
  [videoOperation setCompletionBlock:^{
    // 从视频操作字典里面异常这个Operation
    [self.videoOperationDict removeObjectForKey:videoKey];
    // 属性停止回调
    if (weakVideoOperation.videoStopBlock) {
      weakVideoOperation.videoStopBlock(filePath);
    }
  }];
  NSArray* dicValueArr = @[ filePath, videoOperation ];
  // 将这个Operation操作加入到视频操作字典内
  [self.videoOperationDict setObject:dicValueArr forKey:videoKey];
  // add之后就执行操作
  [self.videoOperationQueue addOperation:videoOperation];

  return videoOperation;
}

- (void)reloadVideoPlay:(VideoStop)videoStop
           withFilePath:(NSString*)filePath
            withVideoId:(NSInteger)videoId {
  NSString* dicVideoKey = [NSString stringWithFormat:@"%ld", (long)videoId];
  ISListVideoOperation* videoOperation;
  if (self.videoOperationDict[dicVideoKey] &&
      [self.videoOperationDict[dicVideoKey] isKindOfClass:[NSArray class]]) {
    NSArray* videoArr = self.videoOperationDict[dicVideoKey];
    if (videoArr.count == 2) {
      videoOperation = videoArr[1];
      videoOperation.videoStopBlock = videoStop;
    }
  }
}

- (void)cancelVideo:(NSString*)videoKey {
  ISListVideoOperation* videoOperation;
  // 如果所有视频操作字典内存在这个视频操作，取出这个操作
  if (self.videoOperationDict[videoKey] &&
      [self.videoOperationDict[videoKey] isKindOfClass:[NSArray class]]) {
    NSArray* videoArr = self.videoOperationDict[videoKey];
    if (videoArr.count < 2) {
      return;
    }
    videoOperation = videoArr[1];
    // 如果这个操作已经是取消状态，就返回。
    if (videoOperation.isCancelled) {
      return;
    }
    // 操作完不做任何事
    [videoOperation setCompletionBlock:nil];

    videoOperation.videoStopBlock = nil;
    videoOperation.videoDecodeBlock = nil;
    // 取消这个操作
    [videoOperation cancel];
    if (videoOperation.isCancelled) {
      // 从视频操作字典里面异常这个Operation
      [self.videoOperationDict removeObjectForKey:videoKey];
    }
  }
}

- (void)cancelAllVideo {
  if (self.videoOperationQueue) {
    // 根据视频地址这个key来取消所有Operation
    NSMutableDictionary* tempDict =
        [NSMutableDictionary dictionaryWithDictionary:self.videoOperationDict];
    for (NSString* key in tempDict) {
      [self cancelVideo:key];
    }
    [self.videoOperationDict removeAllObjects];
    [self.videoOperationQueue cancelAllOperations];
  }
}

@end
