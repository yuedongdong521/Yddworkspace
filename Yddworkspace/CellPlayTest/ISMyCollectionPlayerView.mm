//
//  ISMyCollectionPlayerView.m
//  iShow
//
//  Created by ispeak on 2017/12/19.
//

#import "ISMyCollectionPlayerView.h"


@interface ISMyCollectionPlayerView ()

@property(nonatomic, strong) UIImageView* bgImageView;
@property(nonatomic, strong) AVPlayerLayer* playerLayer;
@property(nonatomic, assign) CGRect originFrame;
@property(nonatomic, strong) NSURL* videoURL;

@end

@implementation ISMyCollectionPlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame WithURL:(NSURL*)url {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor blackColor];
    _originFrame = frame;
    [self initPlayerWithURL:url];
    [self addObserver];
  }
  return self;
}

- (void)initPlayerWithURL:(NSURL*)url {
  _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
  _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
  [self addSubview:_bgImageView];

  _videoURL = url;
  AVAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
  AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:asset];
  AVPlayer* player = [AVPlayer playerWithPlayerItem:playerItem];
  AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
  playerLayer.frame = _bgImageView.bounds;
  playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
  playerLayer.contentsScale = [UIScreen mainScreen].scale;
  playerLayer.backgroundColor = [UIColor clearColor].CGColor;
  [_bgImageView.layer addSublayer:playerLayer];
  player.volume = 1.0;
  _playerLayer = playerLayer;
  _player = player;
}

- (void)setBGImageViewImageURL:(NSURL*)imageURL {
    _bgImageView.image = [UIImage imageNamed:@"squareDefaultIcon@2x"];
  CGFloat bgRate = 0.0;
  if (_bgImageView.image && _bgImageView.image.size.height &&
      _bgImageView.image.size.width > 0) {
    bgRate = _bgImageView.image.size.width / _bgImageView.image.size.height;
    [self layoutUIWithSize:_bgImageView.image.size];
    if ([_delegate respondsToSelector:@selector(reloadItemSizeRate:)]) {
      [_delegate reloadItemSizeRate:bgRate];
    }
  }
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [self thumbnailImageForVideo:_videoURL atTime:1];
        if (image) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (image.size.height > 0) {
              self.bgImageView.image = image;
              CGFloat imageRate = image.size.width / image.size.height;
              if (imageRate != 0 && imageRate != bgRate) {
                [self layoutUIWithSize:_bgImageView.image.size];
                if ([_delegate
                        respondsToSelector:@selector(reloadItemSizeRate:)]) {
                  [_delegate reloadItemSizeRate:imageRate];
                }
              }
            }
          });
        }
      });
}

- (void)layoutUIWithSize:(CGSize)size {
  CGFloat rate = size.width / size.height;
  CGFloat height = self.frame.size.width / rate;
  _originFrame.size.height = height;
  //    if (rate > 1) {
  //        CGFloat height = self.frame.size.width / rate;
  //        _originFrame.size.height = height;
  //    } else {
  //        CGFloat width = self.frame.size.height * rate;
  //        _originFrame.size.width = width;
  //    }
  [self resetOriginFrame];
}

- (void)animateIsStart:(BOOL)isStart {
  if (isStart) {
    _playerLayer.hidden = YES;
  } else {
    _playerLayer.hidden = NO;
  }
}

- (void)resetOriginFrame {
  [self resetFrame:_originFrame];
}

- (void)resetFrame:(CGRect)frame {
  self.frame = frame;
  _bgImageView.frame = self.bounds;
  _playerLayer.frame = _bgImageView.bounds;
}

- (void)addObserver {
  //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
  [_player.currentItem
      addObserver:self
       forKeyPath:@"status"
          options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
          context:nil];

  //监控播放完成通知
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(playbackFinished)
             name:AVPlayerItemDidPlayToEndTimeNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(appWillEnterBackground)
             name:UIApplicationWillEnterForegroundNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(appDidBecomeActive)
             name:UIApplicationDidBecomeActiveNotification
           object:nil];
}

- (void)appWillEnterBackground {
  if (_player) {
    [_player pause];
  }
}

- (void)appDidBecomeActive {
  if (_player) {
    [_player play];
  }
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id>*)change
                       context:(void*)context {
  AVPlayerItem* playerItem = (AVPlayerItem*)object;
  if ([keyPath isEqualToString:@"status"]) {
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
      NSLog(@"playerItem is ready");
      [_player play];
    } else {
      NSLog(@"视频加载出错");
   
    }
    NSLog(@"播放状态：%ld", (long)playerItem.status);
  }
}

- (void)playbackFinished {
  if (_player) {
    [_player.currentItem seekToTime:kCMTimeZero];
    [_player play];
  }
}

- (UIImage*)thumbnailImageForVideo:(NSURL*)videoURL
                            atTime:(NSTimeInterval)time {
  AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
  NSParameterAssert(asset);
  AVAssetImageGenerator* assetImageGenerator =
      [[AVAssetImageGenerator alloc] initWithAsset:asset];
  assetImageGenerator.appliesPreferredTrackTransform = YES;
  assetImageGenerator.apertureMode =
      AVAssetImageGeneratorApertureModeEncodedPixels;

  CGImageRef thumbnailImageRef = NULL;
  CFTimeInterval thumbnailImageTime = time;
  NSError* thumbnailImageGenerationError = nil;
  thumbnailImageRef =
      [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                                  actualTime:NULL
                                       error:&thumbnailImageGenerationError];

  if (!thumbnailImageRef)
    NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);

  UIImage* thumbnailImage =
      thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
                        : nil;

  return thumbnailImage;
}

- (void)removeObserver {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_player.currentItem removeObserver:self forKeyPath:@"status"];
}

- (void)dealloc {
  NSLog(@"ISMyCollectionPlayerView 释放了");
}

@end
