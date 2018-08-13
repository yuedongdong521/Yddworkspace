//
//  ISChatMoreImageCollectionViewLayout.m
//  iShow
//
//  Created by ydd on 2018/8/2.
//

#import "ISChatMoreImageCollectionViewLayout.h"

@implementation ISChatMoreImageCollectionViewLayout

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

- (NSMutableArray *)cellHArray
{
  if (!_cellHArray) {
    _cellHArray = [[NSMutableArray alloc] init];
  }
  return _cellHArray;
}

- (NSMutableArray *)attrsArray
{
  if (!_attrsArray) {
    _attrsArray = [[NSMutableArray alloc] init];
  }
  return _attrsArray;
}

- (void)prepareLayout
{
  [super prepareLayout];
  [self.attrsArray removeAllObjects];
  self.cellY = 0.0;
  
  for (NSInteger i = self.attrsArray.count; i < [self.collectionView numberOfItemsInSection:0]; i++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
    // 计算布局属性并将结果添加到布局属性数组中
    [self.attrsArray addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
  }
  
}

// 返回布局属性，一个UICollectionViewLayoutAttributes对象数组
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
  return self.attrsArray;
}

// 计算布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
  
  // collectionView的宽度
  CGFloat collectionViewW = self.collectionView.frame.size.width;

  // cell的高度
  CGFloat collectionViewH = [self.cellHArray[indexPath.item] floatValue];
  
  attrs.frame = CGRectMake(0, _cellY, collectionViewW, collectionViewH);
  // 计算cell的y
  _cellY += collectionViewH;
  NSLog(@"cell y = %f", _cellY);
  // 返回计算获取的布局
  return attrs;
}

- (CGSize)collectionViewContentSize {
  return CGSizeMake(ScreenWidth, _cellY);
}


@end
