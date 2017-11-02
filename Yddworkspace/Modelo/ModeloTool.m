//
//  ModeloTool.m
//  Yddworkspace
//
//  Created by ispeak on 2017/7/27.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "ModeloTool.h"

@interface ModeloTool ()<NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *reumeData;

@end

@implementation ModeloTool

/*
单例规则

关于单例，有三个重要的准则需要牢记：

1. 单例必须是唯一的(要不怎么叫单例？) 在程序生命周期中只能存在一个这样的实例。单例的存在使我们可以全局访问状态。例如：
NSNotificationCenter, UIApplication和NSUserDefaults。

2. 为保证单例的唯一性，单例类的初始化方法必须是私有的。这样就可以避免其他对象通过单例类创建额外的实例。

3. 考虑到规则1，为保证在整个程序的生命周期中值有一个实例被创建，单例必须是线程安全的。并发有时候确实挺复杂，简单说来，如果单例的代码不正确，如果有两个线程同时实例化一个单例对象，就可能会创建出两个单例对象。也就是说，必须保证单例的线程安全性，才可以保证其唯一性。通过调用dispatch_once，即可保证实例化代码只运行一次。

在程序中保持单例的唯一性，只初始化一次，这样并不难。帖子的余下部分中，需要记住：单例实现要满足隐藏的dispatch_once规则。
*/

+ (instancetype)sharedModeloTool
{
    static ModeloTool *modelo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modelo = [[ModeloTool alloc] init];
    });
    return modelo;
}

- (NSData *)getRequestBodyDataForParameter:(NSDictionary *)parameter
{
    if (!parameter) {
        return nil;
    }
    NSArray *array = [parameter allKeys];
    NSString *parameterStr = @"";
    for (int i = 0; i < array.count; i++) {
        if (i != 0) {
            parameterStr = [NSString stringWithFormat:@"%@&%@=%@", parameterStr, array[i], [parameter objectForKey:array[i]]];
        } else {
            parameterStr = [NSString stringWithFormat:@"%@=%@", array[i], [parameter objectForKey:array[i]]];
        }
    }
    return [parameterStr dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)urlConnectionnetworkRequestForType:(NSString *)type ForUrl:(NSString *)url ForParameter:(NSDictionary *)parameter ForBackResult:(void(^)(NSDictionary *dic, NSError *error))backResult
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    request.HTTPMethod = type;
    if ([type isEqualToString:@"POST"] && parameter) {
        request.HTTPBody = [self getRequestBodyDataForParameter:parameter];
    }
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data && connectionError == nil) {
            NSError *jserror = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jserror];
            if (result) {
                NSDictionary *dic = (NSDictionary *)result;
                backResult(dic, jserror);
            } else {
                backResult(nil, jserror);
            }
        } else {
            backResult(nil, connectionError);
        }
    }];
}

#pragma mark NSURLSessionTask {

//简单的get请求
- (void)urlSessionGETNewWorkRequestForUrlStr:(NSString *)urlStr ForBackResult:(void(^)(NSDictionary *dic, NSError *error))backResult
{
    //快捷方式获得session对象
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlStr];
    //通过url初始化task， 在block内部可以直接对返回的数据进行处理
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && error == nil) {
            NSError *jserror = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jserror];
            if (result) {
                NSDictionary *dic = (NSDictionary *)result;
                backResult(dic, jserror);
            } else {
                backResult(nil, jserror);
            }
        } else {
            backResult(nil, error);
        }

    }];
    //启动任务
    [task resume];
}

//简单的POST请求
- (void)urlSessionPOSTNetWorkRequestForUrlStr:(NSString *)urlStr ForParameter:(NSDictionary *)parameter ForBackResult:(void(^)(NSDictionary *dic, NSError *error))backResult
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [self getRequestBodyDataForParameter:parameter];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *tast = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && error == nil) {
            NSError *jserror = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jserror];
            if (result) {
                NSDictionary *dic = (NSDictionary *)result;
                backResult(dic, jserror);
            } else {
                backResult(nil, jserror);
            }
        } else {
            backResult(nil, error);
        }

    }];
    [tast resume];
}


