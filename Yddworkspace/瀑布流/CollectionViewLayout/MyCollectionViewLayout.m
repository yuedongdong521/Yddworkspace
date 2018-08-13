//
//  MyCollectionViewLayout.m
//  Yddworkspace
//
//  Created by ydd on 2018/5/18.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyCollectionViewLayout.h"
#import "MyCollectionElementKindSectionDecorationView.h"

static CGFloat sectionInterInset = 10.0;

@interface MyCollectionViewLayout()
@property (nonatomic, strong) NSMutableArray *attributesArray;
@property(nonatomic) CGFloat headerAreaHeight;
@property(nonatomic) CGFloat cellAreaHeight;
@property(nonatomic) CGFloat footerAreaHeight;

@end

@implementation MyCollectionViewLayout

- (instancetype)init
{
  self = [super init];
  if (self) {
    _itemListArray = [NSMutableArray array];
    _attributesArray = [NSMutableArray array];
    _contentViewHeight = 0;
    _headerAreaHeight = 0;
    _cellAreaHeight = 0;
    _footerAreaHeight = 0;
  }
  return self;
}

#pragma mark - 实现内部的方法
/**
 * collection滚动范围
 */
- (CGSize)collectionViewContentSize {
  CGFloat minContentHeight = -1;
  if (_delegate && [_delegate respondsToSelector:@selector
                    (minContentHeightOfCollectionViewLayout:)]) {
    minContentHeight = [_delegate minContentHeightOfCollectionViewLayout:self];
  }
  
  if (_contentViewHeight < minContentHeight) {
    _contentViewHeight = minContentHeight;
  }
  
  return CGSizeMake(ScreenWidth, _contentViewHeight);
}


