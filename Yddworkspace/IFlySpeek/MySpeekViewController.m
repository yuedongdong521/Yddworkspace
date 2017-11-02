//
//  MySpeekViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/3/18.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MySpeekViewController.h"
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>
#import "PcmToMp3Manager.h"
#import "lame.h"

@interface MySpeekViewController ()<SFSpeechRecognizerDelegate, AVAudioRecorderDelegate, PcmToMp3ManagerDelegate>

@property (nonatomic, strong) UIButton *speekBtn;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) SFSpeechRecognizer *recongizer;
//@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechURLRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSURL *pathUrl;
@property (nonatomic, strong) NSString *mp3FileName;
@property (nonatomic, assign) BOOL isStopRecorde;
@property (nonatomic, assign) BOOL isFinishConvert;
@property (nonatomic, assign) NSString *mp3Path;
@property (nonatomic, assign) AVAudioPlayer *player;

@property (nonatomic, strong) PcmToMp3Manager *manager;

@end

@implementation MySpeekViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _speekBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _speekBtn.frame = CGRectMake(ScreenWidth / 2 - 50, ScreenHeight - 100, 100, 80);
    [_speekBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [_speekBtn setTitle:@"按住说话" forState:UIControlStateSelected];
    [_speekBtn addTarget:self action:@selector(startSpeek:) forControlEvents:UIControlEventTouchDown];
    [_speekBtn addTarget:self action:@selector(stopSpeek:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_speekBtn];
    
    [self setAVAuidoSession];
    [self initSFSpeechRecognizer];
    [self initRecorder];
    
    [self initPCMToMP3Manager];
    
    //注册处理中断通知
    NSNotificationCenter *nc= [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
    // //注册线路改变通知
    [nc addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    
}

- (void)initPCMToMP3Manager
{
    self.manager = [[PcmToMp3Manager alloc] init];
    self.manager.delegate = self;
}


- (void)handleInterruption:(NSNotification *)notification
{
    //收到通知 处理中断事件
    NSDictionary *info = notification.userInfo;
    
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        
        //执行中断开始事件
        [self.player stop];
    }
    
    else
    {
        //执行中断结束事件
        
        AVAudioSessionCategoryOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        
        //会话是否重新激活以及是否可以再次播放
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            
            [self.player play];
        }
    }
}

- (void)handleRouteChange:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    
    AVAudioSessionRouteChangeReason reson = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    
    //设备断开时停止播放
    if (reson == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        
        AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
        
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
        
        NSString *portType = previousOutput.portType;
        
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self.player stop];
        }
    }
}

- (void)initAuidoPlayer:(NSString *)path
{
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];
    //音量
    player.volume = 1.0;
    //立体播放声音
    player.pan = 0.5;
    //调整播放率
    player.enableRate = YES;
    //快慢
    player.rate = 1.5;
    //无缝循环，为-1则无限循环
    player.numberOfLoops = -1;
    if (player) {
        //预加载，可降低调用Play方法和听到声音输出之间的延时（可选的）
        [player prepareToPlay];
        //会隐性激活prepareToPlay方法
        [player play];
        self.player = player;
    }
}


- (void)initSFSpeechRecognizer
{

    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-CN"];
    _recongizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
    //设置语音识别的配置参数 需要注意 在每个语音识别请求中也有这样一个属性 这里设置将作为默认值
    //如果SFSpeechRecognitionRequest对象中也进行了设置 则会覆盖这里的值
    self.recongizer.defaultTaskHint = SFSpeechRecognitionTaskHintDictation;
    self.recongizer.delegate = self;
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
    }];
    
    
}

- (void)startSFSpeechRecognizer
{
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

    
    self.recognitionRequest = [[SFSpeechURLRecognitionRequest alloc] initWithURL:[NSURL URLWithString:_mp3Path]];
    self.recognitionRequest.shouldReportPartialResults = true;
    self.recognitionTask = [self.recongizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            isFinal = [result isFinal];
            if (isFinal) {
                NSString *text = [[result bestTranscription] formattedString];
                NSLog(@"识别结果：%@", text);
            }
        }
        if (error || isFinal) {
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
        }
    }];
    
}


- (NSString *)getSaveFilePath
{
    NSString *pathStr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    pathStr = [pathStr stringByAppendingPathComponent:@"recorder.pcm"];
    NSFileManager *manager = [[NSFileManager alloc] init];
    if ([manager fileExistsAtPath:pathStr]) {
     
        [manager removeItemAtPath:pathStr error:nil];
    }
    return pathStr;
}

- (void)initRecorder
{
    NSString *filePath = [self getSaveFilePath];
    NSURL *url = [NSURL URLWithString:filePath];
    self.pathUrl = url;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [dic setObject:@(11025.0) forKey:AVSampleRateKey];
    [dic setObject:@(2) forKey:AVNumberOfChannelsKey];
    [dic setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    [dic setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    NSError *error = nil;
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:dic error:&error];
    if (error) {
        return;
    }
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    self.recorder = recorder;
   
    
}

- (void)setAVAuidoSession{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

//录音完成回调
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        self.manager.pcmFilePath = self.pathUrl.absoluteString;
        NSString *mp3Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"mp3File.mp3"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:mp3Path]) {
            [[NSFileManager defaultManager] removeItemAtPath:mp3Path error:nil];
        }
//        self.manager.mp3FilePath = mp3Path;
//        [self.manager startConvert];
        [self audio_PCMtoMP3];
    }
    
}

- (void)didConvertPcmToMp3:(PcmToMp3Manager *)manager sucess:(BOOL)sucess errorInfo:(NSString *)errorInfo
{
    if (sucess) {
        [self initAuidoPlayer:manager.mp3FilePath];
    }
}


- (void)startSpeek:(UIButton *)btn
{
    if (![_recorder isRecording]) {
        [_recorder record];
    }
}

- (void)stopSpeek:(UIButton *)btn
{
    if([_recorder isRecording]) {
        [_recorder stop];
    }
}


- (void)audio_PCMtoMP3
{
    
    NSString *mp3FilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"mp3File.mp3"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mp3FilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:mp3FilePath error:nil];
    }

    
    @try {
        int read, write;
        
        FILE *pcm = fopen([self.pathUrl.absoluteString cStringUsingEncoding:1], "rb"); //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR); //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
//        self.pathUrl = [NSURL URLWithString:mp3FilePath];
        NSLog(@"MP3生成成功: %@", self.pathUrl);
        [self initAuidoPlayer:mp3FilePath];
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
