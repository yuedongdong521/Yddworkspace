//
//  VoiceConvertHandle.m
//  BleVOIP
//
//  Created by JustinYang on 16/6/14.
//  Copyright © 2016年 JustinYang. All rights reserved.
//

#define handleError(error)  if(error){ NSLog(@"%@",error); exit(1);}
#define kSmaple     44100

#define kOutoutBus 0
#define kInputBus  1
//存取PCM原始数据的节点
typedef struct PCMNode{
    struct PCMNode *next;
    struct PCMNode *previous;
    void        *data;
    unsigned int dataSize;
} PCMNode;



#import "VoiceConvertHandle.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

#include <pthread.h>

#import "BNRAudioData.h"

#define kRecordDataLen  (1024*20)
typedef struct {
    NSInteger   front;
    NSInteger   rear;
    SInt16      recordArr[kRecordDataLen];
} RecordStruct;

/*
 * pthread_mutex_t recordLock; 声明pthread_mutex_t(互斥锁)的结构
 * pthread_cond_init recordCond; 初始化条件数据结构
 */

static pthread_mutex_t  recordLock;
static pthread_cond_t   recordCond;

static pthread_mutex_t  playLock;
static pthread_cond_t   playCond;

static pthread_mutex_t  buffLock;
static pthread_cond_t   buffcond;

@interface BNRAudioQueueBuffer : NSObject
@property (nonatomic,assign) AudioQueueBufferRef buffer;
@end
@implementation BNRAudioQueueBuffer
@end

@interface VoiceConvertHandle ()
{
    AURenderCallbackStruct      _inputProc;
    AudioStreamBasicDescription _audioFormat;
    AudioStreamBasicDescription mAudioFormat;
    
 
    AudioConverterRef           _encodeConvertRef;
    
    AudioQueueRef               _playQueue;
    AudioQueueBufferRef         _queueBuf[3];
    
    
    NSMutableArray *_buffers;
    NSMutableArray *_reusableBuffers;
}

@property (nonatomic,weak)   AVAudioSession *session;
@property (nonatomic,assign) AudioComponentInstance toneUnit;

@property (nonatomic,strong) NSMutableArray     *aacArry;

@end

@implementation VoiceConvertHandle
RecordStruct    recordStruct;

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static VoiceConvertHandle *handle;
    dispatch_once(&onceToken, ^{
        handle = [[VoiceConvertHandle alloc] init];
        [handle dataInit];
        [handle configAudio];
    });
    return handle;
}
-(void)setStartRecord:(BOOL)startRecord{
    _startRecord = startRecord;
    _startRecord? CheckError(AudioOutputUnitStart(_toneUnit), "couldnt start audio unit"): CheckError(AudioOutputUnitStop(_toneUnit), "couldnt stop audio unit");
}

#pragma mark 监听音频输出路线
-(void)audioSessionRouteChangeHandle:(NSNotification *)noti{
//    NSError *error;
//    [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
//    handleError(error);
    [self.session setActive:YES error:nil];
    if (self.startRecord) {
        CheckError(AudioOutputUnitStart(_toneUnit), "couldnt start audio unit");
    }
}
-(void)configAudio{
    _inputProc.inputProc = inputRenderTone;
    _inputProc.inputProcRefCon = (__bridge void *)(self);
    
    //对AudioSession的一些设置
    NSError *error;
    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    handleError(error);
    //route变化监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChangeHandle:) name:AVAudioSessionRouteChangeNotification object:self.session];
    
    [self.session setPreferredIOBufferDuration:0.005 error:&error];
    handleError(error);
    [self.session setPreferredSampleRate:kSmaple error:&error];
    handleError(error);
    
//    [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
//    handleError(error);
    
    [self.session setActive:YES error:&error];
    handleError(error);
    
    /************************************************************
     ************************************************************/
    
    // 1、音频数据采集
    // 设置 Audio Unit
    //    Obtain a RemoteIO unit instance
    AudioComponentDescription acd;
    acd.componentType = kAudioUnitType_Output;
    acd.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    acd.componentFlags = 0;
    acd.componentFlagsMask = 0;
    acd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &acd);
    AudioComponentInstanceNew(inputComponent, &_toneUnit);
    
    
    UInt32 enable = 1;
    AudioUnitSetProperty(_toneUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         kInputBus,
                         &enable,
                         sizeof(enable));

    
    mAudioFormat.mSampleRate         = kSmaple;//采样率
    mAudioFormat.mFormatID           = kAudioFormatLinearPCM;//PCM采样
    mAudioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    mAudioFormat.mFramesPerPacket    = 1;//每个数据包多少帧
    mAudioFormat.mChannelsPerFrame   = 1;//1单声道，2立体声
    mAudioFormat.mBitsPerChannel     = 16;//语音每采样点占用位数
    mAudioFormat.mBytesPerFrame      = mAudioFormat.mBitsPerChannel*mAudioFormat.mChannelsPerFrame/8;//每帧的bytes数
    mAudioFormat.mBytesPerPacket     = mAudioFormat.mBytesPerFrame*mAudioFormat.mFramesPerPacket;//每个数据包的bytes总数，每帧的bytes数＊每个数据包的帧数
    mAudioFormat.mReserved           = 0;
    
    CheckError(AudioUnitSetProperty(_toneUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output, kInputBus,
                                    &mAudioFormat, sizeof(mAudioFormat)),
               "couldn't set the remote I/O unit's input client format");
    
    CheckError(AudioUnitSetProperty(_toneUnit,
                                    kAudioOutputUnitProperty_SetInputCallback,
                                    kAudioUnitScope_Output,
                                    kInputBus,
                                    &_inputProc, sizeof(_inputProc)),
               "couldnt set remote i/o render callback for input");
    
    
    CheckError(AudioUnitInitialize(_toneUnit),
               "couldn't initialize the remote I/O unit");
