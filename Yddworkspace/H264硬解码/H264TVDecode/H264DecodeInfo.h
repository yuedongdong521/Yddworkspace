//
//  H264DecodeInfo.h
//  ViewsTalk
//
//  Created by ydd on 2018/9/11.
//  Copyright © 2018年 ywx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface H264DecodeInfo : NSObject

+ (void)decode_emulation_prevention:(unsigned char *)buf lenght:(unsigned int*)lenght;

+ (BOOL)decodeSpsBuf:(unsigned char*)buf spsLenght:(unsigned int)lenght width:(int*)width height:(int*)height fps:(int*)fps;

@end
