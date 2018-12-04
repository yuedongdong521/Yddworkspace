//
//  Record.m
//  Yddworkspace
//
//  Created by ydd on 2018/11/30.
//  Copyright © 2018 QH. All rights reserved.
//

#import "Record.h"

@implementation Record

@synthesize aqc;
@synthesize audioDataLength;

static void AQInputCallback (void                   * inUserData,
                             AudioQueueRef          inAudioQueue,
                             AudioQueueBufferRef    inBuffer,
                             const AudioTimeStamp   * inStartTime,
                             unsigned long          inNumPackets,
                             const AudioStreamPacketDescription * inPacketDesc)
{
  
  Record * engine = (__bridge Record *) inUserData;
  if (inNumPackets > 0)
  {
    [engine processAudioBuffer:inBuffer withQueue:inAudioQueue];
  }
  
  if (engine.aqc.run)
  {
    AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
  }
}

- (id) init
{
  self = [super init];
  if (self)
  {
    aqc.mDataFormat.mSampleRate = kSamplingRate;
    aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
    aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger |kLinearPCMFormatFlagIsPacked;
    aqc.mDataFormat.mFramesPerPacket = 1;
    aqc.mDataFormat.mChannelsPerFrame = kNumberChannels;
    aqc.mDataFormat.mBitsPerChannel = kBitsPerChannels;
    aqc.mDataFormat.mBytesPerPacket = kBytesPerFrame;
    aqc.mDataFormat.mBytesPerFrame = kBytesPerFrame;
    aqc.frameSize = kFrameSize;
    
    AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, (__bridge void *)(self), NULL, kCFRunLoopCommonModes,0, &aqc.queue);
    
    for (int i=0;i<kNumberBuffers;i++)
    {
      AudioQueueAllocateBuffer(aqc.queue, aqc.frameSize, &aqc.mBuffers[i]);
      AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
    }
    aqc.recPtr = 0;
    aqc.run = 1;
  }
  audioDataIndex = 0;
  return self;
}

- (void) dealloc
{
  AudioQueueStop(aqc.queue, true);
  aqc.run = 0;
  AudioQueueDispose(aqc.queue, true);
}

- (void) start
{
  AudioQueueStart(aqc.queue, NULL);
}

- (void) stop
{
  AudioQueueStop(aqc.queue, true);
}

- (void) pause
{
  AudioQueuePause(aqc.queue);
}

- (Byte *)getBytes
{
  return audioByte;
}

- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
{
  NSLog(@"processAudioData :%ld", buffer->mAudioDataByteSize);
  //处理data：忘记oc怎么copy内存了，于是采用的C++代码，记得把类后缀改为.mm。同Play
  memcpy(audioByte+audioDataIndex, buffer->mAudioData, buffer->mAudioDataByteSize);
  audioDataIndex +=buffer->mAudioDataByteSize;
  audioDataLength = audioDataIndex;
}


@end
