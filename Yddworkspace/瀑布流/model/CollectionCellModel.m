//
//  CollectionCellModel.m
//  Yddworkspace
//
//  Created by ydd on 2018/5/19.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "CollectionCellModel.h"

@implementation CollectionCellModel

- (instancetype)init
{
  self = [super init];
  if (self) {
    _cellSize = CGSizeZero;
    _contentFrame = CGRectZero;
    _contentHeight = 0;
    _title = @"";
  }
  return self;
}

@end
