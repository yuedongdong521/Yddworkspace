//
//  AudioQueueRecorder.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/23.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioQueueRecorder : NSObject
//开始录音
- (void)startRecording;

//停止录音
- (void)stopRecording;
@end