- (void)prepareLayout
{
  [super prepareLayout];
  NSLog(@"****** %@ : prepareLayout", NSStringFromClass([self class]));
  
  [self registerClass:[MyCollectionElementKindSectionDecorationView class] forDecorationViewOfKind:kMyCollectionElementKindSectionDecorationView];
  [_attributesArray removeAllObjects];
  _contentViewHeight = 0;
  //遍历所有item获取位置信息并进行存储
  NSInteger sectionCount = [self.collectionView numberOfSections];
  for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:sectionIndex];
    CollectionDataModel *cellDataMode = nil;
    if (_itemListArray.count > sectionIndex) {
      cellDataMode = _itemListArray[sectionIndex];
    } else {
      cellDataMode = [[CollectionDataModel alloc] init];
    }
    [self makeHeaderFrame:cellDataMode topContentOffset:_contentViewHeight];
    [self makeCellsFrame:cellDataMode topContentOffset:_contentViewHeight];
    [self makeCellsFrame:cellDataMode topContentOffset:_contentViewHeight];
    _contentViewHeight += _cellAreaHeight + _headerAreaHeight + _footerAreaHeight;
    _cellAreaHeight = 0;
    _headerAreaHeight = 0;
    _footerAreaHeight = 0;
    
    // 设置 cell 的 frame
    // 设置对应indexPath的布局属性
    for (NSInteger i = 0; i < itemCount; i++) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
      UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
      CGRect itemFrame = CGRectZero;
      if (cellDataMode.cellModelArray.count > i) {
        CollectionCellModel *cellMode = cellDataMode.cellModelArray[i];
        itemFrame =  cellMode.contentFrame;
      }
      attributes.frame = itemFrame;
      [self.attributesArray addObject:attributes];
    }
    
    UICollectionViewLayoutAttributes* headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
    headerAttributes.frame = cellDataMode.headerModel.contentFrame;
    [self.attributesArray addObject:headerAttributes];
    
    UICollectionViewLayoutAttributes* footerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
    footerAttributes.frame = cellDataMode.footerModel.contentFrame;
    
    UICollectionViewLayoutAttributes *decorationViewAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kMyCollectionElementKindSectionDecorationView withIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
    decorationViewAttributes.frame = cellDataMode.decorationModel.contentFrame;
    decorationViewAttributes.zIndex = -1;
    [self.attributesArray addObject:decorationViewAttributes];
  }
}
/**
 
 * 返回所有当前在可视范围内的item的布局属性
 
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
//  [super layoutAttributesForElementsInRect:rect];
  NSArray *attributesInRect = [self.attributesArray filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(
                                                                                                                       id _Nullable evaluatedObject,
                                                                                                                       NSDictionary<NSString*, id>* _Nullable bindings) {
    UICollectionViewLayoutAttributes* evaluatedAttributes =
    (UICollectionViewLayoutAttributes*)evaluatedObject;
    return CGRectIntersectsRect(rect, [evaluatedAttributes frame]);
  }]];
  return attributesInRect;
}

- (void)makeHeaderFrame:(CollectionDataModel *)dataModel topContentOffset:(CGFloat)topContentOffset {
  if (dataModel.headerModel) {
    CGFloat yStartPos = topContentOffset;
    CGRect headerFrame = dataModel.headerModel.contentFrame;
    dataModel.headerModel.contentFrame = CGRectMake(
                                  CGRectGetMinX(headerFrame), CGRectGetMinY(headerFrame) + yStartPos,
                                  CGRectGetWidth(headerFrame), CGRectGetHeight(headerFrame));
    self.headerAreaHeight = CGRectGetHeight(headerFrame) + sectionInterInset;
  }
}

- (void)makeFooterFrame:(CollectionDataModel *)dataModel topContentOffset:(CGFloat)topContentOffset
{

  if (dataModel.footerModel) {
    CGFloat yStartPos =
    topContentOffset + self.headerAreaHeight + self.cellAreaHeight;
    CGRect footerFrame = dataModel.footerModel.contentFrame;
    dataModel.footerModel.contentFrame = CGRectMake(
                                  CGRectGetMinX(footerFrame), CGRectGetMinY(footerFrame) + yStartPos,
                                  CGRectGetWidth(footerFrame), CGRectGetHeight(footerFrame));
    self.footerAreaHeight = CGRectGetHeight(footerFrame) + sectionInterInset;
  }
}



- (void)makeCellsFrame:(CollectionDataModel *)dataModel topContentOffset:(CGFloat)topContentOffset
{
  CGFloat yStartPos = topContentOffset + self.headerAreaHeight;
  NSMutableArray *array = [NSMutableArray array];
  for (NSInteger i = 0; i < dataModel.cellModelArray.count; i++) {
    CollectionCellModel* viewModel = (CollectionCellModel*)dataModel.cellModelArray[i];
    
    CGRect itemFrame =
    CGRectMake(CGRectGetMinX(viewModel.contentFrame),
               CGRectGetMinY(viewModel.contentFrame) + yStartPos,
               CGRectGetWidth(viewModel.contentFrame),
               CGRectGetHeight(viewModel.contentFrame));
    viewModel.contentFrame = itemFrame;
    [array addObject:viewModel];
  }
  dataModel.cellModelArray = array;
  self.cellAreaHeight = [self totalHeightWithViewModels:dataModel.cellModelArray] +
  sectionInterInset * 2;
}

- (CGFloat)totalHeightWithViewModels:(NSArray*)models {
  CGFloat totalHeight = 0;
  CGFloat minYPos = CGFLOAT_MAX;
  CGFloat maxYPos = 0;
  for (NSInteger i = 0; i < models.count; i++) {
    CollectionCellModel* viewModel = (CollectionCellModel*)models[i];
    // size != zero的才计入比较范围
    if (!CGSizeEqualToSize(viewModel.contentFrame.size, CGSizeZero)) {
      CGFloat viewMinYPos = CGRectGetMinY(viewModel.contentFrame);
      CGFloat viewMaxYPos = CGRectGetMaxY(viewModel.contentFrame);
      if (viewMinYPos < minYPos) {
        minYPos = viewMinYPos;
      }
      if (viewMaxYPos > maxYPos) {
        maxYPos = viewMaxYPos;
      }
    }
  }
  if (maxYPos > minYPos) {
    totalHeight = maxYPos - minYPos;
  }
  return totalHeight;
}


@end
