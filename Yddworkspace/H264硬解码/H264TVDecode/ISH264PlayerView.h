//
//  ISH264PlayerView.h
//  ViewsTalk
//
//  Created by ispeak on 2018/1/17.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ISH264PlayerViewDelegate <NSObject>

- (void)quiteFullScreen;

@end

@interface ISH264PlayerView : UIView

@property(nonatomic, weak) id<ISH264PlayerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
/**
 播放每帧数据
 */
- (void)playForPixelBuffer:(CVPixelBufferRef)buffer;
/**
 重置播放器
 */
- (void)resetPlay;

- (void)changePlayerFrameForFullScreen:(BOOL)isFull;

- (void)clearBuff;

- (void)appEnterBackgroundGlFinish;

@end
