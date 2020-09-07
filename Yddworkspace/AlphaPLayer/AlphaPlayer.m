//
//  AlphaPlayer.m
//  Yddworkspace
//
//  Created by ydd on 2020/3/24.
//  Copyright © 2020 QH. All rights reserved.
//

#import "AlphaPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "AlphaFrameFilter.h"
#import "UIImage+ydd.h"

@interface AlphaPlayer ()

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) NSString *videoUrl;

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImage *labelImage;

@property (nonatomic, copy) void(^playerCompleted)(BOOL finished);

@end

@implementation AlphaPlayer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _label.text = @"岳栋栋";
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor cyanColor];
        _label.backgroundColor = [UIColor clearColor];
    }
    return _label;
}

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        [self commonInit];
        self.videoUrl = url;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)startURL:(NSString *)videoPath completed:(void(^)(BOOL finished))completed
{
    self.videoUrl = videoPath;
    self.playerCompleted = completed;
    [self loadVideo];
}

- (void)commonInit
{
    self.playerLayer.pixelBufferAttributes = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    self.playerLayer.player = self.player;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
}

- (void)stopPlayer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player pause];
    self.player = nil;
    _playerItem = nil;
    
}

- (void)addVideoOutput
{
    if (!_videoOutput) {
        _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:nil];
    }
    
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    
    [self.player.currentItem addOutput:_videoOutput];
  
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkAction:(CADisplayLink *)display
{
    CMTime time = [_videoOutput itemTimeForHostTime:CACurrentMediaTime()];
    if ([_videoOutput hasNewPixelBufferForItemTime:time]) {
        CVPixelBufferRef buffer = [_videoOutput copyPixelBufferForItemTime:time itemTimeForDisplay:nil];
        [self addWaiterImage:buffer];
        CVPixelBufferRelease(buffer);
    }
}


- (CVPixelBufferRef)addWaiterImage:(CVPixelBufferRef)pixelBuffer {
  static CIImage* ciImage = nil;
  static CGRect imageRect;
  if (!ciImage) {
    UIImage* image = [UIImage imageNamed:@"0.jpg"];
    imageRect = CGRectMake(20, 20, image.size.width, image.size.height);
    ciImage = [[CIImage alloc] initWithImage:image];
  }
  static CIContext* ciContext = nil;
  if (ciContext == nil) {
    EAGLContext* eaglContext =
        [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    ciContext = [CIContext contextWithEAGLContext:eaglContext options:nil];
  }

  [ciContext render:ciImage
      toCVPixelBuffer:pixelBuffer
               bounds:imageRect
           colorSpace:nil];

  return pixelBuffer;
}



- (void)playerCompleted:(BOOL)completed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.playerCompleted) {
            self.playerCompleted(completed);
        }
    });
}

- (void)loadVideo
{
    if (!_videoUrl) {
        [self playerCompleted:NO];
        return;
    }
    self.asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.videoUrl]];
    if (!self.asset) {
        [self playerCompleted:NO];
        return;
    }
    __weak typeof(self) weakself = self;
    __weak typeof(self.asset) weakAsse = self.asset;
    [self.asset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
        __strong typeof(weakself) strongself = weakself;
        __strong typeof(weakAsse) strongAsse = weakAsse;
        if (!strongself || !strongself.asset ) {
            [self playerCompleted:NO];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            strongself.playerItem = [AVPlayerItem playerItemWithAsset:strongAsse];
            [strongself.player play];
        });
    }];
    
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    [self.player pause];
    _playerItem = playerItem;
    [self.player seekToTime:kCMTimeZero];
    [self setupPlayerItem];
    [self setupLooping];
    [self.player replaceCurrentItemWithPlayerItem:_playerItem];
//    [self addVideoOutput];
}

- (void)setupLooping
{
    if (!self.playerItem || !self.player) {
        return;
    }
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [self addObserver:self.playerItem forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusFailed) {
            [self playerCompleted:NO];
        }
    }
}

- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)notify
{
//    __weak typeof(self.player) weakplayer = self.player;
//    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
//        __strong typeof(weakplayer) strongplayer = weakplayer;
//        [strongplayer play];
//    }];
    [self playerCompleted:YES];
    
}

- (void)applicationDidBecomeActive:(NSNotification *)notify
{
    if (self.playerLayer) {
//
        if (self.backgroundPlay) {
            [self.player play];
        } else {
            self.playerLayer.player = self.player;
        }
        
    }
}

