//
//  FileManager.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/22.
//  Copyright © 2019 QH. All rights reserved.
//

#import "FileManager.h"
#include <sys/param.h>
#include <sys/mount.h>

@implementation FileManager

+ (NSFileManager *)fileManager
{
    return [NSFileManager defaultManager];
}

+ (NSString *)freeDiskSpaceInBytes {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    NSString *str = [NSString stringWithFormat:@"手机剩余存储空间为：%0.2lld MB",freeSpace/1024/1024];
    return str;
}

+ (NSUInteger)getFreeDiskSpaceForUnit:(DiskSpaceUnit)unit
{
    CGFloat freesize = 0.0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary)
    {
        NSNumber *free = [dictionary objectForKey:NSFileSystemFreeSize];
        freesize = [free unsignedIntegerValue] * 1.0 / unit;
    } else
    {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return freesize;
}

+ (NSUInteger)getTotalDiskSpaceForUnit:(DiskSpaceUnit)unit
{
    CGFloat totalsize = 0.0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        
        NSNumber *total = [dictionary objectForKey:NSFileSystemSize];
        totalsize = [total unsignedIntegerValue] * 1.0/unit;
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return totalsize;
}

+ (NSUInteger)getFileSizeForPath:(NSString *)path
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    return fileHandle.availableData.length;
}

+ (NSString *)createDocumentFilePathWithDire:(NSString *)dire name:(NSString *)name
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    BOOL isDire = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", path, dire, name];
    BOOL exis = [[self fileManager] fileExistsAtPath:filePath isDirectory:&isDire];
    if (!isDire || !exis) {
        [[self fileManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

+ (BOOL)addFileDataWithPath:(NSString *)path data:(NSData *)data
{
    CGFloat freeSize = [self getFreeDiskSpaceForUnit:DiskSpaceUnit_Bytes];
    if (freeSize < data.length) {
        return NO;
    }
    if (![[self fileManager] fileExistsAtPath:path]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        [fileHandle writeData:data];
        [fileHandle closeFile];
        return YES;
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    //  将节点跳到文件的末尾
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
    return YES;
}


@end
