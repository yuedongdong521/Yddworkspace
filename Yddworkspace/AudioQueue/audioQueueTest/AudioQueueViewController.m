//
//  AudioQueueViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/11/30.
//  Copyright © 2018 QH. All rights reserved.
//

#import "AudioQueueViewController.h"
#import "Play.h"
#import "Record.h"
@interface AudioQueueViewController ()

@property (nonatomic, strong) Play *player;
@property (nonatomic, strong) Record *recorder;

@end

@implementation AudioQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  NSArray *arr = @[@"录制", @"播放", @"录制完成"];
  
  for (int i = 0; i < arr.count; i++) {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 100 + i * 80, 100, 60);
    [btn setTitle:arr[i] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor grayColor];
    btn.tag = i;
    [self.view addSubview:btn];
  }
  [self recorder];
  
}

- (void)btnAction:(UIButton *)btn
{
  btn.selected = !btn.selected;
  switch (btn.tag) {
    case 0:
      [self recoder:btn];
      break;
    case 1:
      [self play];
      break;
    case 2:
      [self recoderFinish];
      break;
      
    default:
      break;
  }
}

- (void)recoder:(UIButton *)btn
{
  if (btn.selected) {
    [self.recorder start];
  } else {
    [self.recorder pause];
  }
}

- (void)play
{
  
}

- (void)recoderFinish
{
  [self.recorder stop];
}
- (void)player:(UIButton *)btn
{
  [self.player Play:[self.recorder getBytes] Length:self.recorder.audioDataLength];
}

- (void)complete
{
  
}

- (Record *)recorder
{
  if (!_recorder) {
    _recorder = [[Record alloc] init];
    __weak typeof(self) weakself = self;
    _recorder.processAudioBuffer = ^(Byte * _Nonnull audioData, long lenght) {
      [weakself.player Play:audioData Length:lenght];
    };
  }
  return _recorder;
}

- (Play *)player{
  if (!_player) {
    _player = [[Play alloc] init];
    
  }
  return _player;
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