- (void)applicationWillResignActive:(NSNotification *)notify
{
    if (self.playerLayer) {
//
        if (self.backgroundPlay) {
            [self.player pause];
        } else {
            self.playerLayer.player = nil;
        }
    }
}

- (void)setupPlayerItem
{
    if (!self.playerItem) {
        [self playerCompleted:NO];
        return;
    }
    NSArray <AVAssetTrack *> * tracks = self.playerItem.asset.tracks;
    if (!tracks || tracks.count == 0) {
        [self playerCompleted:NO];
        return;
    }
    CGSize videoSize = CGSizeMake(tracks.firstObject.naturalSize.width * 0.5, tracks.firstObject.naturalSize.height);
    if (videoSize.width <= 0 || videoSize.height <= 0) {
        [self playerCompleted:NO];
        return;
    }
    
    CGRect sourceRect = CGRectMake(0, 0, videoSize.width, videoSize.height);
    CGRect alphaRect = CGRectOffset(sourceRect, sourceRect.size.width, 0);
    AlphaFrameFilter *filter = [[AlphaFrameFilter alloc] init];
    
    AVMutableVideoComposition *composition = [AVMutableVideoComposition videoCompositionWithAsset:self.playerItem.asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
    
//        NSLog(@"compositionTime = %f", CMTimeGetSeconds(request.compositionTime));
        
         
        CIImage *inputImage = [request.sourceImage imageByCroppingToRect:alphaRect];
        filter.inputImage = [inputImage imageByApplyingTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, -sourceRect.size.width, 0)];
        filter.maskImage = [request.sourceImage imageByCroppingToRect:sourceRect];
        
        CIImage *outputImage = filter.outputImage;
        
//        CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
//        [scaleFilter setValue:filter.outputImage forKey:@"inputImage"];
//        [scaleFilter setValue:@(0.5) forKey:@"inputScale"];
        
        /*
        CGFloat curTime = CMTimeGetSeconds(request.compositionTime);
        if (curTime > 1 && curTime <= 4) {
            UIImage *image = self.labelImage;//[self coverImageWithView:self.label];//[UIImage imageNamed:@"0.jpg"];
            CIImage *nputImage = [[CIImage alloc] initWithImage:image];
            
            
            CIFilter *filter1 = [CIFilter filterWithName:@"CIAffineTransform"];
            NSLog(@"CILanczosScaleTransform keys : %@", filter1.inputKeys);
            [filter1 setValue:nputImage forKey:@"inputImage"];
            CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, image.size.width * 0.5, 0);//CGAffineTransformMake(0.5, 0, 0, 0.5, (videoSize.width - image.size.width) * 0.5, (videoSize.height - image.size.height) * 0.5);
//            [filter1 setValue:[NSValue valueWithCGAffineTransform:transform] forKey:@"inputTransform"];
            
            
            CIFilter *filter2 = [CIFilter filterWithName:@"CISourceOverCompositing"];
            NSLog(@"CISourceOverCompositing keys : %@", filter2.inputKeys);
            [filter2 setValue:filter1.outputImage forKey:@"inputImage"]; //setValue(filter.outputImage, forKey: "inputImage")
            
            [filter2  setValue:filter.outputImage forKey:@"inputBackgroundImage"];
            outputImage = filter2.outputImage;
        }
*/
        [request finishWithImage:outputImage context:nil];
    
    }];
//    [self addText:@"123456" rect:CGRectMake(20, videoSize.height - 100, videoSize.width - 40, 100) videoRect:CGRectMake(0, 0, videoSize.width, videoSize.height) videoCamposition:composition];
    composition.renderSize = videoSize;
    self.playerItem.videoComposition = composition;
    self.playerItem.seekingWaitsForVideoCompositionRendering = YES;
    
}

- (UIImage *)coverImageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
    [view drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl = videoUrl;
    [self loadVideo];
}


- (AVPlayerLayer *)playerLayer
{
    
    return (AVPlayerLayer *)self.layer;
}

- (AVPlayer *)player
{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    
    return _player;
}

- (void)dealloc
{
    _playerItem = nil;
}


