//
//  MyURLTools.h
//  iShow
//
//  Created by run on 2018/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ISURLInfomationHandler)(NSString* title, NSString* desc,
                                       NSString* imageUrl);
typedef void (^ISURLShareInfomationHandler)(NSString* imageUrl, NSString* desc);

@interface MyURLTools : NSObject
// completionHandler异步
+ (void)getUrlInfomationWithUrlString:(NSString*)urlString
                           completion:(ISURLInfomationHandler)completionHandler;
// completionHandler同步
+ (void)getUrlInfomationSyncWithUrlString:(NSString*)urlString
                               completion:(ISURLShareInfomationHandler)
                                              completionHandler;

+ (BOOL)isWebsiteURLStrWithString:(NSString*)string;

@end

NS_ASSUME_NONNULL_END
