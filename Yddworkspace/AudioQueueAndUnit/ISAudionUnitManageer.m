//
//  ISAudionUnitManageer.m
//  Yddworkspace
//
//  Created by ispeak on 2018/3/16.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "ISAudionUnitManageer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

//bus0就是输出,bus 1代表输入，播放音频文件就是在bus 0传送数据，bus 1输入在Remote IO 默认是关闭的，在录音的状态下 需要把bus 1设置成开启状态。
#define kOutputBus 0
#define kInputBus 1

#define kSampleRate 8000
#define kFramePerPacket 1
#define kChannelPerFrame 1
#define kBitsPerChannel 16
#define BUFFER_SIZE 1024


static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    // TOOO:
    // 使用 inNumberFrames 计算有多少数据是有效的
    // 在 AudioBufferList 里存放着更多的有效空间
    
    AudioBufferList *bufferList; // bufferList里存放着一堆 buffers， buffers的长度是动态的。
    
    // 获得录制的采样数据
    OSStatus status;
    return noErr;
    
}

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    // Notes: ioData 包括了一堆 buffers
    // 尽可能多的向ioData中填充数据，记得设置每个buffer的大小要与buffer匹配好。
    return noErr;
}


static void CheckError(OSStatus error,const char *operaton){
    if (error==noErr) {
        return;
    }
    char errorString[20]={};
    *(UInt32 *)(errorString+1)=CFSwapInt32HostToBig(error);
    if (isprint(errorString[1])&&
        isprint(errorString[2])&&
        isprint(errorString[3])&&
        isprint(errorString[4]))
    {
        errorString[0]=errorString[5]='\'';
        errorString[6]='\0';
    } else {
        sprintf(errorString, "%d",(int)error);
    }
    fprintf(stderr, "Error:%s (%s)\n",operaton,errorString);
    exit(1);
}

@interface ISAudionUnitManageer ()
{
    AudioStreamBasicDescription audioFormat;
}

@property (nonatomic, assign) AudioComponentInstance audioUnit;
@property (nonatomic, assign) AudioBuffer audioBuffer;
@property (nonatomic, strong) NSMutableData *mIn;
@property (nonatomic, strong) NSMutableData *mOut;
@property (nonatomic, strong) NSMutableData *mAllAudioData;



@end

@implementation ISAudionUnitManageer


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initAudioUnit];
    }
    return self;
}

- (void)initAudioUnit
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    OSStatus status;

    // 描述音频元件
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // 获得一个元件
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // 获得 Audio Unit
    status = AudioComponentInstanceNew(inputComponent, &_audioUnit);
    CheckError(status, "AudioComponentInstanceNew");
    
    // 为录制打开 IO
    UInt32 flag = 1;
    status = AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, kInputBus, &flag, sizeof(flag));
    CheckError(status, "为录制打开 IO");
    
    // 描述格式
    audioFormat.mSampleRate         = 44100.00;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mChannelsPerFrame   = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerPacket = 2;
    audioFormat.mBytesPerFrame      = 2;
    
    // 设置格式
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    CheckError(status, "设置格式输入");
    
//    status = AudioUnitSetProperty(_audioUnit,
//                                  kAudioUnitProperty_StreamFormat,
//                                  kAudioUnitScope_Input,
//                                  kOutputBus,
//                                  &audioFormat,
//                                  sizeof(audioFormat));
//    CheckError(status, "设置格式输出");
    
    // 设置数据采集回调函数
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    CheckError(status, "设置数据采集回调函数");
    
    // 设置声音输出回调函数。当speaker需要数据时就会调用回调函数去获取数据。它是 "拉" 数据的概念。
//    callbackStruct.inputProc = playbackCallback;
//    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
//    status = AudioUnitSetProperty(_audioUnit,
//                                  kAudioUnitProperty_SetRenderCallback,
//                                  kAudioUnitScope_Global,
//                                  kOutputBus,
//                                  &callbackStruct,
//                                  sizeof(callbackStruct));
//    CheckError(status, "设置声音输出回调函数");
//
//
//    // 关闭为录制分配的缓冲区（我们想使用我们自己分配的）
//    flag = 0;
//    status = AudioUnitSetProperty(_audioUnit,
//                                  kAudioUnitProperty_ShouldAllocateBuffer,
//                                  kAudioUnitScope_Output,
//                                  kInputBus,
//                                  &flag,
//                                  sizeof(flag));
//    CheckError(status, "关闭为录制分配的缓冲区");
    // 初始化
    status = AudioUnitInitialize(_audioUnit);
    CheckError(status, "初始化");
}

- (void)startAudioUnit
{
    OSStatus status = AudioOutputUnitStart(_audioUnit);
    CheckError(status, "开始录制");
}

- (void)stopAudioUnit
{
    OSStatus status = AudioOutputUnitStop(_audioUnit);
    CheckError(status, "停止录制");
}

- (void)endAudioUnit
{
    OSStatus status = AudioComponentInstanceDispose(_audioUnit);
    CheckError(status, "结束录制");
}
@end
