//
//  PKChatMessagePlayerView.h
//  GPUCameraTest
//
//  Created by ispeak on 2017/12/28.
//  Copyright © 2017年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKChatMessagePlayerView : UIView

@property(nonatomic, assign) BOOL isPlaying;

- (instancetype)initWithFrame:(CGRect)frame
                    videoPath:(NSString*)videoPath
                      videoId:(NSInteger)videoId;

- (void)play;

- (void)stop;

@end
