//
//  IFlySpeek.m
//  Yddworkspace
//
//  Created by ispeak on 2017/2/10.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "IFlySpeek.h"
#import <iflyMSC/iflyMSC.h>

#import "ISRDataHelper.h"
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
#import "iflyMSC/IFlySpeechRecognizer.h"

#define maxSpeekTime 30 //最大说话时长

@interface IFlySpeek ()<IFlySpeechRecognizerDelegate, IFlyPcmRecorderDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;

@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder;//录音器，用于音频流识别的数据传入
@property (nonatomic,assign) BOOL isStreamRec;//是否是音频流识别

@property (nonatomic, strong) NSString *resultStr;
@property (nonatomic, strong) UIImageView *voiceImage;
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) NSTimer *speekTimer;
@property (nonatomic, assign) int countTime;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL isTimeOut;

@end

@implementation IFlySpeek

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
//        [self initIFlySDK];
        [self initIFly];
        [self initView:view];
    }
    return self;
}

#pragma mark - 计算文本宽高 -
- (CGSize)getContentStr:(NSString *)text widthSize:(CGFloat)width heightSize:(CGFloat)height FontOfSize:(UIFont *)fontSize

{
    
    CGSize requiredSize;
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, height)
                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:fontSize}
                                     context:nil];
    
    requiredSize = rect.size;
    
    return requiredSize;
    
}

- (void)initView:(UIView *)view
{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth - 95, ScreenHeight - 145, 85, 92)];
    _bgView.backgroundColor = [UIColor clearColor];
    _bgView.hidden = YES;
    [view addSubview:_bgView];
    
    NSString *str = [NSString stringWithFormat:@"松开手指 取消发送"];
//    CGSize size = [[AppDelegate appDelegate].cmCommonMethod contentString:str cmFontSize:[UIFont systemFontOfSize:8] cmSize:CGSizeMake(1000, 22)];
    CGSize size = [self getContentStr:str widthSize:1000 heightSize:22 FontOfSize:[UIFont systemFontOfSize:8]];
    CGFloat labelWidth = size.width + 22 / 2.0;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((85 - labelWidth) / 2.0, 0, labelWidth, 22)];
    label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:8];
    label.textColor = [UIColor whiteColor];
    label.text = str;
    label.layer.cornerRadius = 11;
    label.layer.masksToBounds = YES;
    _label = label;
    [_bgView addSubview:_label];

    
    _voiceImage = [[UIImageView alloc] initWithFrame:CGRectMake(12.5, 32, 60, 60)];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"voice_empty@2x" ofType:@"png"]];
    _voiceImage.image = image;
    _voiceImage.backgroundColor = [UIColor clearColor];
    [_bgView addSubview:_voiceImage];
    
}

- (void)initIFly
{
    _resultStr = @"";
    //单例模式，无UI的实例
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    }
    
    // 设置参数
    if (_iFlySpeechRecognizer != nil) {
        //扩展参数
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        NSString *maxTimeStr = [NSString stringWithFormat:@"%d", maxSpeekTime * 1000];
        //设置最长录音时间
        [_iFlySpeechRecognizer setParameter:maxTimeStr forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        //设置采样率，推荐使用16K
        [_iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
        //设置语言
        [_iFlySpeechRecognizer setParameter:@"zh_cn" forKey:[IFlySpeechConstant LANGUAGE]];
        //设置方言
        [_iFlySpeechRecognizer setParameter:@"mandarin" forKey:[IFlySpeechConstant ACCENT]];
        //设置是否返回标点符号
        [_iFlySpeechRecognizer setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置数据返回格式
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //取消sdk内部音频默认设置
        [_iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant PLAYER_INIT]];
        [_iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant PLAYER_DEACTIVE]];
        [_iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant RECORDER_INIT]];
        [_iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant RECORDER_DEACTIVE]];
        
        // 设置代理
        _iFlySpeechRecognizer.delegate = self;
    }

    //初始化录音器
    if (_pcmRecorder == nil)
    {
        _pcmRecorder = [IFlyPcmRecorder sharedInstance];
    }
    
    _pcmRecorder.delegate = self;
    
    [_pcmRecorder setSample:@"16000"];
    
    [_pcmRecorder setSaveAudioPath:nil];    //不保存录音文件

}


//音频流识别
- (void)startAudioStream
{
    if (_iFlySpeechRecognizer == nil) {
        [self initIFly];
    }
    
    [_iFlySpeechRecognizer setDelegate:self];
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"@audio_source"];
    BOOL ret = [_iFlySpeechRecognizer startListening];
    if (ret) {
        NSLog(@"启动识别服务成功");
    }else{
        NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
    }
    
}

- (void)speekTimerAction
{
    if (maxSpeekTime >= _countTime && maxSpeekTime - _countTime <= 5) {
        _isTimeOut = YES;
        NSString *str = [NSString stringWithFormat:@"还可以讲话%d秒", maxSpeekTime - _countTime];
        CGSize size = [self getContentStr:str widthSize:1000 heightSize:22 FontOfSize:[UIFont systemFontOfSize:8]];
        CGFloat labelWidth = size.width + 22 / 2.0;
        _label.frame = CGRectMake((85 - labelWidth) / 2.0, 0, labelWidth, 22);
        _label.text = str;
        _label.hidden = NO;
    }
    _countTime++;
}