//    CheckError(AudioOutputUnitStart(_toneUnit), "couldnt start audio unit");
    
   
    
    // 音频转码
    // 初始化
    //convertInit for PCM TO AAC
    AudioStreamBasicDescription sourceDes = mAudioFormat;

    AudioStreamBasicDescription targetDes;
    memset(&targetDes, 0, sizeof(targetDes));
    targetDes.mFormatID = kAudioFormatMPEG4AAC;
    targetDes.mSampleRate = kSmaple;
    targetDes.mChannelsPerFrame = sourceDes.mChannelsPerFrame;

    UInt32 size = sizeof(targetDes);
    CheckError(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                      0, NULL, &size, &targetDes),
               "couldnt create target data format");


//     选择软件编码
//     主要是设置编码器的输入音频格式(PCM),输出音频格式(AAC),选择软件编码器(默认使用硬件编码器),设置编码器的比特率
    AudioClassDescription audioClassDes;
    CheckError(AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders,
                                          sizeof(targetDes.mFormatID),
                                          &targetDes.mFormatID,
                                          &size), "cant get kAudioFormatProperty_Encoders");
    UInt32 numEncoders = size/sizeof(AudioClassDescription);
    AudioClassDescription audioClassArr[numEncoders];
    CheckError(AudioFormatGetProperty(kAudioFormatProperty_Encoders,
                                      sizeof(targetDes.mFormatID),
                                      &targetDes.mFormatID,
                                      &size,
                                      audioClassArr),
               "wrirte audioClassArr fail");
    for (int i = 0; i < numEncoders; i++) {
        if (audioClassArr[i].mSubType == kAudioFormatMPEG4AAC
            && audioClassArr[i].mManufacturer == kAppleSoftwareAudioCodecManufacturer) {
            memcpy(&audioClassDes, &audioClassArr[i], sizeof(AudioClassDescription));
            break;
        }
    }

    CheckError(AudioConverterNewSpecific(&sourceDes, &targetDes, 1,
                                         &audioClassDes, &_encodeConvertRef),
               "cant new convertRef");

    size = sizeof(sourceDes);
    CheckError(AudioConverterGetProperty(_encodeConvertRef, kAudioConverterCurrentInputStreamDescription, &size, &sourceDes), "cant get kAudioConverterCurrentInputStreamDescription");

    size = sizeof(targetDes);
    CheckError(AudioConverterGetProperty(_encodeConvertRef, kAudioConverterCurrentOutputStreamDescription, &size, &targetDes), "cant get kAudioConverterCurrentOutputStreamDescription");

    UInt32 bitRate = 64000;
    size = sizeof(bitRate);
    CheckError(AudioConverterSetProperty(_encodeConvertRef,
                                         kAudioConverterEncodeBitRate,
                                         size, &bitRate),
               "cant set covert property bit rate");
    

