//
//  AudioQueuePlayer.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/23.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioQueuePlayer : NSObject

- (void)playWithData:(NSData *)data;

- (void)resetPlay;

- (void)stop;

@end