- (void)releseSpeekTimer
{
    _countTime = 0;
    if (_speekTimer != nil) {
        if ([_speekTimer isValid]) {
            [_speekTimer invalidate];
        }
        _speekTimer = nil;
    }
    
}
//语音识别
- (void)understand
{
    //1.在应用A启动识别前中断正在运行的音乐播放：
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:1],AVAudioSessionInterruptionTypeKey, nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:AVAudioSessionInterruptionNotification object:nil userInfo:userInfo];
//    //2.设置识别AVAudioSession的Category属性：
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord withOptions: AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    
    _resultStr = @"";
    _countTime = 0;
    _isTimeOut = NO;
    _bgView.hidden = NO;
    NSString *str = [NSString stringWithFormat:@"松开手指 取消发送"];
    CGSize size = [self getContentStr:str widthSize:1000 heightSize:22 FontOfSize:[UIFont systemFontOfSize:8]];
    CGFloat labelWidth = size.width + 22 / 2.0;
    _label.frame = CGRectMake((85 - labelWidth) / 2.0, 0, labelWidth, 22);
    _label.text = str;
    //1.在应用A启动识别前设置AVAudioSession的Category属性：
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    if(_iFlySpeechRecognizer == nil)
    {
        [self initIFly];
    }

    [_iFlySpeechRecognizer cancel];
    
    
    BOOL ret = [_iFlySpeechRecognizer startListening];
    
    if (ret) {
        NSLog(@"启动识别服务成功");
        if (_speekTimer == nil) {
            _speekTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(speekTimerAction) userInfo:nil repeats:YES];
            [_speekTimer fire];
        }
    }else{
        NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
        _bgView.hidden = YES;
        _voiceImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"voice_empty@2x" ofType:@"png"]];
        if ([_delegate respondsToSelector:@selector(returnErrorCode:)]) {
            [_delegate returnErrorCode:-1];
        }
    }
}

- (void)end
{
    NSLog(@"endtime开始识别");
    _bgView.hidden = YES;
    _label.hidden = YES;
    [self releseSpeekTimer];
    [_iFlySpeechRecognizer stopListening];
}

- (void)cancel
{
    _bgView.hidden = YES;
    _label.hidden = YES;
    [self releseSpeekTimer];
    [_iFlySpeechRecognizer cancel];
}

- (void)cancelPromptIsShow:(BOOL)isShow
{
    if (!_iFlySpeechRecognizer.isListening) {
        return;
    }
    if (_isTimeOut) {
        return;
    }
    if (isShow) {
        _label.hidden = NO;
    } else {
        _label.hidden = YES;
    }
}

- (void)releseIFly
{
    [_iFlySpeechRecognizer cancel]; //取消识别
    [_iFlySpeechRecognizer setDelegate:nil];
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    [_pcmRecorder stop];
    _pcmRecorder.delegate = nil;
    [self releseSpeekTimer];
}

#pragma IFlySpeechRecognizerDelegate
#pragma {
/**
 开始录音回调
 ****/
- (void) onBeginOfSpeech
{
    NSLog(@"正在录音");
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"停止录音");
    [_pcmRecorder stop];
}

/**
 识别取消回调
 ***/

- (void)onCancel
{
    NSLog(@"取消识别回调");
}

/**
 音量变化回调
 ***/
- (void) onVolumeChanged: (int)volume
{
//    NSLog(@"说话音量 volume = %d", volume);
    if (volume > 10) {
        _voiceImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"voice_full@2x" ofType:@"png"]];
    } else {
        _voiceImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"voice_empty@2x" ofType:@"png"]];
    }
}


/**
 识别错误回调
 ***/
- (void) onError:(IFlySpeechError *)errorCode
{
    NSLog(@"识别错误回调\n code = %d,\n codeType = %d,\n desc = %@", errorCode.errorCode, errorCode.errorType, errorCode.errorDesc);
    _bgView.hidden = YES;
    _label.hidden = YES;
    
    _voiceImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"voice_empty@2x" ofType:@"png"]];
    _resultStr = @"";
    if ([_delegate respondsToSelector:@selector(returnErrorCode:)]) {
        [_delegate returnErrorCode:errorCode.errorCode];
    }
    
//    在此回调方法中先恢复设置启动识别之前的AVAudioSession的Category属性。然后在此回调方法中恢复应用A之前的音乐播放：
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0],AVAudioSessionInterruptionTypeKey, nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:AVAudioSessionInterruptionNotification object:nil userInfo:userInfo];
}

/**
 * 识别结果回调
 */
- (void) onResults:(NSArray *)results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    _resultStr = [NSString stringWithFormat:@"%@%@", _resultStr,resultFromJson];

    if (isLast){
        [_delegate returnResultStr:_resultStr];
        NSLog(@"识别结果范返回时间 time %@", _resultStr);
        _resultStr = @"";
    } else {
        NSLog(@"识别结果 %@", _resultStr);
    }
    
    
}
#pragma }


#pragma mark - IFlyPcmRecorderDelegate

- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    
    int ret = [self.iFlySpeechRecognizer writeAudio:audioBuffer];
    if (!ret)
    {
        [self.iFlySpeechRecognizer stopListening];
    }
    NSLog(@"回调音频数据");
}

- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    NSLog(@"回调音频的错误码 ecoder = %d", error);
}

//power:0-100,注意控件返回的音频值为0-30
- (void) onIFlyRecorderVolumeChanged:(int) power
{
    //    NSLog(@"%s,power=%d",__func__,power);
    
    NSString * vol = [NSString stringWithFormat:@"音量：%d",power];
}



@end
