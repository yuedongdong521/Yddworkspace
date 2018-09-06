//
//  ISH264Player.h
//  ViewsTalk
//
//  Created by ispeak on 2018/1/17.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef enum : NSUInteger {
  ISVideoContentModelScaleAspectFit = 0,
  ISVideoContentModelScaleAspectFull,
} ISVideoContentModel; // 视频画面填充方式

@interface ISH264Player : CAEAGLLayer

@property CVPixelBufferRef pixelBuffer;

@property(nonatomic, assign) ISVideoContentModel videoModel;

- (id)initWithFrame:(CGRect)frame;

- (void)playerForPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (void)resetRenderBuffer;

- (void)clearFrame;

- (void)playGlFinish;

@end
