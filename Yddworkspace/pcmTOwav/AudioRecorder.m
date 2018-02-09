//
//  AudioRecorder.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/10.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "AudioRecorder.h"

@interface AudioRecorder ()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSString *pcmPath;
@property (nonatomic, strong) NSTimer *timer;

@end

static AudioRecorder *_audioRecorder;

@implementation AudioRecorder

+ (AudioRecorder *)shareAudioRecorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _audioRecorder = [[self alloc] initAudioRecorder];
    });
    return _audioRecorder;
}

- (instancetype)initAudioRecorder
{
    self = [super init];
    if (self) {
        [self initAudioSession];
        [self initRecorder];
    }
    return self;
}

- (void)initAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)initRecorder
{
    _pcmPath = [self getRecordFilePath];
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithSettings:@{AVSampleRateKey:@(16000.0),
                                                                      AVFormatIDKey:@(kAudioFormatLinearPCM),
                                                                      AVLinearPCMBitDepthKey:@(16),
                                                                      AVNumberOfChannelsKey:@(1),
                                              //3.声道 要转换mp3格式声道就必须设置为2                         AVEncoderAudioQualityKey:@(AVAudioQualityHigh)
                                                                }];
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_pcmPath] format:format error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;//是否启用录音测量，如果启用录音测量可以获得录音分贝等数据信息
    _recorder = recorder;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(upDataVoices) userInfo:nil repeats:YES];
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
- (void)upDataVoices
{
    [_recorder updateMeters];
    //获取音量的平均值  [_recorder averagePowerForChannel:0];
    //音量的最大值  [_recorder peakPowerForChannel:0];
    
    float voices = [_recorder peakPowerForChannel:0];
    NSLog(@"当前音量值 = %.2f", voices);
    
}



- (NSString *)getRecordFilePath
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = [path stringByAppendingPathComponent:@"AudioRecorder"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDire = NO;
    BOOL isEix = [fileManager fileExistsAtPath:path isDirectory:&isDire];
    if (!isDire || !isEix) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingString:@"/pcmFile.pcm"];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    return path;
}

- (BOOL)startRecord
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:_pcmPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_pcmPath error:nil];
    }
    if ([_recorder prepareToRecord]) {
        BOOL isRecording = [_recorder record];
        if (isRecording) {
            [self timer];
        }
        return isRecording;
    } else {
        return NO;
    }
}

- (void)stopRecord
{
    [self invalidate];
    [_recorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"录制完成 flag = %d", flag);
    if (flag) {
        if ([_delegate respondsToSelector:@selector(recordFinishAudioPath:)]) {
            [_delegate recordFinishAudioPath:_pcmPath];
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"录制出错 error = %@", error);
}

@end
