//
//  YDDpcmTOwav.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/9.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface YDDpcmTOwav : NSObject

- (int)convertPcmToWavWithPCMPath:(NSString*)pcmPath
                          WAVPath:(NSString*)wavPath
                         Channels:(int)channel
                      Sample_rate:(int)sample_rate;

@end
