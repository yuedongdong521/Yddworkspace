//
//  AppCrashManager.m
//  Yddworkspace
//
//  Created by ydd on 2019/5/15.
//  Copyright © 2019 QH. All rights reserved.
//

#import "AppCrashManager.h"
#include <execinfo.h>

static AppCrashManager *_crashManager;

@interface AppCrashManager ()

@property (nonatomic, copy) NSString *logPath;
@property (nonatomic, copy) NSString *crashPath;

@end

@implementation AppCrashManager


static void printLastSelectorName(NSString *crashStackString)
{
    // print registers
    NSLog(@"*** print registers begin. ***");
    
    if (crashStackString.length > 0 && ([crashStackString rangeOfString:@"objc_msgSend"].location != NSNotFound)) {
        
        NSLog(@"*** have found objc_msgSend. ***");
        
        NSString *r1Flag = @"r1: 0x";
        NSString *x1Flag = @"x1: 0x";
        NSRange rangeContainsR1Reg = [crashStackString rangeOfString:r1Flag];
        NSRange rangeContainsX1Reg = [crashStackString rangeOfString:x1Flag];
        
        NSString *valOfR1X1 = nil;
        
        @try {
            if ((rangeContainsR1Reg.location != NSNotFound) && (crashStackString.length >= rangeContainsR1Reg.location + r1Flag.length + 8)) { // 32-bit
                valOfR1X1 = [crashStackString substringWithRange:NSMakeRange(rangeContainsR1Reg.location + r1Flag.length, 8)];
            }
            else if ((rangeContainsX1Reg.location != NSNotFound) && (crashStackString.length >= rangeContainsX1Reg.location + x1Flag.length + 16)) { // 64-bit
                valOfR1X1 = [crashStackString substringWithRange:NSMakeRange(rangeContainsX1Reg.location + x1Flag.length, 16)];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"*** exception: %@", exception);
        }
        
        if (valOfR1X1.length > 0) {
            unsigned long val = strtoul([[valOfR1X1 substringWithRange:NSMakeRange(0, valOfR1X1.length)] UTF8String], 0, 16);
            if (val != 0 && val != ULONG_MAX) {
                
                NSLog(@"*** r1(x1) val = %lx", val);
                NSLog(@"*** r1(x1): %@", NSStringFromSelector((SEL)val));
            }
        }
    }

    NSLog(@"*** print registers end. ***");
}

void CrashExceptionHandler(NSException *exception){
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    //TODO: 保存奔溃信息到本地，下次启动的时候上传到服务器
    [callStack componentsJoinedByString:@"\n"];
}

void SignalExceptionHandler(int signal){
    NSArray *callStack = [AppCrashManager backtrace];
    NSLog(@"信号捕获崩溃，堆栈信息：%@",callStack);
    NSString *name = @"LMSignalException";
    NSString *reason = [NSString stringWithFormat:@"signal %d was raised",signal];
    //TODO: 保存信息上传到本地
    [callStack componentsJoinedByString:@"\n"];
}

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

+ (void)resginCrashCatchMethod
{
    NSSetUncaughtExceptionHandler(&CrashExceptionHandler);
    
    signal(SIGABRT, SignalExceptionHandler);
    signal(SIGILL, SignalExceptionHandler);
    signal(SIGSEGV, SignalExceptionHandler);
    signal(SIGFPE, SignalExceptionHandler);
    signal(SIGBUS, SignalExceptionHandler);
    signal(SIGPIPE, SignalExceptionHandler);
}

+ (void)writeCrashInfo:(NSString *)info
{
    if (info && info.length > 0) {
        info = [self packageInfo:info];
        NSError *error;
        [info writeToFile:[self shareCrashManager].crashPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

+ (void)writeLogInfo:(NSString *)info
{
     if (info && info.length > 0) {
         info = [self packageInfo:info];
         NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[self shareCrashManager].logPath];
         [fileHandle seekToEndOfFile];
         NSData *data = [info dataUsingEncoding:NSUTF8StringEncoding];
         [fileHandle writeData:data];
         [fileHandle closeFile];
     }
}

+ (NSString *)packageInfo:(NSString *)info
{
    if (!info) {
        return info;
    }
    return [NSString stringWithFormat:@"\n %@   %@", [NSDate dateWithTimeIntervalSinceNow:28800], info];
}


+ (AppCrashManager *)shareCrashManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _crashManager = [[AppCrashManager alloc] init];
    });
    return _crashManager;
}


- (NSString *)logPath
{
    if (!_logPath) {
        NSString *path = [self getAppLogDirectory];
        _logPath = [path stringByAppendingPathComponent:@"log.txt"];
    }
    return _logPath;
}

- (NSString *)crashPath
{
    if (!_crashPath) {
         NSString *path = [self getAppLogDirectory];
        _crashPath = [path stringByAppendingPathComponent:@"crash.txt"];

    }
    return _crashPath;
}


- (NSString *)getAppLogDirectory
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    path = [path stringByAppendingPathComponent:@"applog"];
    BOOL isDir;
    BOOL isExis = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (!isDir || !isExis) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}





@end
