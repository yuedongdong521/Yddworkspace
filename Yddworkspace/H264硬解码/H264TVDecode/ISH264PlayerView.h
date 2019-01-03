//
//  ISH264PlayerView.h
//  ViewsTalk
//
//  Created by ispeak on 2018/1/17.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISH264Player.h"
#import "ISPlayerLoadingView.h"

@protocol ISH264PlayerViewDelegate <NSObject>

- (void)quiteFullScreen;

@end

@interface ISH264PlayerView : UIView

@property(nonatomic, weak) id<ISH264PlayerViewDelegate> delegate;

@property(nonatomic, strong) ISPlayerLoadingView* loadingView;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setVideoContentModel:(ISVideoContentModel)model;

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

/** 显示视频加载画面 */
- (void)showLoadingView:(NSString*)tipStr animation:(BOOL)animation;
/** 影藏视频加载画面 */
- (void)hiddenLoadingView;

- (void)fullButtonAction:(UIButton*)btn;

@end
