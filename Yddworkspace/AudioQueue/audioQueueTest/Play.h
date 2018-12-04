//
//  Play.h
//  AudioTest
//
//  Created by webseat2 on 13-10-22.
//  Copyright (c) 2013年 WebSeat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AudioConstant.h"

@interface Play : NSObject
{
    //音频参数
    AudioStreamBasicDescription audioDescription;
    // 音频播放队列
    AudioQueueRef audioQueue;
    // 音频缓存
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE];
}

-(void)Play:(Byte *)audioByte Length:(long)len;

@end
