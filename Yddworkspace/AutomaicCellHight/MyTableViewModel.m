//
//  MyTableViewModel.m
//  Yddworkspace
//
//  Created by ispeak on 16/10/18.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "MyTableViewModel.h"

@implementation MyTableViewModel

- (instancetype)initWithName:(NSString *)name HeadImageStr:(NSString *)headImageStr UserId:(int)userId TestStr:(NSString *)testStr IsOpen:(BOOL)isOpen
{
    self = [super init];
    if (self) {
        _name = name;
        _headImage = headImageStr;
        _uid = userId;
        _contentString = testStr;
        _isOpen = isOpen;
    }
    return self;
}


- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}


@end