- (void)addVideoLayerFrame:(CGRect)frame
          VideoCamposition:(AVMutableVideoComposition*)videoComposition {
  CALayer* backgroundLayer = [CALayer layer];
  UIImage* image = [UIImage imageNamed:@"iSpeakWatermark"];
  backgroundLayer.contents = (__bridge id _Nullable)image.CGImage;
  backgroundLayer.frame = CGRectMake(
      frame.size.width - (120 + 10),
      frame.size.height - 10 - (image.size.height / image.size.width * 120),
      120, image.size.height / image.size.width * 120);
  backgroundLayer.masksToBounds = YES;

  CALayer* videoLayer = [CALayer layer];
  videoLayer.frame = frame;

  CALayer* parentLayer = [CALayer layer];
  parentLayer.frame = frame;
  [parentLayer addSublayer:videoLayer];
  [parentLayer addSublayer:backgroundLayer];

  videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                                              inLayer:
                                                                  parentLayer];
}

- (void)addText:(NSString *)text rect:(CGRect)rect videoRect:(CGRect)videoRect  videoCamposition:(AVMutableVideoComposition*)videoComposition
{
    // 1 - 这个layer就是用来显示水印的。
    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
    [subtitle1Text setFont:@"Helvetica-Bold"];
    [subtitle1Text setFontSize:36];
    [subtitle1Text setFrame:rect];
    [subtitle1Text setString:text];
    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
    [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subtitle1Text];
    overlayLayer.frame = videoRect;
    [overlayLayer setMasksToBounds:YES];
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = videoRect;
    videoLayer.frame = videoRect;
    // 这里看出区别了吧，我们把overlayLayer放在了videolayer的上面，所以水印总是显示在视频之上的。
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

- (void)addAnimationIndex:(NSInteger)index
                     rect:(CGRect)rect
                videoRect:(CGRect)videoRect
         videoCamposition:(AVMutableVideoComposition*)videoComposition
{
    // 1
    UIImage *animationImage = [UIImage imageNamed:@"star.png"];;
    CALayer *overlayLayer1 = [CALayer layer];
    [overlayLayer1 setContents:(id)[animationImage CGImage]];
    overlayLayer1.frame = rect;
    [overlayLayer1 setMasksToBounds:YES];
    CALayer *overlayLayer2 = [CALayer layer];
    [overlayLayer2 setContents:(id)[animationImage CGImage]];
    overlayLayer2.frame = rect;
    [overlayLayer2 setMasksToBounds:YES];
    // 2 - Rotate
    if (index == 0) {
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.duration=2.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // rotate from 0 to 360
        animation.fromValue=[NSNumber numberWithFloat:0.0];
        animation.toValue=[NSNumber numberWithFloat:(2.0 * M_PI)];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer1 addAnimation:animation forKey:@"rotation"];
        animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.duration=2.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // rotate from 0 to 360
        animation.fromValue=[NSNumber numberWithFloat:0.0];
        animation.toValue=[NSNumber numberWithFloat:(2.0 * M_PI)];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer2 addAnimation:animation forKey:@"rotation"];
        // 3 - Fade
    } else if(index == 1) {
        CABasicAnimation *animation
        =[CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration=3.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // animate from fully visible to invisible
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:0.0];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer1 addAnimation:animation forKey:@"animateOpacity"];
        animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration=3.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // animate from invisible to fully visible
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:0.0];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer2 addAnimation:animation forKey:@"animateOpacity"];
        // 4 - Twinkle
    } else if(index == 2) {
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration=0.5;
        animation.repeatCount=10;
        animation.autoreverses=YES;
        // animate from half size to full size
        animation.fromValue=[NSNumber numberWithFloat:0.5];
        animation.toValue=[NSNumber numberWithFloat:1.0];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer1 addAnimation:animation forKey:@"scale"];
        animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration=1.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // animate from half size to full size
        animation.fromValue=[NSNumber numberWithFloat:0.5];
        animation.toValue=[NSNumber numberWithFloat:1.0];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer2 addAnimation:animation forKey:@"scale"];
    }
    // 5
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = videoRect;
    videoLayer.frame = videoRect;
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer1];
    [parentLayer addSublayer:overlayLayer2];
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}

- (void)setTimeRange:(CMTimeRange)timeRange
          videoTrack:(AVAssetTrack *)track
    VideoCamposition:(AVMutableVideoComposition*)videoComposition
{
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.timeRange = timeRange;
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
}




@end
