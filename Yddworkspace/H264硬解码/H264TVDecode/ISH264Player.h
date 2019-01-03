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
} ISVideoContentModel;

@interface ISH264Player : CAEAGLLayer

@property CVPixelBufferRef pixelBuffer;

@property(nonatomic, assign) ISVideoContentModel videoModel;

- (id)initWithFrame:(CGRect)frame;

- (void)playerForPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)playForYUVData:(const unsigned char*)data width:(size_t)width height:(size_t)height;

- (void)resetRenderBuffer;

- (void)clearFrame;

- (void)playGlFinish;

@end
