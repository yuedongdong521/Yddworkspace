//
//  TimeTools.h
//  Yddworkspace
//
//  Created by ydd on 2019/5/15.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeTools : NSObject

+ (NSString *)timeWithStyle:(NSString *)style date:(NSDate *)date;
+ (NSString *)timeWithStyle:(NSString *)style timeStamp:(NSUInteger)timeStamp;
+ (NSUInteger)timeStampSincel1970;


@end

NS_ASSUME_NONNULL_END
