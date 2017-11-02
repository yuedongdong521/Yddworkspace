//
//  ModeloTool.h
//  Yddworkspace
//
//  Created by ispeak on 2017/7/27.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModeloTool : NSObject

+ (instancetype)sharedModeloTool;

- (void)urlConnectionnetworkRequestForType:(NSString *)type ForUrl:(NSString *)url ForParameter:(NSDictionary *)parameter ForBackResult:(void(^)(NSDictionary *dic, NSError *error))backResult;
@end
