//
//  CollectionDataModel.m
//  Yddworkspace
//
//  Created by ydd on 2018/5/19.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "CollectionDataModel.h"

@implementation CollectionDataModel

- (instancetype)init
{
  self = [super init];
  if (self) {
    _cellModelArray = [NSMutableArray array];
  }
  return self;
}

@end
