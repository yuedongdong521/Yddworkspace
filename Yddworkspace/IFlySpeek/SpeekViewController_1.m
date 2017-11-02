//
//  SpeekViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/3/1.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "SpeekViewController.h"
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>

@interface SpeekViewController ()<SFSpeechRecognizerDelegate>

@property (strong, nonatomic) UIButton *siriBtu;//siri按钮
@property (strong, nonatomic) UITextView *siriTextView; //显示语音转化成的文本
@property (strong, nonatomic) SFSpeechRecognitionTask *recognitionTask; //语音识别任务
@property (strong, nonatomic)SFSpeechRecognizer *speechRecognizer; //语音识别器
@property (strong, nonatomic) SFSpeechAudioBufferRecognitionRequest *recognitionRequest; //识别请求
@property (strong, nonatomic)AVAudioEngine *audioEngine; //录音引擎

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioSession *myAudioSession;
@property (nonatomic, strong) NSTimer *volumeTimer;

@end

@implementation SpeekViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    //监听系统音量
//    AVSystemController_SystemVolumeDidChangeNotification
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];//注，ios9上不加这一句会无效，加了这一句后，
    
    //在移除通知时候加上这句[[UIApplication sharedApplication] endReceivingRemoteControlEvents]
    
    _siriBtu = [UIButton buttonWithType:UIButtonTypeCustom];
    _siriBtu.frame = CGRectMake(ScreenWidth / 2 - 100 / 2, ScreenHeight - 100, 100, 50);
    [_siriBtu setTitle:@"开始" forState:UIControlStateNormal];
    [_siriBtu addTarget:self action:@selector(microphoneTap:) forControlEvents:UIControlEventTouchUpInside];
    [_siriBtu addTarget:self action:@selector(microphoneTap:) forControlEvents:UIControlEventTouchDown];
    _siriBtu.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_siriBtu];
    self.siriBtu.enabled = false;
    
    self.siriTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 80, ScreenWidth - 40, ScreenHeight - 200)];
    self.siriTextView.backgroundColor = [UIColor grayColor];
    self.siriTextView.textColor = [UIColor blackColor];
    [self.view addSubview:self.siriTextView];
    

    
    [self initSpeeckRecognizer];
    
    
}

- (void)initSpeeckRecognizer
{
    //设备识别语言为中文
    NSLocale *cale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh-CN"];
    self.speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:cale];
    //语音识别风格，
    self.speechRecognizer.defaultTaskHint = SFSpeechRecognitionTaskHintDictation;//正常的听写风格
    //设置代理
    _speechRecognizer.delegate = self;
    //发送语音认证请求(首先要判断设备是否支持语音识别功能)
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        bool isButtonEnabled = false;
//        typedef NS_ENUM(NSInteger, SFSpeechRecognizerAuthorizationStatus) {
//            //结果未知 用户尚未进行选择
//            SFSpeechRecognizerAuthorizationStatusNotDetermined,
//            //用户拒绝授权语音识别
//            SFSpeechRecognizerAuthorizationStatusDenied,
//            //设备不支持语音识别功能
//            SFSpeechRecognizerAuthorizationStatusRestricted,
//            //用户授权语音识别
//            SFSpeechRecognizerAuthorizationStatusAuthorized,
//        };
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                isButtonEnabled = true;
                NSLog(@"可以语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                isButtonEnabled = false;
                NSLog(@"用户被拒绝访问语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                isButtonEnabled = false;
                NSLog(@"不能在该设备上进行语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                isButtonEnabled = false;
                NSLog(@"没有授权语音识别");
                break;
            default:
                break;
        }
        self.siriBtu.enabled = isButtonEnabled;
    }];
    
    //创建录音引擎
//    self.audioEngine = [[AVAudioEngine alloc]init];
    [self audio];
}

- (void)audio{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    //录音设置
    
    NSMutableDictionary*recordSetting = [[NSMutableDictionary alloc]init];
    
    //设置录音格式
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC]forKey:AVFormatIDKey];
    
    //设置录音采样率(Hz)如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    
    [recordSetting setValue:[NSNumber numberWithFloat:44100]forKey:AVSampleRateKey];
    
    //录音通道数1或2
    
    [recordSetting setValue:[NSNumber numberWithInt:1]forKey:AVNumberOfChannelsKey];
    
    //线性采样位数8、16、24、32
    
    [recordSetting setValue:[NSNumber numberWithInt:16]forKey:AVLinearPCMBitDepthKey];
    
    //录音的质量
    
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh]forKey:AVEncoderAudioQualityKey];
    
    NSString*strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
    static int number = 0;
    NSURL * urlPlay= [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%d.aac", strUrl, number++]];
    
    NSError*error;
    
    //初始化
    
    _recorder= [[AVAudioRecorder alloc]initWithURL:urlPlay settings:recordSetting error:&error];
    
    //开启音量检测
    _recorder.meteringEnabled=YES;
    
}

- (void)microphoneTap:(UIButton *)sender {
//    if ([self.audioEngine isRunning]) {
//        [self.audioEngine stop];
//        [self.recognitionRequest endAudio];
//        self.siriBtu.enabled = YES;
//        [self.siriBtu setTitle:@"开始录制" forState:UIControlStateNormal];
//    }else{
//        [self startRecording];
//        [self.siriBtu setTitle:@"正在录制" forState:UIControlStateNormal];
//    }
}

-(void)startRecording{
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    bool  audioBool = [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    bool  audioBool1= [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    bool  audioBool2= [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (audioBool || audioBool1||  audioBool2) {
        NSLog(@"可以使用");
    }else{
        NSLog(@"这里说明有的功能不支持");
    }
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
//    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    self.recognitionRequest.shouldReportPartialResults = true;
    
    //开始识别任务
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        NSLog(@"thread = %@ \n result: %@", [NSThread currentThread],result);
        
        bool isFinal = false;
        if (result) {
            
            //是否已经完成 如果YES 则所有所有识别信息都已经获取完成
            isFinal = [result isFinal];
            
            //准确性最高的识别实例
            NSString *text = [[result bestTranscription] formattedString]; //语音转文本
            self.siriTextView.text = text;
            
        }
        if (error || isFinal) {
//            [self.audioEngine stop];
//            [inputNode removeTapOnBus:0];
            
            [_recorder stop];
            
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
            self.siriBtu.enabled = true;
        }
    }];
//    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
//    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
//        //拼接音频流
//        [self.recognitionRequest appendAudioPCMBuffer:buffer];
//    }];
//    [self.audioEngine prepare];
//    bool audioEngineBool = [self.audioEngine startAndReturnError:nil];
//    NSLog(@"%d",audioEngineBool);
//    self.siriTextView.text = @"我是小冰！Siri 冰，你说我听";
    
    
    
    //开始录音
    [_recorder prepareToRecord];
    
    [_recorder record];
    
    
}

- (void)startUpDateVolumeTimer
{
    if (_volumeTimer == nil) {
        __weak SpeekViewController *weak_self = self;
        _volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weak_self updateVolume];
        }];
        [_volumeTimer fire];
    }

}

- (void)invalidVolumeTimer {
    if (_volumeTimer) {
        if ([_volumeTimer isValid]) {
            [_volumeTimer invalidate];
        }
        _volumeTimer = nil;
    }
}

- (void)updateVolume
{
    [_recorder updateMeters];
    CGFloat volume = [_recorder peakPowerForChannel:0];
    NSLog(@"当前音量 %f", volume);
}

//当语音识别操作可用性发生改变时会被调用
-(void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    if(available){
        self.siriBtu.enabled = true;
    }else{
        self.siriBtu.enabled = false;
    }
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
