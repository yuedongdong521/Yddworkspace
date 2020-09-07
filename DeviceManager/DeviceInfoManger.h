//
//  DeviceInfoManger.h
//  Demo
//
//  Created by ydd on 2019/11/5.
//  Copyright © 2019年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfoManger : NSObject

//设备名
@property(nonatomic,copy)NSString *deviceName;
//系统名称
@property(nonatomic,copy)NSString *systemName;
//app版本
@property(nonatomic,copy)NSString *appVersion;
//电池电量
@property(nonatomic,copy)NSString *batteryLevel;
//iPhone名
@property(nonatomic,copy)NSString *iPhoneName;
//系统版本
@property(nonatomic,copy)NSString *systemVersion;
//uuid
@property(nonatomic,copy)NSString *strUuid;
//IP
@property(nonatomic,copy)NSString *ipAddress;
//ipv4
@property (nonatomic,copy) NSString *ipv4Address;
//idfa
@property(nonatomic,copy)NSString *idfa;
//idfv
@property(nonatomic,copy)NSString *idfv;
//macAddress
@property(nonatomic,copy)NSString *macAddress;

@property (nonatomic,copy)NSString *dns;

+ (instancetype)manger;

- (double)availableMemory;
- (NSString *) getDeviceString;
    // 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory;

// deviceStr可以传nil
- (BOOL)ipohne6PlusAndbelowWithDeviceStr:(NSString *)deviceStr;
- (BOOL)ipohne6sPlusAndbelowWithDeviceStr:(NSString *)deviceStr; // 包含iphoneSE
- (BOOL)ipohne7PlusAndbelowWithDeviceStr:(NSString *)deviceStr;

// 获取设备型号
- (NSString *)getDeviceName;

@end
