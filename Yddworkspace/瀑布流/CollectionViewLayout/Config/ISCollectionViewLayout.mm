//
//  ISCustomCollectionViewLayout.m
//  iShow
//
//  Created by admin on 2017/6/23.
//
//

#import "ISCollectionViewLayout.h"
#import "ISCollectionElementKindSectionDecorationView.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width

@interface ISCollectionViewLayout ()

@property(nonatomic, strong) NSMutableArray* attributesArray;

@property(nonatomic) CGFloat contentViewHeight;

@end

@implementation ISCollectionViewLayout

- (instancetype)initWithTemplateList:
    (NSMutableArray<ISTemplate*>*)templateList {
  self = [super init];
  if (self) {
    _templateList = templateList;
    _contentViewHeight = 0;
  }

  return self;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _templateList = [NSMutableArray new];
    _contentViewHeight = 0;
  }

  return self;
}

#pragma mark - 实现内部的方法
- (CGSize)collectionViewContentSize {
  CGFloat minContentHeight = -1;
  if (_delegate && [_delegate respondsToSelector:@selector
                              (minContentHeightOfCollectionViewLayout:)]) {
    minContentHeight = [_delegate minContentHeightOfCollectionViewLayout:self];
  }

  if (_contentViewHeight < minContentHeight) {
    _contentViewHeight = minContentHeight;
  }

  return CGSizeMake(kScreenWidth, _contentViewHeight);
}

- (void)prepareLayout {
  [super prepareLayout];

  [self registerClass:[ISCollectionElementKindSectionDecorationView class]
      forDecorationViewOfKind:@"ISCollectionElementKindSectionDecorationView"];

  if ([_templateList isKindOfClass:[NSArray class]]) {
    _contentViewHeight = 0;
    [self.attributesArray removeAllObjects];

    NSInteger sectionCount = [self.collectionView numberOfSections];

    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount;
         sectionIndex++) {
      NSUInteger itemCount =
          [self.collectionView numberOfItemsInSection:sectionIndex];

      ISTemplate* templateItem = nil;
      if (_templateList.count > sectionIndex) {
        templateItem = _templateList[sectionIndex];
      } else {
        templateItem =
            [ISTemplate defaultTemplateWithSectionIndex:sectionIndex];
      }

      [templateItem
          updateItemsFrameAndConetentHeightWithTopOffset:_contentViewHeight
                                           numberOfItems:itemCount];

      _contentViewHeight += templateItem.contentHeight;
      for (NSUInteger i = 0; i < itemCount; i++) {
        NSIndexPath* indexPath =
            [NSIndexPath indexPathForItem:i inSection:sectionIndex];

        UICollectionViewLayoutAttributes* attributes =
            [UICollectionViewLayoutAttributes
                layoutAttributesForCellWithIndexPath:indexPath];

        CGRect itemFrame = CGRectZero;
        if (templateItem.itemFrameList.count > i) {
          itemFrame = CGRectFromString(
              [NSString stringWithFormat:@"%@", templateItem.itemFrameList[i]]);
        }

        attributes.frame = itemFrame;
        [self.attributesArray addObject:attributes];
      }

      UICollectionViewLayoutAttributes* footerAttributes =
          [UICollectionViewLayoutAttributes
              layoutAttributesForSupplementaryViewOfKind:
                  UICollectionElementKindSectionFooter
                                           withIndexPath:
                                               [NSIndexPath
                                                   indexPathForRow:0
                                                         inSection:
                                                             sectionIndex]];
      footerAttributes.frame = templateItem.footerFrame;
      [self.attributesArray addObject:footerAttributes];

      UICollectionViewLayoutAttributes* headerAttributes =
          [UICollectionViewLayoutAttributes
              layoutAttributesForSupplementaryViewOfKind:
                  UICollectionElementKindSectionHeader
                                           withIndexPath:
                                               [NSIndexPath
                                                   indexPathForRow:0
                                                         inSection:
                                                             sectionIndex]];
      headerAttributes.frame = templateItem.headerFrame;
      [self.attributesArray addObject:headerAttributes];

      UICollectionViewLayoutAttributes* decorationViewAttributes =
          [UICollectionViewLayoutAttributes
              layoutAttributesForDecorationViewOfKind:
                  @"ISCollectionElementKindSectionDecorationView"
                                        withIndexPath:
                                            [NSIndexPath
                                                indexPathForRow:0
                                                      inSection:sectionIndex]];
      decorationViewAttributes.frame = templateItem.decorationFrame;
      decorationViewAttributes.zIndex = -1;
      [self.attributesArray addObject:decorationViewAttributes];
    }
  }
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
  NSArray* attributesInRect = [self.attributesArray
      filteredArrayUsingPredicate:
          [NSPredicate predicateWithBlock:^BOOL(
                           id _Nullable evaluatedObject,
                           NSDictionary<NSString*, id>* _Nullable bindings) {
            return CGRectIntersectsRect(rect, [evaluatedObject frame]);
          }]];

  return attributesInRect;
}

- (NSMutableArray*)attributesArray {
  if (!_attributesArray) {
    _attributesArray = [[NSMutableArray alloc] init];
  }
  return _attributesArray;
}

@end
