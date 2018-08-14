//
//  NSObject+AddAttribute.m
//  Yddworkspace
//
//  Created by ydd on 2018/8/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "NSObject+AddAttribute.h"
#import <objc/runtime.h>

@implementation NSObject (AddAttribute)

- (void)setName:(NSString *)name
{
  objc_setAssociatedObject(self, @"name", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)name
{
  return objc_getAssociatedObject(self, @"name");
}


@end
