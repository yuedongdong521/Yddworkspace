//
//  AudioRecorder.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/10.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@protocol AudioRecorderDelegate<NSObject>

- (void)recordFinishAudioPath:(NSString *)path;

@end

@interface AudioRecorder : NSObject

@property (nonatomic, weak) id <AudioRecorderDelegate>delegate;

+ (AudioRecorder *)shareAudioRecorder;

- (BOOL)startRecord;

- (void)stopRecord;

@end
