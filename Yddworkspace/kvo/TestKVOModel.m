//
//  TestKVOModel.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/10.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TestKVOModel.h"

@implementation TestKVOModel


- (instancetype)init
{
  self = [super init];
  if (self) {
   
  }
  return self;
}

- (void)changeName:(NSString *)name
{
  _name = name;
}

- (id)copyWithZone:(NSZone *)zone
{
  TestKVOModel *copy = [TestKVOModel allocWithZone:zone];
  copy.name = self.name;
  copy.contentStr = self.contentStr;
  return copy;
}


@end
