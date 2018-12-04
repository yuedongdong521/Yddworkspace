//
//  PCMTOWAVViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/10.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "PCMTOWAVViewController.h"
#import "AudioRecorder.h"
#import "YDDpcmTOwav.h"
#import "AudioPlayer.h"

@interface PCMTOWAVViewController ()<AudioRecorderDelegate>

@property (nonatomic, strong) AudioPlayer *player;

@property (nonatomic, strong) NSString *playPath;

@end

@implementation PCMTOWAVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = 100;
    button.frame = CGRectMake(20, 100, 100, 50);
    [button setTitle:@"录制" forState:UIControlStateNormal];
    [button setTitle:@"停止" forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [AudioRecorder shareAudioRecorder].delegate = self;
    
    
    UIButton *playbtn = [UIButton buttonWithType:UIButtonTypeSystem];
    playbtn.tag = 200;
    playbtn.frame = CGRectMake(20, 200, 100, 50);
    [playbtn setTitle:@"播放" forState:UIControlStateNormal];
    [playbtn setTitle:@"停止" forState:UIControlStateSelected];
    [playbtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playbtn];
    
    
}

- (void)buttonAction:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.tag == 100) {
        if (button.selected) {
            [[AudioRecorder shareAudioRecorder] startRecord];
        } else {
            [[AudioRecorder shareAudioRecorder] stopRecord];
        }
    } else if (button.tag == 200) {
        if (button.selected) {
            [self playerWithPath:_playPath];
        } else {
            [self stopPlayer];
        }
    }
}

- (void)recordFinishAudioPath:(NSString *)path
{
    NSString *wavPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *name = [NSString stringWithFormat:@"%f", [[NSDate date]timeIntervalSince1970]];
    wavPath = [wavPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",name]];
    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
//        [[NSFileManager defaultManager] createFileAtPath:wavPath contents:nil attributes:nil];
//    }
    YDDpcmTOwav *ydd = [[YDDpcmTOwav alloc] init];
    int code = [ydd convertPcmToWavWithPCMPath:path WAVPath:wavPath Channels:2 Sample_rate:16000];
    NSLog(@"转码 code = %d", code);
    
    if (code == 0) {
        _playPath = wavPath;
    }
    
}

- (void)playerWithPath:(NSString *)path
{
  if (!path) {
    return;
  }
    if (!_player) {
        _player = [[AudioPlayer alloc] initAudioPlayerWithAudioPath:[NSURL fileURLWithPath:path]];
    } else {
        if (![_player.currentPath isEqualToString:path]) {
            [_player stopPlay];
            _player = nil;
            _player = [[AudioPlayer alloc] initAudioPlayerWithAudioPath:[NSURL fileURLWithPath:path]];
        }
    }
    [_player startPlay];
}

- (void)stopPlayer
{
    [_player stopPlay];
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
