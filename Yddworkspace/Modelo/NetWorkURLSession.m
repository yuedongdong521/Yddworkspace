//
//  NetWorkURLSession.m
//  Yddworkspace
//
//  Created by lwj on 2018/5/17.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "NetWorkURLSession.h"

@interface NetWorkURLSession()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>
{
  NSURLSession *_session;
  NSURLSessionDownloadTask *_downloadTask;
  NSString *_savePath;
  
}

@property (nonatomic, copy) CompleteProgress completeProgress;
@property (nonatomic, copy) Finish downloadFinish;

@end

@implementation NetWorkURLSession

- (instancetype)init
{
  self = [super init];
  if (self) {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
  }
  return self;
}

- (void)downLoad:(NSURL *)url savePath:(NSString *)savePath completeProgress:(CompleteProgress)progress finish:(Finish)finish
{
  _completeProgress = progress;
  _downloadFinish = finish;
  _savePath = savePath;
  _downloadTask = [_session downloadTaskWithURL:url];
  [_downloadTask resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
  [session invalidateAndCancel];
  if (error.code != 0) {
    if (_downloadFinish) {
      _downloadFinish(error);
    }
  }
  _downloadFinish = nil;
  _completeProgress = nil;
  
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  BOOL isExe = [fileManager fileExistsAtPath:_savePath];
  if (isExe) {
    [fileManager removeItemAtPath:_savePath error:nil];
  }
  NSError *error = nil;
  [fileManager moveItemAtPath:location.path toPath:_savePath error:&error];
  if (_downloadFinish) {
    _downloadFinish(error);
    _downloadFinish = nil;
    _completeProgress = nil;
  }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
  
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
  double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
  if (_completeProgress) {
    _completeProgress(progress);
  }
}

- (void)cancelDownload
{
  [_downloadTask cancel];
  _downloadFinish = nil;
  _completeProgress = nil;
}

- (void)dealloc
{
  NSLog(@"networkurlSession dealloc");
}

@end
