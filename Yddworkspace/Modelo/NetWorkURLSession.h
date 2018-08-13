//
//  NetWorkURLSession.h
//  Yddworkspace
//
//  Created by lwj on 2018/5/17.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompleteProgress)(double progress);
typedef void(^Finish)(NSError *error);

@interface NetWorkURLSession : NSObject 

- (void)downLoad:(NSURL *)url savePath:(NSString *)savePath completeProgress:(CompleteProgress)progress finish:(Finish)finish;
- (void)cancelDownload;
@end
