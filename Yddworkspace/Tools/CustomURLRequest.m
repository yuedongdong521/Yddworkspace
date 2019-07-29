//
//  CustomURLRequest.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/11.
//  Copyright © 2019 QH. All rights reserved.
//

#import "CustomURLRequest.h"
#import "AFNetworking.h"

@implementation ResponseModel

- (instancetype)initWithRequest:(NSURLRequest *)request
                       respones:(NSURLResponse *)respones
                          error:(NSError *)error
{
    self = [super init];
    if (self) {
        _request = request;
        _response = respones;
        _error = error;
    }
   return self;
}

@end

@interface CustomURLRequest ()

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, copy) NSString *requestMethod;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) NSMutableDictionary *paramDic;
@property (nonatomic, copy) void (^constructingBodyBlock)(id <AFMultipartFormData> formData);
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@end

@implementation CustomURLRequest

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        [self configRequestWithUrl:url httpMethod:@"GET" paramDic:nil];
    }
    return self;
}

- (instancetype)initWithUrl:(NSString *)url paramDic:(NSDictionary *)paramDic
{
    self = [super init];
    if (self) {
        [self configRequestWithUrl:url httpMethod:@"GET" paramDic:paramDic];
    }
    return self;
}

- (instancetype)initWithUrl:(NSString *)url httpMethod:(NSString *)method paramDic:(NSDictionary *)paramDic
{
    self = [super init];
    if (self) {
        [self configRequestWithUrl:url httpMethod:method paramDic:paramDic];
    }
    return self;
}

- (void)configRequestWithUrl:(NSString *)url httpMethod:(NSString *)method paramDic:(NSDictionary *)paramDic
{
    self.requestURL = [NSURL URLWithString:url];
    self.requestMethod = method;
    if (paramDic) {
        [self.paramDic addEntriesFromDictionary:paramDic];
    }
    self.timeOut = 30;
}

- (void)startRequestCompletionBlock:(CompletionBlock)completionBlock
{
    [self createRequest];
    _reuqestTask = [self dataCompletionBlock:completionBlock];
}

- (NSDictionary<NSString *, NSString *>*)requestHeaderFieldValueDictionary
{
    return nil;
}

- (void)addConstructingBodyWithFilePath:(NSString *)filePath
                                   name:(NSString *)name
                               fileName:(NSString *)fileName
                                   type:(NSString *)type
{
    NSParameterAssert(![self.requestMethod isEqualToString:@"GET"] && ![self.requestMethod isEqualToString:@"HEAD"]);
    self.constructingBodyBlock = ^(id<AFMultipartFormData>  _Nonnull formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"file://path/to/image.jpg"] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:name fileName:fileName mimeType:type error:nil];
    };
}

- (void)createRequest
{
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    if (self.isJsonRequestSerializer) {
        requestSerializer = [AFJSONRequestSerializer serializer];
        responseSerializer = [AFJSONResponseSerializer serializer];
    }
    requestSerializer.timeoutInterval = self.timeOut;
    NSDictionary <NSString *, NSString *>*headerFieldValueDictionary = [self requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    NSError *error;
    if (self.constructingBodyBlock) {
        _request = [requestSerializer multipartFormRequestWithMethod:self.requestMethod
                                                             URLString:self.requestURL.absoluteString
                                                            parameters:self.paramDic
                                             constructingBodyWithBlock:self.constructingBodyBlock
                                                                 error:&error];
    } else {
        _request = [requestSerializer requestWithMethod:self.requestMethod
                                                URLString:self.requestURL.absoluteString
                                               parameters:self.paramDic
                                                    error:&error];
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    [self.sessionManager setResponseSerializer:responseSerializer];
}

- (NSURLSessionTask *)downloadCompletionBlock:(CompletionBlock)completionBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    __weak typeof(self) weakself = self;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:self.request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (completionBlock) {
            ResponseModel *model = [[ResponseModel alloc] initWithRequest:weakself.request respones:response error:error];
            model.filePath = filePath;
            completionBlock(model);
        }
    }];
    [downloadTask resume];
    return downloadTask;
}

- (NSURLSessionTask *)uploaFilePath:(NSURL *)filePath
                    completionBlock:(CompletionBlock)completionBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    __weak typeof(self) weakself = self;
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:self.request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (completionBlock) {
            ResponseModel *model = [[ResponseModel alloc] initWithRequest:weakself.request respones:response error:error];
            model.filePath = filePath;
            model.data = responseObject;
            completionBlock(model);
        }
    }];
    [uploadTask resume];
    return uploadTask;
}

- (void)upload
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://example.com/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"file://path/to/image.jpg"] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                      }
                  }];
    
    [uploadTask resume];

}


- (NSURLSessionTask *)dataCompletionBlock:(CompletionBlock)completionBlock
{
    __weak typeof(self) weakself = self;
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:self.request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completionBlock) {
            ResponseModel *model = [[ResponseModel alloc] initWithRequest:weakself.request respones:response error:error];
            model.data = responseObject;
            completionBlock(model);
        }
    }];
    [dataTask resume];
    return dataTask;
}


@end
