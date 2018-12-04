//
//  AudioConstant.h
//  AudioTest
//
//  Created by webseat2 on 13-10-23.
//  Copyright (c) 2013年 WebSeat. All rights reserved.
//

#import <Foundation/Foundation.h>

// Audio Settings
#define kNumberBuffers      3
#define t_sample             SInt16
#define kSamplingRate       20000
#define kNumberChannels     1
#define kBitsPerChannels    (sizeof(t_sample) * 8)
#define kBytesPerFrame      (kNumberChannels * sizeof(t_sample))
//#define kFrameSize          (kSamplingRate * sizeof(t_sample))
#define kFrameSize          1000


#define QUEUE_BUFFER_SIZE  2//队列缓冲个数
#define EVERY_READ_LENGTH  10240 //每次从文件读取的长度
#define MIN_SIZE_PER_FRAME 10240 //每侦最小数据长度
@interface AudioConstant : NSObject

@end
