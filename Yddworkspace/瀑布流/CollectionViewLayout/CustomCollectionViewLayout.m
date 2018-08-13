//
//  CustomCollectionViewLayout.m
//  Yddworkspace
//
//  Created by ydd on 2018/5/21.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "CustomCollectionViewLayout.h"

@implementation CustomCollectionViewLayout

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

/**
 
 * 准备布局item前调用，我们要在这里面完成必要属性的初始化
 
 */

- (void)prepareLayout

{
  [super prepareLayout];

  //初始化行距间距

  self.minimumLineSpacing = LINESPACING;

  self.minimumInteritemSpacing = INTERITEMSPACING;

  //初始化存储容器

  _attributes = [NSMutableDictionary dictionary];

  _colArray = [NSMutableArray arrayWithCapacity:COLUMNCOUNT];

  for (int i = 0; i < COLUMNCOUNT; i++) {
    [_colArray addObject:@(.0f)];
  }

  //遍历所有item获取位置信息并进行存储
  
  NSUInteger sectionCount = [self.collectionView numberOfSections];

  for (int section = 0; section < sectionCount; section++) {
    NSUInteger itemCount =
    [self.collectionView numberOfItemsInSection:section];

    for (int item = 0; item < itemCount; item++) {
      [self
          layoutItemFrameAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
    }
  }
}

/**
 
 * 用来设置每一个item的尺寸，然后和indexPath存储起来
 
 */

- (void)layoutItemFrameAtIndexPath:(NSIndexPath*)indexPath

{
  CGSize itemSize = CGSizeMake(ITEMWIDTH, 100 + arc4random() % 101);
  

   //获取当前三列高度中高度最低的一列
  
  NSUInteger smallestCol = 0;
  CGFloat shortHeight = 0.0;
   CGFloat lessHeight = [_colArray[smallestCol] doubleValue];
  for (int col = 1; col < _colArray.count; col++) {
    if (lessHeight < [_colArray[col] doubleValue]) {
      shortHeight = [_colArray[col] doubleValue];
      smallestCol = col;
    }
  }
  //在当前高度最低的列上面追加item并且存储位置信息
  UIEdgeInsets insets = self.collectionView.contentInset;
  CGFloat x = insets.left + smallestCol * (INTERITEMSPACING + ITEMWIDTH);
  CGRect frame = {x, insets.top + shortHeight, itemSize};
  [_attributes setValue:indexPath forKey:NSStringFromCGRect(frame)];
  [_colArray replaceObjectAtIndex:smallestCol
                           withObject:@(CGRectGetMaxY(frame))];
}

/**
 
 * 返回所有当前在可视范围内的item的布局属性
 
 */

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect

{
  //获取当前所有可视item的indexPath。通过调用父类获取的布局属性数组会缺失一部分可视item的布局属性
  NSMutableArray* indexPaths = [NSMutableArray array];
  for (NSString* rectStr in _attributes) {
    CGRect cellRect = CGRectFromString(rectStr);
    if (CGRectIntersectsRect(cellRect, rect)) {
      NSIndexPath* indexPath = _attributes[rectStr];
      [indexPaths addObject:indexPath];
    }
  }
  //获取当前要显示的所有item的布局属性并返回
  NSMutableArray* layoutAttributes =
      [NSMutableArray arrayWithCapacity:indexPaths.count];
  [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath* indexPath,
                                               NSUInteger idx, BOOL* stop) {
    UICollectionViewLayoutAttributes* attributes =
        [self layoutAttributesForItemAtIndexPath:indexPath];
    [layoutAttributes addObject:attributes];
  }];
  return layoutAttributes;
}

/**
 
 * 返回对应indexPath的布局属性
 
 */

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:
    (NSIndexPath*)indexPath {
  UICollectionViewLayoutAttributes* attributes =
      [UICollectionViewLayoutAttributes
          layoutAttributesForCellWithIndexPath:indexPath];
  for (NSString* frame in _attributes) {
    if (_attributes[frame] == indexPath) {
      attributes.frame = CGRectFromString(frame);
      break;
    }
  }
  return attributes;
}

/**
 
 * 设置collectionView的可滚动范围（瀑布流必要实现）
 
 */

- (CGSize)collectionViewContentSize {
  __block CGFloat maxHeight = [_colArray[0] floatValue];
  [_colArray enumerateObjectsUsingBlock: ^(NSNumber * height, NSUInteger idx, BOOL *stop) {
    if (height.floatValue > maxHeight) {
      maxHeight = height.floatValue;
    }
  }];
  return CGSizeMake(CGRectGetWidth(self.collectionView.frame), maxHeight + self.collectionView.contentInset.bottom);
}

/**
 * 在collectionView的bounds发生改变的时候刷新布局
 */

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
  return !CGRectEqualToRect(self.collectionView.bounds, newBounds);
}

@end
