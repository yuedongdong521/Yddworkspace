//
//  KXAudioServicesPlayer.m
//  KXLive
//
//  Created by ydd on 2020/3/20.
//  Copyright © 2020 ibobei. All rights reserved.
//

#import "KXAudioServicesPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
@implementation KXAudioServicesPlayer

/**
缺陷
 1>长度一般不超过30秒,不需要对播放过程进行控制

 2>不能循环播放，不能暂停

 3>不能播放立体声

 4>不能播放混音
*/

+ (void)playerAudioName:(NSString *)name
{
    SystemSoundID soundId = 0;
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    if (path) {
        AudioServicesCreateSystemSoundID( (__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
    }
    AudioServicesPlayAlertSoundWithCompletion(soundId, ^{
        AudioServicesDisposeSystemSoundID(soundId);
    });
}

@end
