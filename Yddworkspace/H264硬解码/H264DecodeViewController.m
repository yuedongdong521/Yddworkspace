//
//  H264DecodeViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/9/6.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "H264DecodeViewController.h"
#import "ISH264PlayerView.h"
#import "ISH246TVDecode.h"

@interface H264DecodeViewController ()<ISH264TVDecodeDelegate>

@property(nonatomic, strong) ISH264PlayerView *player;

@property(nonatomic, strong) ISH246TVDecode *h264Decode;

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) NSInteger currentLength;
@property(nonatomic, strong) NSData *h264Data;

@end

@implementation H264DecodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  _player = [[ISH264PlayerView alloc] initWithFrame:CGRectMake(0, 80, ScreenWidth, ScreenWidth / 4 * 3)];
  
  [self.view addSubview:_player];
  
  [_player hiddenLoadingView];
  
  _h264Decode = [[ISH246TVDecode alloc] init];
  [_h264Decode open:self width:ScreenWidth height:ScreenWidth / 4 * 3];
  
  
  UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
  startBtn.frame = CGRectMake(40, ScreenHeight - 100, 100, 50);
  [startBtn setTitle:@"start" forState:UIControlStateNormal];
  [startBtn setTitle:@"stop" forState:UIControlStateSelected];
  [startBtn addTarget:self action:@selector(startPlay:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:startBtn];
  
  _h264Data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ispeak" ofType:@"h264"]];
}

- (void)startPlay:(UIButton *)btn
{
  if (!_h264Data) {
    NSLog(@"没有播放源");
    return;
  }
  
  btn.selected = !btn.selected;
  if (btn.selected) {
    [self startTimer];
  } else {
    [self stopTimer];
  }
}

- (void)startTimer
{
  _currentLength = 0;
  [self stopTimer];
  _timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
  [_timer fire];
  [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
  if (_timer) {
    if ([_timer isValid]) {
      [_timer invalidate];
    }
    _timer = nil;
  }
}


- (void)timeAction
{
  [self stopTimer];
  static const NSInteger lenght = 1024 * 10;
   NSInteger maxLenght = _h264Data.length;
  NSRange range;
  if (_currentLength >= maxLenght) {
    _currentLength = 0;
    
    range = NSMakeRange(_currentLength, lenght);
  } else if (_currentLength + lenght > maxLenght) {
    range = NSMakeRange(_currentLength, maxLenght - _currentLength);
  } else {
    range = NSMakeRange(_currentLength, lenght);
  }
  NSData *curData = [_h264Data subdataWithRange:range];
  
  [_h264Data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
    NSLog(@"byteRange = %@, stop = %d", NSStringFromRange(byteRange), *stop);
    [_h264Decode decodeNalu:(uint8_t *)bytes withSize:(uint32_t)byteRange.length];
    *stop = YES;
  }];
  
  
//  [_h264Decode decodeNalu:curData withSize:range.length];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
  [self stopTimer];
}

-(void)displayDecode:(ISH246TVDecode *)decode ImageBuffer:(CVPixelBufferRef)buffer
{
  if (buffer) {
    [self.player playForPixelBuffer:buffer];
  }
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
