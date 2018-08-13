//
//  ISTemplate.m
//  TestCollectionViewLayout
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 com.zhanglei.testshange. All rights reserved.
//

#import "ISTemplate.h"

@interface ISTemplate ()

@end

@implementation ISTemplate

- (instancetype)init {
  self = [super init];
  if (self) {
    _headerFrame = CGRectZero;
    _footerFrame = CGRectZero;
    _decorationFrame = CGRectZero;
    _contentHeight = 0;
    [self itemFrameList];

    _sectionIndex = -1;
  }

  return self;
}

- (void)updateItemsFrameAndConetentHeightWithTopOffset:(CGFloat)topContentOffset
                                         numberOfItems:
                                             (NSInteger)numberOfItems {
}

- (NSMutableArray*)itemFrameList {
  if (_itemFrameList == nil) {
    _itemFrameList = [NSMutableArray new];
  }

  return _itemFrameList;
}

+ (ISTemplate*)defaultTemplateWithSectionIndex:(NSInteger)sectionIndex {
  ISTemplate* defaultTemplate = [[ISTemplate alloc] init];
  defaultTemplate.sectionIndex = sectionIndex;
  return defaultTemplate;
}

@end