//     开启转码线程
    [self performSelectorInBackground:@selector(convertPCMToAAC) withObject:nil];
  
    /************************************************************
     ************************************************************/
    
    // 2、音频播放
    // Audio Queue 播放AAC音频数据
    /*
     音频数据以一个个`AudioQueueBuffer`的形式存在与音频队列中，`Audio Queue`使用它提供的音频数据来播放，某一个`AudioQueueBuffer`使用完毕后，会调用`Audio Queue`的回调，要求用户再在这个`AudioQueueBuffer`填入数据，并使它加入`Audio Queue`中，如此循环，达到不间断播放音频数据的效果。
     */
    
    // Audio Queue初始化
    CheckError(AudioQueueNewOutput(&targetDes,
                                   fillBufCallback,
                                   (__bridge void *)self,
                                   NULL,
                                   NULL,
                                   0,
                                   &(_playQueue)),
               "cant new audio queue");
    CheckError( AudioQueueSetParameter(_playQueue,
                                       kAudioQueueParam_Volume, 1.0),
               "cant set audio queue gain");

    for (int i = 0; i < 3; i++) {
        AudioQueueBufferRef buffer;
        CheckError(AudioQueueAllocateBuffer(_playQueue, 1024, &buffer), "cant alloc buff");
        BNRAudioQueueBuffer *buffObj = [[BNRAudioQueueBuffer alloc] init];
        buffObj.buffer = buffer;
        [_buffers addObject:buffObj];
        [_reusableBuffers addObject:buffObj];

    }

    [self performSelectorInBackground:@selector(playData) withObject:nil];
}


-(void)dataInit{
    int rc;
    rc = pthread_mutex_init(&recordLock,NULL);
    assert(rc == 0);
    rc = pthread_cond_init(&recordCond, NULL);
    assert(rc == 0);
    
    rc = pthread_mutex_init(&playLock,NULL);
    assert(rc == 0);
    rc = pthread_cond_init(&playCond, NULL);
    assert(rc == 0);
    
    rc = pthread_mutex_init(&buffLock,NULL);
    assert(rc == 0);
    rc = pthread_cond_init(&buffcond, NULL);
    assert(rc == 0);
    
    
    memset(recordStruct.recordArr, 0, kRecordDataLen);
    recordStruct.front = recordStruct.rear = 0;
    
    self.aacArry = [[NSMutableArray alloc] init];
    
    _buffers = [[NSMutableArray alloc] init];
    _reusableBuffers = [[NSMutableArray alloc] init];
    
}


#pragma mark 采集音频数据的采集输入回调
static OSStatus inputRenderTone(
                         void *inRefCon,
                         AudioUnitRenderActionFlags 	*ioActionFlags,
                         const AudioTimeStamp 		*inTimeStamp,
                         UInt32 						inBusNumber,
                         UInt32 						inNumberFrames,
                         AudioBufferList 			*ioData)

{
    
    VoiceConvertHandle *THIS=(__bridge VoiceConvertHandle*)inRefCon;
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;
    OSStatus status = AudioUnitRender(THIS->_toneUnit,
                                      ioActionFlags,
                                      inTimeStamp,
                                      kInputBus,
                                      inNumberFrames,
                                      &bufferList);
    
    NSInteger lastTimeRear = recordStruct.rear;
    for (int i = 0; i < inNumberFrames; i++) {
        SInt16 data = ((SInt16 *)bufferList.mBuffers[0].mData)[i];
        recordStruct.recordArr[recordStruct.rear] = data;
        recordStruct.rear = (recordStruct.rear+1)%kRecordDataLen;
    }
    // 采用循环队列存储原始的音频数据，每1024点的PCM数据，让Converter转换为AAC编码,所以当收集了1024点PCM后，唤醒Converter线程。pthread_cond_signal 唤醒转码线程
    if ((lastTimeRear/1024 + 1) == (recordStruct.rear/1024)) {
         pthread_cond_signal(&recordCond);
    }
    return status;
}

#pragma mark AAC编码
/**
    新建的`bufferList`是用来存放每次转码后的AAC音频数据.for循环中等待音频输入回调存满1024个PCM数组并唤醒它。`outputPacketDescriptions`数组是每次转换的AAC编码后各个包的描述,但这里每次只转换一包数据(由传入的packetSize决定)。调用`AudioConverterFillComplexBuffer`触发转码，他的第二个参数是填充原始音频数据的回调。转码完成后，会将转码的数据存放在它的第五个参数中(`bufferList `).转换完成的AAC就可以发送给另外一台手机了。
 */
