//
//  YDDUtils.h
//  YDDLive
//
//  Created by ydd on 2019/6/23.
//  Copyright © 2019年 ydd. All rights reserved.
//  通用工具类

#import <Foundation/Foundation.h>

#define kMaxLevel 120
#define kMinLevel 0

@interface YDDUtils : NSObject<UIAlertViewDelegate>

/** 时间转时间戳 */
+ (NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format;
/** 将某个时间戳转化成 时间 */
+ (NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format;

/** NSDate互转NSString */
+ (NSDate *)NSStringToDate:(NSString *)dateString;
+ (NSDate *)NSStringToDate:(NSString *)dateString withFormat:(NSString *)formatestr;
+ (NSString *)NSDateToString:(NSDate *)dateFromString withFormat:(NSString *)formatestr;

/** string->json */
+ (id)getObjectFromJsonString:(NSString *)jsonString;
/** json->string */
+ (NSString *)getJsonStringFromObject:(id)object;
/** 保存bool */
+ (void)setBool:(BOOL)boolValue key:(NSString *)key;
/** 读取bool */
+ (BOOL)boolForKey:(NSString *)key;
/** 保存double */
+ (void)setDouble:(double)doubleValue key:(NSString *)key;
/** 读取double */
+ (double)doubleForKey:(NSString *)key;


/** 字母、数字、中文正则判断（不包括空格）*/
+ (BOOL)isInputRuleNotBlank:(NSString *)str;

/** 判断是不是九宫格 */
+ (BOOL)isNineKeyBoard:(NSString *)string;

/** 限制第三方键盘的emoji */
+ (BOOL)hasThreadEmoji:(NSString*)string;
/** 限制系统键盘自带的emoji */
+ (BOOL)hasSysEmoji:(NSString *)string;

/** 字符长度计算方法 */
+ (int)stringLengthContainsEmoji:(NSString *)string;

/** 字符长度计算方法 */
+ (NSString *)stringLengthContainsEmoji:(NSString *)string maxLength:(NSInteger)maxLength;


/** maxLength为字符数，大于最大长度截取,后面...显示 */
+ (NSString *)cutString:(NSString *)string maxLength:(NSInteger)maxLength;

/**  检查是否为正确手机号码  **/
+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber;

/** 是否有麦克风权限 */
+ (BOOL)checkAudioAuth;

/** 是否有相机权限 */
+ (BOOL)checkCameraAuth;

+ (void)requestCameraPermission:(void(^)(BOOL grant))permission;

+ (void)requestMicPermission:(void(^)(BOOL grant))permission;

/** APP的蜂窝移动网络权限是否被关闭 */
+ (void)checkNetworkAuth;




@end
