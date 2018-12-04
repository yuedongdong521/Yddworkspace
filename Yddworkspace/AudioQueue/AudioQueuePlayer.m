//
//  AudioQueuePlayer.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/23.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "AudioQueuePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define MIN_SIZE_PER_FRAME 1920 //每个包的大小,室内机要求为960,具体看下面的配置信息
#define QUEUE_BUFFER_SIZE 3   //缓冲器个数
#define SAMPLE_RATE    16000 //采样频率




@interface AudioQueuePlayer()
{
    AudioQueueRef audioQueue;                 //音频播放队列
    AudioStreamBasicDescription _audioDescription;
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE]; //音频缓存
    BOOL audioQueueBufferUsed[QUEUE_BUFFER_SIZE];       //判断音频缓存是否在使用
    NSLock *sysnLock;
    NSMutableData *tempData;
    OSStatus osState;
}

@property(nonatomic, strong) NSMutableArray *audioDataArr;

@property(nonatomic, strong) NSTimer *timer;

- (void)audioQueueIsRuningStatue:(AudioQueueRef)queueRef queueId:(AudioQueuePropertyID)outId;
- (void)resetBufferState:(AudioQueueRef)audioQueueRef and:(AudioQueueBufferRef)audioQueueBufferRef;

@end

// ************************** 回调 **********************************
// 回调回来把buffer状态设为未使用
static void AudioPlayerAQInputCallback(void* inUserData,AudioQueueRef audioQueueRef, AudioQueueBufferRef audioQueueBufferRef) {
  
  AudioQueuePlayer* audio = (__bridge AudioQueuePlayer*)inUserData;
  
  [audio resetBufferState:audioQueueRef and:audioQueueBufferRef];
}

static void AudioQueueIsRuningCallback(void* outUserData, AudioQueueRef outAQRef, AudioQueuePropertyID outId) {
  AudioQueuePlayer* player = (__bridge AudioQueuePlayer*)outUserData;
  [player audioQueueIsRuningStatue:outAQRef queueId:outId];
}


@implementation AudioQueuePlayer

#pragma mark - 提前设置AVAudioSessionCategoryMultiRoute 播放和录音
+ (void)initialize
{
    NSError *error = nil;
    //只想要播放:AVAudioSessionCategoryPlayback
    //只想要录音:AVAudioSessionCategoryRecord
    //想要"播放和录音"同时进行 必须设置为:AVAudioSessionCategoryMultiRoute 而不是AVAudioSessionCategoryPlayAndRecord(设置这个不好使)
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryMultiRoute error:&error];
    if (!ret) {
        NSLog(@"设置声音环境失败");
        return;
    }
    //启用audio session
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (!ret)
    {
        NSLog(@"启动失败");
        return;
    }
}


- (void)startPlay
{
  if (audioQueue) {
    OSStatus error = AudioQueueStart(audioQueue, NULL);
    
    NSLog(@"AudioQueueStart error = %d", (int)error);
  }
}

- (void)receiveAudioData:(NSData *)data
{
  @synchronized(self) {
    [_audioDataArr addObject:data];
//    while (true) {
//      if (_audioDataArr.count > 0) {
//        NSData *audioData = _audioDataArr.firstObject;
//        [self playWithData:_audioDataArr.firstObject];
//        [_audioDataArr removeObject:audioData];
//      } else {
//        //      break;
//      }
//    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [self startTimer];
    });
    
  }
}

- (void)startTimer
{
  if (!_timer) {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
      if (_audioDataArr.count > 0) {
        NSData *audioData = _audioDataArr.firstObject;
        [NSThread detachNewThreadSelector:@selector(playWithData:) toTarget:self withObject:audioData];
        //        [self playWithData:_audioDataArr.firstObject];
        //        [_audioDataArr removeObject:audioData];
      } else {
        //      break;
      }
    }];
  }
}

- (void)resetPlay
{
    if (audioQueue != nil) {
        AudioQueueReset(audioQueue);
      
    }
  [_audioDataArr removeAllObjects];
}