-(void)convertPCMToAAC{
    UInt32 maxPacketSize = 0;
    UInt32 size = sizeof(maxPacketSize);
    CheckError(AudioConverterGetProperty(_encodeConvertRef,
                                         kAudioConverterPropertyMaximumOutputPacketSize,
                                         &size,
                                         &maxPacketSize),
               "cant get max size of packet");
    
    AudioBufferList *bufferList = malloc(sizeof(AudioBufferList));
    bufferList->mNumberBuffers = 1;
    bufferList->mBuffers[0].mNumberChannels = 1;
    bufferList->mBuffers[0].mData = malloc(maxPacketSize);
    bufferList->mBuffers[0].mDataByteSize = maxPacketSize;
    
    for (; ; ) {
        @autoreleasepool {
            
        
        pthread_mutex_lock(&recordLock);
        while (ABS(recordStruct.rear - recordStruct.front) < 1024 ) {
            pthread_cond_wait(&recordCond, &recordLock);
        }
        pthread_mutex_unlock(&recordLock);
        
        SInt16 *readyData = (SInt16 *)calloc(1024, sizeof(SInt16));
        memcpy(readyData, &recordStruct.recordArr[recordStruct.front], 1024*sizeof(SInt16));
        recordStruct.front = (recordStruct.front+1024)%kRecordDataLen;
        UInt32 packetSize = 1;
        AudioStreamPacketDescription *outputPacketDescriptions = malloc(sizeof(AudioStreamPacketDescription)*packetSize);
        bufferList->mBuffers[0].mDataByteSize = maxPacketSize;
        CheckError(AudioConverterFillComplexBuffer(_encodeConvertRef,
                                                   encodeConverterComplexInputDataProc,
                                                   readyData,
                                                   &packetSize,
                                                   bufferList,
                                                   outputPacketDescriptions),
                   "cant set AudioConverterFillComplexBuffer");
        free(outputPacketDescriptions);
        free(readyData);

        NSMutableData *fullData = [NSMutableData dataWithBytes:bufferList->mBuffers[0].mData length:bufferList->mBuffers[0].mDataByteSize];
        // 发送aac音频数据
        if ([self.delegate respondsToSelector:@selector(covertedData:)]) {
            [self.delegate covertedData:[fullData copy]];
        }
//            static int lastIndex = 0;
//            pthread_mutex_lock(&playLock);
//            AudioStreamPacketDescription packetDescription;
//            packetDescription.mDataByteSize = (UInt32)[fullData length];
//            packetDescription.mStartOffset = lastIndex;
//            lastIndex += [fullData length];
//            BNRAudioData *audioData = [BNRAudioData parsedAudioDataWithBytes:[fullData bytes] packetDescription:packetDescription];
//            [self.aacArry addObject:audioData];
//            BOOL  couldSignal = NO;
//            if (self.aacArry.count%8 == 0 && self.aacArry.count > 0) {
//                lastIndex = 0;
//                couldSignal = YES;
//            }
//                pthread_mutex_unlock(&playLock);
//            if (couldSignal) {
//                pthread_cond_signal(&playCond);
//            }
        }
    }
}

#pragma mark 收到音频数据开始播放
-(void)playWithData:(NSData *)data{
        static int lastIndex = 0;
        pthread_mutex_lock(&playLock);
        AudioStreamPacketDescription packetDescription;
        packetDescription.mDataByteSize = (UInt32)[data length];
        packetDescription.mStartOffset = lastIndex;
        lastIndex += [data length];
        BNRAudioData *audioData = [BNRAudioData parsedAudioDataWithBytes:[data bytes] packetDescription:packetDescription];
        [self.aacArry addObject:audioData];
        BOOL  couldSignal = NO;
        if (self.aacArry.count%8 == 0 && self.aacArry.count > 0) {
            lastIndex = 0;
            couldSignal = YES;
        }
            pthread_mutex_unlock(&playLock);
        if (couldSignal) {
            pthread_cond_signal(&playCond); // 唤醒播放线程
        }
}


#pragma mark Audio Queue播放音频数据
/**
 在`playData`中等待收到的`aacArry`数据，**这里要注意:每1024点PCM转换成的一包AAC数据加入到`AudioQueueBuffer`中，不足以使Audio Queue播放音频，所以这里使用8包AAC数据放到一个`AudioQueueBuffer`中**。`fillBufCallback`是Audio Queue播放完一个`AudioQueueBuffer`调用的回调函数，在这里面通知`playData`可以往使用完的`AudioQueueBufferRef`填数据了，填完后，用`AudioQueueEnqueueBuffer`将它加入`Audio Queue`中，这个三个`AudioQueueBufferRef`不断重用。
 */

