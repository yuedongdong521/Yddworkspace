//
//  AudioQueueRecorder.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/23.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AudioQueueRecorderDelegate <NSObject>

- (void)recorderData:(NSData *)data;

@end

@interface AudioQueueRecorder : NSObject

@property(nonatomic, weak) id<AudioQueueRecorderDelegate>delegate;

//开始录音
- (void)startRecording;

//停止录音
- (void)stopRecording;
@end
