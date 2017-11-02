//
//  PKColorConversion.h
//  DevelopPlayerDemo
//
//  Created by jiangxincai on 16/1/11.
//  Copyright © 2016年 pepsikirk. All rights reserved.
//

#ifndef PKColorConversion_h
#define PKColorConversion_h

#import "GPUImageContextYDD.h"

extern GLfloat *kColorConversionYDD601;
extern GLfloat *kColorConversion601FullRangeYDD;
extern GLfloat *kColorConversionYDD709;
extern NSString *const kGPUImageVertexShaderStr;
extern NSString *const kGPUImageYUVFullRangeConversionForLAFragmentShaderStr;
extern NSString *const kGPUImagePassthroughFragmentShaderStr;

#endif /* PKColorConversion_h */