-(void)playData{
    for (; ; ) {
        @autoreleasepool {
            
        NSMutableData *data = [[NSMutableData alloc] init];
        pthread_mutex_lock(&playLock);
        if (self.aacArry.count%8 != 0 || self.aacArry.count == 0) {
            pthread_cond_wait(&playCond, &playLock);
        }
        AudioStreamPacketDescription *paks = calloc(sizeof(AudioStreamPacketDescription), 8);
        for (int i = 0; i < 8 ; i++) { // 8包AAC数据组成放入一个AudioQueueBuffer的数据包
            BNRAudioData *audio = [self.aacArry firstObject];
            [data appendData:audio.data];
            paks[i].mStartOffset = audio.packetDescription.mStartOffset;
            paks[i].mDataByteSize = audio.packetDescription.mDataByteSize;
            [self.aacArry removeObjectAtIndex:0];
        }
        pthread_mutex_unlock(&playLock);
        
        pthread_mutex_lock(&buffLock);
        if (_reusableBuffers.count == 0) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                AudioQueueStart(_playQueue, nil);
            });
            pthread_cond_wait(&buffcond, &buffLock);
           
        }
        BNRAudioQueueBuffer *bufferObj = [_reusableBuffers firstObject];
        [_reusableBuffers removeObject:bufferObj];
        pthread_mutex_unlock(&buffLock);
        
        memcpy(bufferObj.buffer->mAudioData,[data bytes] , [data length]);
        bufferObj.buffer->mAudioDataByteSize = (UInt32)[data length];
        CheckError(AudioQueueEnqueueBuffer(_playQueue, bufferObj.buffer, 8, paks), "cant enqueue");
        free(paks);

        }
    }
}


#pragma mark 填充原始数据回调
OSStatus encodeConverterComplexInputDataProc(AudioConverterRef inAudioConverter,
                                             UInt32 *ioNumberDataPackets,
                                             AudioBufferList *ioData,
                                             AudioStreamPacketDescription **outDataPacketDescription,
                                             void *inUserData)
{
    ioData->mBuffers[0].mData = inUserData;
    ioData->mBuffers[0].mNumberChannels = 1;
    ioData->mBuffers[0].mDataByteSize = 1024*2;
    *ioNumberDataPackets = 1024;
    return 0;
}
static void CheckError(OSStatus error,const char *operaton){
    if (error==noErr) {
        return;
    }
    char errorString[20]={};
    *(UInt32 *)(errorString+1)=CFSwapInt32HostToBig(error);
    if (isprint(errorString[1])&&isprint(errorString[2])&&isprint(errorString[3])&&isprint(errorString[4])) {
        errorString[0]=errorString[5]='\'';
        errorString[6]='\0';
    }else{
        sprintf(errorString, "%d",(int)error);
    }
    fprintf(stderr, "Error:%s (%s)\n",operaton,errorString);
    exit(1);
}

static void fillBufCallback(void *inUserData,
                           AudioQueueRef inAQ,
                           AudioQueueBufferRef buffer){
    VoiceConvertHandle *THIS=(__bridge VoiceConvertHandle*)inUserData;
    
    for (int i = 0; i < THIS->_buffers.count; ++i) {
        if (buffer == [THIS->_buffers[i] buffer]) {
            pthread_mutex_lock(&buffLock);
            [THIS->_reusableBuffers addObject:THIS->_buffers[i]];
            pthread_mutex_unlock(&buffLock);
            pthread_cond_signal(&buffcond);
            break;
        }
    }
    
}



#pragma mark - mutex
- (void)_mutexInit
{
    pthread_mutex_init(&buffLock, NULL);
    pthread_cond_init(&buffcond, NULL);
}

- (void)_mutexDestory
{
    pthread_mutex_destroy(&buffLock);
    pthread_cond_destroy(&buffcond);
}

- (void)_mutexWait
{
    pthread_mutex_lock(&buffLock);
    pthread_cond_wait(&buffcond, &buffLock);
    pthread_mutex_unlock(&buffLock);
}

- (void)_mutexSignal
{
    pthread_mutex_lock(&buffLock);
    pthread_mutex_unlock(&buffLock);
    pthread_cond_signal(&buffcond);
}

@end
