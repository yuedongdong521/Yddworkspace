//
//  Record.h
//  Yddworkspace
//
//  Created by ydd on 2018/11/30.
//  Copyright © 2018 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AudioConstant.h"


NS_ASSUME_NONNULL_BEGIN

// use Audio Queue
typedef struct AQCallbackStruct
{
  AudioStreamBasicDescription mDataFormat;
  AudioQueueRef               queue;
  AudioQueueBufferRef         mBuffers[kNumberBuffers];
  AudioFileID                 outputFile;
  
  unsigned long               frameSize;
  long long                   recPtr;
  int                         run;
  
} AQCallbackStruct;





@interface Record : NSObject
{
  AQCallbackStruct aqc;
  AudioFileTypeID fileFormat;
  long audioDataLength;
  Byte audioByte[999999];
  long audioDataIndex;
}

- (id) init;
- (void) start;
- (void) stop;
- (void) pause;
- (Byte *) getBytes;
- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue;

@property (nonatomic, assign) AQCallbackStruct aqc;
@property (nonatomic, assign) long audioDataLength;

@end

NS_ASSUME_NONNULL_END
