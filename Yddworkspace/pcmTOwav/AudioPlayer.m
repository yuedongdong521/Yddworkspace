//
//  AudioPlayer.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/10.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "AudioPlayer.h"

@interface AudioPlayer ()

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AudioPlayer

- (instancetype)initAudioPlayerWithAudioPath:(NSURL *)audioURL
{
    self = [super init];
    if (self) {
        [self initAudioSession];
        [self creatAudioPlayerAudioURL:audioURL];
    }
    return self;
}


- (void)initAudioSession
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [session setActive:YES error:nil];
}

- (void)creatAudioPlayerAudioURL:(NSURL *)audioURL
{
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    player.volume = 1.0;
    player.numberOfLoops = -1;
    player.enableRate = YES;
    player.rate = 1.0;
    _player = player;
    
    _player.meteringEnabled = YES;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(upDatePlayerVolume) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)invalidate
{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}
- (void)upDatePlayerVolume
{
    [_player updateMeters];
    
    CGFloat currentVolume = [_player averagePowerForChannel:0];
    NSLog(@"currentVolume = %f", currentVolume);
}


- (void)startPlay
{
    if ([_player prepareToPlay]) {
        BOOL isPlaying = [_player play];
        if (isPlaying) {
            [self timer];
        }
    }
}

- (void)stopPlay
{
    [self invalidate];
    [_player stop];
}

- (NSString *)currentPath
{
    return _player.url.absoluteString;
}

@end
