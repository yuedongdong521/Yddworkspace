//
//  YDDUtils.m
//  YDDLive
//
//  Created by ydd on 2019/6/23.
//  Copyright © 2019年 ydd. All rights reserved.
//

#import "YDDUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCellularData.h>
#import "ISAlertController.h"

@implementation YDDUtils

/**
 一定位数的小数 四舍五入

 @param num 原始数据
 @param scale 要保留的小数位数
 @return 小数
 */
+ (NSString *)decimal:(NSString *)num scale:(short)scale
{
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *numResult1 = [NSDecimalNumber decimalNumberWithString:num];
    
    numResult1 = [numResult1 decimalNumberByRoundingAccordingToBehavior:behavior];
    
    return [NSString stringWithFormat:@"%@", numResult1];
}

+ (NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return timeSp;
}

+ (NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+ (NSDate *)NSStringToDate:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}

+ (NSDate *)NSStringToDate:(NSString *)dateString withFormat:(NSString *)formatestr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatestr];
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}

+ (NSString *)NSDateToString:(NSDate *)dateFromString withFormat:(NSString *)formatestr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatestr];
    NSString *strDate = [dateFormatter stringFromDate:dateFromString];
    return strDate;
}



+ (id) getObjectFromJsonString:(NSString *)jsonString
{
    NSError *error = nil;
    if (jsonString) {
        id rev=[NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUnicodeStringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if (error==nil) {
            return rev;
        } else {
            return nil;
        }
    }
    return nil;
}

+ (NSString *)getJsonStringFromObject:(id)object
{
    if ([NSJSONSerialization isValidJSONObject:object]){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
        return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (void)setBool:(BOOL)boolValue key:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:boolValue forKey:key];
    [defaults synchronize];
}

+ (BOOL)boolForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL boolValue=[defaults boolForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return boolValue;
}

+ (void)setDouble:(double)doubleValue key:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:doubleValue forKey:key];
    [defaults synchronize];
}

+ (double)doubleForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat doubleValue=[defaults doubleForKey:key];
    return doubleValue;
}

+ (BOOL)isInputRuleNotBlank:(NSString *)str
{
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    // 这里是后期补充的内容:九宫格判断
    if (!isMatch) {
        NSString *other = @"➋➌➍➎➏➐➑➒";
        unsigned long len=str.length;
        for(int i=0;i<len;i++)
        {
            unichar a=[str characterAtIndex:i];
            if(!((isalpha(a))
                 ||(isalnum(a))
                 ||((a >= 0x4e00 && a <= 0x9fa6))
                 ||([other rangeOfString:str].location != NSNotFound)
                 ))
                return NO;
        }
        return YES;
        
    }
    return isMatch;
}

+ (BOOL)isNineKeyBoard:(NSString *)string
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}


+ (BOOL)hasThreadEmoji:(NSString*)string
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

+ (BOOL)hasSysEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}


// 字符长度计算方法
+ (int)stringLengthContainsEmoji:(NSString *)string {
    __block int lenChar = 0;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         BOOL isEmoji = NO;
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEmoji = YES;
                 }
             }
         }else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEmoji = YES;
             }
         }else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 isEmoji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEmoji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEmoji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEmoji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 isEmoji = YES;
             }
         }
         if (isEmoji) {
             lenChar+=2;
         }
         else
         {
             const char    *cString = [substring UTF8String];
             if (strlen(cString) >= 2)
             {
                 lenChar+=2;
             } else lenChar+=1;
         }
     }];
    return lenChar;
}

+ (NSString *)stringLengthContainsEmoji:(NSString *)string maxLength:(NSInteger)maxLength
{
    int lenChar = [YDDUtils stringLengthContainsEmoji:string];
    if (lenChar > maxLength)
    {
        while (lenChar > maxLength) {
            long toIndex = ([string length]-1);
            if (string.length >= 2) {
                if(([string characterAtIndex:toIndex-1]&0xfc00)==0xd800) toIndex--;
            }
            string = [string substringToIndex:toIndex];
            lenChar = [YDDUtils stringLengthContainsEmoji:string];
        }
    }
    return string;
}

