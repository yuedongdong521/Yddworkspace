//
//  FileManager.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/22.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    DiskSpaceUnit_Bytes = 1,
    DiskSpaceUnit_KB = 1024,
    DiskSpaceUnit_M = 1024 * 1024,
} DiskSpaceUnit;

@interface FileManager : NSObject


+ (NSString *)freeDiskSpaceInBytes;

+ (NSUInteger)getFreeDiskSpaceForUnit:(DiskSpaceUnit)unit;

+ (NSUInteger)getTotalDiskSpaceForUnit:(DiskSpaceUnit)unit;


+ (NSUInteger)getFileSizeForPath:(NSString *)path;

+ (NSString *)createDocumentFilePathWithDire:(NSString *)dire name:(NSString *)name;

+ (BOOL)addFileDataWithPath:(NSString *)path data:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
