//
//  RuntimeTestModel.h
//  Yddworkspace
//
//  Created by ydd on 2020/12/30.
//  Copyright © 2020 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

@interface RuntimeTestModel : NSObject

@property (nonatomic, strong) NSString *prop1;
@property (nonatomic, strong) NSString *prop2;

@property (nonatomic, strong) NSMutableDictionary *dictionary;

+ (objc_property_t)parseSelector:(SEL)selector isGetter:(nullable BOOL *)isGetter isSetter:(nullable BOOL *)isSetter;

@end

NS_ASSUME_NONNULL_END