+ (NSString *)cutString:(NSString *)string maxLength:(NSInteger)maxLength
{
    if (string.length == 0) {
        return @"";
    }
    int lenChar = [self stringLengthContainsEmoji:string];
    if (lenChar > maxLength) {
        return [NSString stringWithFormat:@"%@...",[self stringLengthContainsEmoji:string maxLength:maxLength]];
    }
    return string;
}


/**
 *  检查是否为正确手机号码
 *
 *  @param phoneNumber 手机号
 *
 *  @return <#return value description#>
 */
+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber
{
    if (phoneNumber.length != 11)
    {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[0, 1, 6, 7, 8], 18[0-9]
     * 移动号段: 134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
     * 联通号段: 130,131,132,145,155,156,170,171,175,176,185,186
     * 电信号段: 133,149,153,170,173,177,180,181,189
     */
    NSString *MOBILE = @"^1[3456789]\\d{9}";
    //    /**
    //     * 中国移动：China Mobile
    //     * 134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188,198
    //     */
    //    NSString *CM = @"^1(3[4-9]|4[78]|5[0-27-9]|7[08]|8[2-478]|9[8])\\d{8}$";
    //    /**
    //     * 中国联通：China Unicom
    //     * 130,131,132,145,155,156,170,171,175,176,185,186,166
    //     */
    //    NSString *CU = @"^1(3[0-2]|4[056]|5[56]|6[6]|7[0156]|8[56])\\d{8}$";
    //    /**
    //     * 中国电信：China Telecom
    //     * 133,149,153,170,173,177,180,181,189,199
    //     */
    //     NSString *CT = @"^1(3[3]|4[9]|53|7[037]|8[019]|9[9])\\d{8}$";
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    //    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    //    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    //    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if ([regextestmobile evaluateWithObject:phoneNumber] == YES)
        
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/** 是否有麦克风权限 */
+ (BOOL)checkAudioAuth
{
    __block BOOL isAuth = YES;
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
        //第一次询问用户是否进行授权
        NSLog(@"第一次询问用户是否进行授权");
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            NSLog(@"授权granted = %d",granted);
            if (!granted) {
                isAuth = NO;
            }
        }];
        
    } else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {
        // 未授权
        NSLog(@"未授权");
        isAuth = NO;
    } else {
        // 已授权
        NSLog(@"已授权");
        isAuth = YES;
    }
    return isAuth;
}

/** 是否有相机权限 */
+ (BOOL)checkCameraAuth
{
    __block BOOL isAuth = YES;
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
        //第一次询问用户是否进行授权
        NSLog(@"第一次询问用户是否进行授权");
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            NSLog(@"授权granted = %d",granted);
            if (!granted) {
                isAuth = NO;
            }
        }];
    } else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {
        // 未授权
        NSLog(@"未授权");
        isAuth = NO;
    } else {
        // 已授权
        NSLog(@"已授权");
        isAuth = YES;
    }
    return isAuth;
}

+ (void)requestCameraPermission:(void(^)(BOOL grant))permission
{
    NSString *videoType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:videoType completionHandler:^(BOOL granted) {
        if (permission) {
            permission(granted);
        }
    }];
}

+ (void)requestMicPermission:(void(^)(BOOL grant))permission
{
    NSString *videoType = AVMediaTypeAudio;
    [AVCaptureDevice requestAccessForMediaType:videoType completionHandler:^(BOOL granted) {
        if (permission) {
            permission(granted);
        }
    }];
}

/** APP的蜂窝移动网络权限是否被关闭 */
+ (void)checkNetworkAuth
{
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    // 状态发生变化时调用
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState restrictedState) {
        switch (restrictedState) {
            case kCTCellularDataRestrictedStateUnknown:
                NSLog(@"蜂窝移动网络状态：未知");
                break;
            case kCTCellularDataRestricted:
                NSLog(@"蜂窝移动网络状态：关闭");
                [[ISAlertController alertWithTitle:@"已关闭蜂窝移动数据" message:@"您可以在设置中为应用打开蜂窝移动数据" cancelTitle:@"好" otherTitle:@"设置" cancelBlock:nil actionBlock:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }] showInWindow];
                break;
            case kCTCellularDataNotRestricted:
                NSLog(@"蜂窝移动网络状态：开启");
                break;
                
            default:
                break;
        }
    };
}



@end
