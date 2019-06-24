//
//  TimeTools.m
//  Yddworkspace
//
//  Created by ydd on 2019/5/15.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TimeTools.h"

static NSMutableDictionary *_dateFormatterDic;

@implementation TimeTools

+ (NSString *)timeWithStyle:(NSString *)style date:(NSDate *)date
{
    if (!style) {
        style = @"yyyy-MM-dd HH:mm:ss";
    }
    if (!_dateFormatterDic) {
        _dateFormatterDic = [NSMutableDictionary dictionary];
    }
    id formatter = [_dateFormatterDic objectForKey:style];
    if (formatter && [formatter isKindOfClass:[NSDateFormatter class]]) {
       return [((NSDateFormatter *)formatter) stringFromDate:date];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:style];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    if (![dateFormatter.timeZone.name isEqualToString:timeZone.name]) {
        dateFormatter.timeZone = timeZone;
    }
    if (dateFormatter) {
        [_dateFormatterDic setObject:dateFormatter forKey:style];
    }
    return [dateFormatter stringFromDate:date];
    
}

+ (NSString *)timeWithStyle:(NSString *)style timeStamp:(NSUInteger)timeStamp
{
    return [self timeWithStyle:style date:[NSDate dateWithTimeIntervalSince1970:timeStamp]];
}

+ (NSUInteger)timeStampSincel1970
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    return [date timeIntervalSince1970];
}

+ (NSDate *)localeDateWithTimeStamp:(NSUInteger)timeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}

@end
