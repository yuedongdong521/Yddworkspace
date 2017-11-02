//
//  AVPlayerViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/3/31.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "AVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation PlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end

@interface AVPlayerViewController ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) PlayerView *playerView;


@end

@implementation AVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initAVplayer];
    
    [self initUI];
}

- (void)initUI
{
    UIButton *playeButton = [self addButtonWithFrame:CGRectMake(ScreenWidth / 2 - 25, ScreenHeight - 60, 50, 50) Title:@"▶️" Image:nil Action:@selector(playeButtonAction:)];
    [self.view addSubview:playeButton];
    
    
}

- (void)playeButtonAction:(UIButton *)button
{
    if ([button.currentTitle isEqualToString:@"▶️"]) {
        [self.playerView.player play];
        [button setTitle:@"⏸" forState:UIControlStateNormal];
    } else {
        [self.playerView.player play];
        [button setTitle:@"▶️" forState:UIControlStateNormal];
    }
}

- (UIButton *)addButtonWithFrame:(CGRect)frame Title:(NSString *)title Image:(UIImage *)image Action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)initAVplayer
{
    self.playerView = [[PlayerView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playerView];
    
    // Do any additional setup after loading the view.
    /***
     status有三种状态：
     
     AVPlayerStatusUnknown,
     
     AVPlayerStatusReadyToPlay,
     
     AVPlayerStatusFailed
     
     当status等于AVPlayerStatusReadyToPlay时代表视频已经可以播放了，我们就可以调用play方法播放了。
     
     loadedTimeRange属性代表已经缓冲的进度，监听此属性可以在UI中更新缓冲进度，也是很有用的一个属性。
     ***/
    _playerItem = [[AVPlayerItem alloc] initWithURL:_playerUrl];
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];//监听status属性
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];//监听loadedTimeRanges属性
    _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    _playerView.player = _player;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];//用于监听视频是否已经播放完毕
}

// KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            
            CMTime duration = self.playerItem.duration;//获取视频总长度
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale; //转换成秒
            //转化成播放时间
            NSString *totalTime = [self convertTime:totalSecond];
            
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.playerView.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSString *)convertTime:(CGFloat)secend {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:secend];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (secend / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:date];
    return showtimeNew;
}

- (void)moviePlayDidEnd:(NSNotification *)notfiy
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
