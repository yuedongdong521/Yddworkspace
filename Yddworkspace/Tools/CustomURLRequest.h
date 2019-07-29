//
//  CustomURLRequest.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/11.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AFMultipartFormData;
NS_ASSUME_NONNULL_BEGIN

@interface ResponseModel : NSObject

@property (nonatomic, strong, nullable) NSURLRequest *request;
@property (nonatomic, strong, nullable) NSURLResponse *response;
@property (nonatomic, strong, nullable) NSURL *filePath;
@property (nonatomic, strong, nullable) NSError *error;
@property (nonatomic, strong, nullable) id data;

- (instancetype)initWithRequest:(nullable NSURLRequest *)request
                       respones:(nullable NSURLResponse *)respones
                          error:(nullable NSError *)error;

@end

typedef void(^CompletionBlock)(ResponseModel *responseModel);

@interface CustomURLRequest : NSObject
/** unit : s */
@property (nonatomic, assign) NSTimeInterval timeOut;
@property (nonatomic, assign) BOOL isJsonRequestSerializer;

@property (nonatomic, strong, readonly) NSURLSessionTask *reuqestTask;

- (instancetype)initWithUrl:(NSString *)url;

- (instancetype)initWithUrl:(NSString *)url
                   paramDic:(NSDictionary *)paramDic;
- (instancetype)initWithUrl:(NSString *)url
                 httpMethod:(NSString *)method
                   paramDic:(NSDictionary *)paramDic;

- (void)addConstructingBodyWithFilePath:(NSString *)filePath
                                   name:(NSString *)name
                               fileName:(NSString *)fileName
                                   type:(NSString *)type;
- (void)startRequestCompletionBlock:(CompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
