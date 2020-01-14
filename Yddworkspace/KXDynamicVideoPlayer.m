//
//  KXDynamicVideoPlayer.m
//  KXLive
//
//  Created by ydd on 2020/1/4.
//  Copyright © 2020 ibobei. All rights reserved.
//

#import "KXDynamicVideoPlayer.h"
//#import "KXVideoPlayerView.h"

@interface KXDynamicVideoPlayer ()

@property (nonatomic, strong) UIView *playerView;

@property (nonatomic, copy) void(^dismissBlock)(void);

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) CGPoint startCenter;
@property (nonatomic, assign) BOOL startPan;
@property (nonatomic, assign) CGPoint startPoint;

@end


@implementation KXDynamicVideoPlayer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void)showPlayerWithVideoURl:(NSString *)videoURl
                     startTime:(CGFloat)startTime
                         image:(nonnull UIImage *)image
                  dismissBlock:(void(^)(void))dismissBlock
{
    KXDynamicVideoPlayer *playerView = [[KXDynamicVideoPlayer alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[UIApplication sharedApplication].keyWindow addSubview:playerView];
    playerView.bgImageView.image = image;
    [playerView playerURL:videoURl startTime:startTime];
    playerView.dismissBlock = dismissBlock;
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgView];
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.bgImageView];
        [self.contentView addSubview:self.playerView];
        self.contentView.frame = self.bounds;
        self.bgImageView.frame = self.bounds;
        self.playerView.frame = self.bounds;
        self.bgView.frame = self.bounds;
    }
    return self;
}

- (void)playerURL:(NSString *)url startTime:(CGFloat)startTime
{
    if (startTime > 1) {
        startTime -= 1;
    } else {
        startTime = 0;
    }
//    [_playerView.player setStartTime:startTime];
//    [_playerView playerURLStr:url];
}
/*
- (KXVideoPlayerView *)playerView
{
    if (!_playerView) {
        _playerView = [[KXVideoPlayerView alloc] init];
        _playerView.player.loop = NO;
        [_playerView addVideoControl];
        @weakify(self);
        _playerView.closeBlock = ^{
            @strongify(self);
            [self closePreVideo];
        };
    }
    return _playerView;
}
 */

- (UIView *)playerView
{
    if (!_playerView) {
        _playerView = [[UIView alloc] init];
    }
    return _playerView;
}

- (void)dismiss
{
//    [_playerView destroy];
    [self closePreVideo];
}

- (void)closePreVideo
{
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    [self removeFromSuperview];
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor blackColor];
    }
    return _bgView;
}

- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bgImageView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_contentView addGestureRecognizer:pan];
        
    }
    return _contentView;
}

- (void)panAction:(UIPanGestureRecognizer *)pan
{
     CGPoint p = [pan locationInView:self];
       
       switch (pan.state) {
           case UIGestureRecognizerStateBegan: {
               self.startPoint = p;
               self.startCenter = self.contentView.center;
               self.startPan = NO;
           } break;
           case UIGestureRecognizerStateChanged: {
               if (self.startPan) {
                   CGFloat deltaY = fabs(p.y - self.startPoint.y);
                   
                   CGFloat alpha = 1 - (MIN(deltaY, 100)) / 100.0;
                   alpha = alpha < 0.3 ? 0.3 : alpha;
                   CGFloat scale =  (ScreenHeight - deltaY) / ScreenHeight;
                   
                   self.contentView.center = p;
                   self.bgView.alpha = alpha;
                   self.contentView.transform = CGAffineTransformMakeScale(scale, scale);
                   
               } else {
                   CGRect startFrame = self.contentView.frame;
                   CGFloat anchorX = p.x / startFrame.size.width;
                   CGFloat anchorY = p.y / startFrame.size.height;
                   self.contentView.layer.anchorPoint = CGPointMake(anchorX, anchorY);
                   self.contentView.center = p;
                   self.startPoint = p;
                   self.startPan = YES;
               }
           } break;
           case UIGestureRecognizerStateEnded: {
               if (self.startPoint.x == 0 && self.startPoint.y == 0) return;
               // 手指移动速度, fasb(v.y) > fabs(v.x)竖直方向移动,反之水方向移动
               CGPoint v = [pan velocityInView:self];
               CGFloat deltaY = p.y - self.startPoint.y;
               
               if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                   [self dismiss];
                   
               } else {
                   self.bgView.alpha = 1;
                   self.contentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                   self.contentView.center = self.startCenter;
                    self.contentView.transform = CGAffineTransformIdentity;
               }
               self.startPan = NO;
           } break;
           case UIGestureRecognizerStateCancelled : {
               self.bgView.alpha = 1;
               self.contentView.layer.anchorPoint = CGPointMake(0.5, 0.5);
               self.contentView.center = self.startCenter;
               self.contentView.transform = CGAffineTransformIdentity;
               self.startPan = NO;
           }
           default:
               break;
       }
}

- (void)setStartPan:(BOOL)startPan
{
    _startPan = startPan;
//    [self.playerView hidVideoControl:startPan];
}



@end
