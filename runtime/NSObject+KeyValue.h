//
//  NSObject+KeyValue.h
//  Yddworkspace
//
//  Created by ydd on 2018/8/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NSObjectKeyValueDelegate<NSObject>

// 用在三级数组转换
- (NSDictionary *)arrayContainModelClass;

@end

@interface NSObject (KeyValue)

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
