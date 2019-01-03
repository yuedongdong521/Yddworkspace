//
//  XMLDataAnalysis.m
//  Yddworkspace
//
//  Created by ydd on 2018/12/10.
//  Copyright © 2018 QH. All rights reserved.
//

#import "XMLDataAnalysis.h"
#import "GDataXMLNode.h"

@implementation XMLDataAnalysis

+ (void)downLoadXMLData:(void(^)(NSData *data, NSError *error))finish
{
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://test.update.ispeak.cn/ishow/daluandou_share_win_tips.xml"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
  NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSData *data = nil;
    if (location) {
      data = [NSData dataWithContentsOfURL:location];
      NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      NSLog(@"dataStr : %@", dataStr);
    }
    if (finish) {
      finish(data, error);
    }
  }];
  [downloadTask resume];
}


+ (void)analysisXML
{
  [self downLoadXMLData:^(NSData *data, NSError *error) {
    if (!data) {
      return;
    }
    NSError *xmlErr;
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithData:data options:0 error:&xmlErr];
    GDataXMLElement *rootElement = [xmlDocument rootElement];
    NSArray *childArray = [rootElement elementsForName:@"daluandou"];
    rootElement.attributes;
    
    
    NSLog(@"xmlD %@", xmlDocument);
  }];
}


@end
