//
//  VideoFilter.h
//  Yddworkspace
//
//  Created by ydd on 2019/1/14.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoFilter : NSObject
+(CVPixelBufferRef)addFilterForPixelbuffer:(CVPixelBufferRef)pixelbuffer;
+ (void)lookupFilter;
@end

NS_ASSUME_NONNULL_END
