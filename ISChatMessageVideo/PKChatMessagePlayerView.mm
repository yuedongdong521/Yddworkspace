//
//  PKChatMessagePlayerView.m
//  GPUCameraTest
//
//  Created by ispeak on 2017/12/28.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import "PKChatMessagePlayerView.h"
// #import <GPUImage/GPUImageMovie.h>
// #import <GPUImage/GPUImageView.h>
#import "ISListVideoPlayer.h"

@interface PKChatMessagePlayerView ()  // <GPUImageMovieDelegate>
{
  //    GPUImageMovie *_moviePlayer;
}

@property(nonatomic, strong) UIImageView* imageView;

@property(nonatomic, strong) NSString* videoPath;
@property(nonatomic, assign) NSInteger videoId;

@end

@implementation PKChatMessagePlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
                    videoPath:(NSString*)videoPath
                      videoId:(NSInteger)videoId {
  self = [super initWithFrame:frame];
  if (self) {
    //        GPUImageView *filterView = [[GPUImageView alloc]
    //        initWithFrame:self.bounds];
    //        [self addSubview:filterView];
    //        _moviePlayer = [[GPUImageMovie alloc] initWithURL:[NSURL
    //        fileURLWithPath:videoPath]];
    //        _moviePlayer.shouldRepeat = YES;  // 重复播放
    //        _moviePlayer.runBenchmark = NO;  // 打印播放日志
    //        _moviePlayer.playAtActualSpeed = YES;  // 是否正常速度播放
    //        [_moviePlayer addTarget:filterView];

    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.backgroundColor = [UIColor blackColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;

    [self addSubview:_imageView];

    _isPlaying = NO;
    _videoPath = videoPath;
    _videoId = videoId;
  }
  return self;
}

- (void)play {
  if (_isPlaying) {
    return;
  } else {
    _isPlaying = YES;
  }
  __weak typeof(self) weakself = self;
  [[ISListVideoPlayer sharedPlayer]
       startPlayVideo:_videoPath
              VideoId:_videoId
      withVideoDecode:^(CGImageRef videoImageRef, NSString* videoFilePath) {
        weakself.imageView.layer.contents =
            (__bridge id _Nullable)(videoImageRef);
      }];

  [[ISListVideoPlayer sharedPlayer]
      reloadVideoPlay:^(NSString* videoFilePath) {
        if (weakself.isPlaying) {
          weakself.isPlaying = NO;
          [weakself play];
        }
      }
         withFilePath:_videoPath
          withVideoId:_videoId];
}

- (void)stop {
  _isPlaying = NO;
  [[ISListVideoPlayer sharedPlayer]
      cancelVideo:[NSString stringWithFormat:@"%ld", (long)_videoId]];
}

- (void)didCompletePlayingMovie {
}

- (void)viewDidLayoutSubviews {
  ISLog(@"MoivePlayerView layout");
}

- (void)dealloc {
  ISLog(@"MoivePlayerView dealloc");
}

@end
