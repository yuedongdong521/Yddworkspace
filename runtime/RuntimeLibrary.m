//
//  RuntimeLibrary.m
//  Yddworkspace
//
//  Created by ydd on 2018/8/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "RuntimeLibrary.h"

@implementation RuntimeLibrary

- (instancetype)init
{
  self = [super init];
  if (self) {
    _project = @"";
    _author = @"";
  }
  return self;
}

- (NSString *)libraryMethod
{
  return _project;
}

@end
