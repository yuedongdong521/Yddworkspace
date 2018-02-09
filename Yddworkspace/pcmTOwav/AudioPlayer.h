//
//  AudioPlayer.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/10.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface AudioPlayer : NSObject

@property (nonatomic, readonly) NSString *currentPath;

- (instancetype)initAudioPlayerWithAudioPath:(NSURL *)audioURL;

- (void)startPlay;

- (void)stopPlay;

@end