- (void)stop
{
    if (audioQueue != nil) {
        AudioQueueStop(audioQueue,true);
    }
  
  [_audioDataArr removeAllObjects];
    audioQueue = nil;
    sysnLock = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        sysnLock = [[NSLock alloc]init];
        
        //设置音频参数 具体的信息需要问后台
        _audioDescription.mSampleRate = SAMPLE_RATE;
        _audioDescription.mFormatID = kAudioFormatLinearPCM;
        _audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        //1单声道
        _audioDescription.mChannelsPerFrame = 1;
        //每一个packet一侦数据,每个数据包下的桢数，即每个数据包里面有多少桢
        _audioDescription.mFramesPerPacket = 1;
        //每个采样点16bit量化 语音每采样点占用位数
        _audioDescription.mBitsPerChannel = 16;
        _audioDescription.mBytesPerFrame = (_audioDescription.mBitsPerChannel / 8) * _audioDescription.mChannelsPerFrame;
        //每个数据包的bytes总数，每桢的bytes数*每个数据包的桢数
        _audioDescription.mBytesPerPacket = _audioDescription.mBytesPerFrame * _audioDescription.mFramesPerPacket;
        
        // 创建音频队列 使用player的内部线程播放 新建输出
      OSStatus error;
      error = AudioQueueNewOutput(&_audioDescription, AudioPlayerAQInputCallback, (__bridge void * _Nullable)(self), nil, 0, 0, &audioQueue);
      if (error) {
        NSLog(@"AudioQueueNewOutput error = %d", (int)error);
      }
      // 监听播放状态
      error = AudioQueueAddPropertyListener(audioQueue, kAudioQueueProperty_IsRunning, AudioQueueIsRuningCallback, (__bridge void* _Nullable)(self));
      if (error) {
        NSLog(@"AudioQueueAddPropertyListener error = %d", (int)error);
      }
      
        
        // 设置音量
        AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);
        
        // 初始化需要的缓冲区
        for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
            audioQueueBufferUsed[i] = false;
            osState = AudioQueueAllocateBuffer(audioQueue, MIN_SIZE_PER_FRAME, &audioQueueBuffers[i]);
        }
        
      
        if (osState != noErr) {
            NSLog(@"AudioQueueStart Error");
        }
      
      _audioDataArr = [NSMutableArray array];
    }
    return self;
}


// 播放数据
-(void)playWithData:(NSData *)data
{
    [sysnLock lock];
  
    tempData = [NSMutableData new];
    [tempData appendData: data];
    NSUInteger len = tempData.length;
    Byte *bytes = (Byte*)malloc(len);
    [tempData getBytes:bytes length: len];
    
    int i = 0;
    while (true) {
        if (!audioQueueBufferUsed[i]) {
            audioQueueBufferUsed[i] = true;
            break;
        }else {
            i++;
            if (i >= QUEUE_BUFFER_SIZE) {
                i = 0;
            }
        }
    }
  
    audioQueueBuffers[i] -> mAudioDataByteSize = (unsigned int)len;
    // 把bytes的头地址开始的len字节给mAudioData,向第i个缓冲器
    memcpy(audioQueueBuffers[i] -> mAudioData, bytes, len);
    
    // 释放对象
    free(bytes);
    
    //将第i个缓冲器放到队列中,剩下的都交给系统了
    AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffers[i], 0, NULL);
  [_audioDataArr removeObject:data];
    [sysnLock unlock];
}


- (void)audioQueueIsRuningStatue:(AudioQueueRef)queueRef queueId:(AudioQueuePropertyID)outId
{
   NSLog(@"音频队列状态改变 %u", (unsigned int)outId);
}

- (void)resetBufferState:(AudioQueueRef)audioQueueRef and:(AudioQueueBufferRef)audioQueueBufferRef {
    // 防止空数据让audioqueue后续都不播放,为了安全防护一下
    if (tempData.length == 0) {
        audioQueueBufferRef->mAudioDataByteSize = 1;
        Byte* byte = audioQueueBufferRef->mAudioData;
        byte = 0;
        AudioQueueEnqueueBuffer(audioQueueRef, audioQueueBufferRef, 0, NULL);
    }
  
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        // 将这个buffer设为未使用
        if (audioQueueBufferRef == audioQueueBuffers[i]) {
            audioQueueBufferUsed[i] = false;
        }
    }
}

- (void)dealloc {
  
  if (audioQueue != nil) {
    AudioQueueStop(audioQueue,true);
  }
  
  audioQueue = nil;
  sysnLock = nil;
}

@end