#pragma mark NSURLSessionDataDelegate代理方法 {
- (void)urlSessionDelegateNetWorkRequestForUrlStr:(NSString *)urlStr
{
    // 使用代理方法需要设置代理,但是session的delegate属性是只读的,要想设置代理只能通过这种方式创建session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    // 创建任务(因为要使用代理方法,就不需要block方式的初始化了)
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];
}

// 1.接收到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
}

// 2.接收到服务器的数据（可能调用多次）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //处理每次接受的数据
}

// 3.请求成功或者失败（如果失败，error有值）
// 由于下载失败导致的下载中断会进入此协议方法,也可以得到用来恢复的数据
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // 请求完成,成功或者失败的处理
    NSLog(@"请求完成,成功或者失败的处理");
    if (self.session == session) {
        self.reumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    }
}

//关键点在代码注释里面都有提及,重要的地方再强调一下:
//
//如果要使用代理方法,需要设置代理,但从NSURLSession的头文件发现session的delegate属性是只读的.因此设置代理要通过session的初始化方法赋值:sessionWithConfiguration:delegate:delegateQueue:其中:
//configuration参数(文章开始提到的)需要传递一个配置,我们暂且使用默认的配置[NSURLSessionConfiguration defaultSessionConfiguration]就好(后面会说下这个配置是干嘛用的);
//delegateQueue参数表示协议方法将会在哪个队列(NSOperationQueue)里面执行.
//NSURLSession在接收到响应的时候要先对响应做允许处理:completionHandler(NSURLSessionResponseAllow);,才会继续接收服务器返回的数据,进入后面的代理方法.值得一提的是,如果在接收响应的时候需要对返回的参数进行处理(如获取响应头信息等),那么这些处理应该放在前面允许操作的前面.
//
//作者：CoderAO
//链接：http://www.jianshu.com/p/fafc67475c73
//來源：简书
//著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

#pragma mark }

#pragma mark NSURLSessionDownloadTask 简单下载

- (void)urlSessionDownload
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://www.daka.com/resources/image/icon.png"] ;
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        // location是沙盒中tmp文件夹下的一个临时url,文件下载后会存到这个位置,由于tmp中的文件随时可能被删除,所以我们需要自己需要把下载的文件挪到需要的地方
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        // 剪切文件
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:nil];
    }];
    // 启动任务
    [task resume];

}

#pragma mark NSURLSessionDownloadDelegate 下载 {
//通过NSURLSessionDownloadDelegate代理方式下载

- (void)urlSessionDownloadDelegateForUrlStr:(NSString *)urlStr
{
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    _reumeData = [NSData new];
    _downloadTask = [_session downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30]];
    [_downloadTask resume];
}

// 每次写入调用(会调用多次)
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // 可在这里通过已写入的长度和总长度算出下载进度
    if (session == self.session) {
         CGFloat progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite; NSLog(@"%f",progress);
    }
   
}

// 下载完成调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    // location还是一个临时路径,需要自己挪到需要的路径(caches下面)
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
}


#pragma mark 断点下载
//取消下载
- (void)cancelDownload
{
    // 使用这种方式取消下载可以得到将来用来恢复的数据,保存起来
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        self.reumeData = resumeData;
    }];
}

//恢复下载
- (void)resumeDownload
{
    self.downloadTask = [self.session downloadTaskWithResumeData:self.reumeData];
    [self.downloadTask resume];
}


#pragma mark }

#pragma mark NSURLSessionUploadTask 上传 {
// 1.GET上传
- (void)urlSessionUploadForUrlStr:(NSString *)urlStr ForFilePath:(NSString *)filePath
{
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    NSURLSessionUploadTask *task = [[NSURLSession sharedSession] uploadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:filePath]] fromFile:fileUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [task resume];
}

// 2.

- (void)urlSessionUploadTowForUrl:(NSURL *)url ForBodyData:(NSData *)bodyData
{
    //处于安全性考虑,通常我们会使用POST方式进行文件上传,所以较多使用第二种方式.
    //但是,NSURLSession并没有为我们提供比NSURLConnection更方便的文件上传方式.方法中body处的参数需要填写request的请求体(http协议规定格式的大长串).
    [[NSURLSession sharedSession] uploadTaskWithRequest:[NSURLRequest requestWithURL:url] fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
}

#pragma mark }




@end
