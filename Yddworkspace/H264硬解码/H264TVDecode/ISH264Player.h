//
//  ISH264Player.h
//  ViewsTalk
//
//  Created by ispeak on 2018/1/17.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface ISH264Player : CAEAGLLayer

@property CVPixelBufferRef pixelBuffer;

- (id)initWithFrame:(CGRect)frame;

- (void)playerForPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (void)resetRenderBuffer;

- (void)clearFrame;

- (void)playGlFinish;

@end
