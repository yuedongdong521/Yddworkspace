//
//  ISH246TVDecode.h
//  ViewsTalk
//
//  Created by ispeak on 2018/1/17.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ISH264TVDecodeDelegate <NSObject>

- (void)displayDecodedFrameImageBuffer:(CVPixelBufferRef)buffer;

@end

@interface ISH246TVDecode : NSObject

@property(nonatomic, weak) id<ISH264TVDecodeDelegate> delegate;

- (BOOL)open:(id<ISH264TVDecodeDelegate>)displayDelegate
       width:(uint16_t)width
      height:(uint16_t)height;
- (BOOL)decodeNalu:(uint8_t*)frame withSize:(uint32_t)frameSize;

@end
