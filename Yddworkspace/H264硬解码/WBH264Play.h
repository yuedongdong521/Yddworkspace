//
//  WBH264Play.h
//  IjkTest
//
//  Created by yf on 2017/10/18.
//  Copyright © 2017年 oceanwing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IWBH264HwDecoderDelegate<NSObject>
-(void)displayDecodedFrame:(uint)uid imageBuffer:(CVPixelBufferRef)buffer;

@end

@interface H264HwDecoder : NSObject
@property (nonatomic,assign)id<IWBH264HwDecoderDelegate> delegate;

- (BOOL)open:(id<IWBH264HwDecoderDelegate>)displayDelegate width:(uint16_t)width height:(uint16_t)height ;
- (BOOL)decodeNalu:(uint8_t *)frame withSize:(uint32_t)frameSize ;
@end




