//
//  ISTemplate.m
//  iShow
//
//  Created by apple on 2017/8/19.
//
//

#import "ISDynamicTemplate.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width

#define kLeftAndRightInset 15.0
#define KDynamicPicMinWidth 60
#define KDynamicPicMinHeight 60

#define kContentHeight (kScreenWidth - kLeftAndRightInset * 2)
#define kContentWidth kContentHeight

#define lengthOneFouth ((kContentWidth - _interItemSpacing * 3) / 4)
#define lengthOneThird ((kContentWidth - _interItemSpacing * 2) / 3)
#define lengthOneSecond ((kContentWidth - _interItemSpacing * 1) / 2)
#define lengthTwoThird (lengthOneThird * 2 + _interItemSpacing)
#define lengthThreeFouth (lengthOneFouth * 3 + _interItemSpacing * 2)
#define lengthOne (kContentWidth)

#define postionZero 0
#define postionOneSecond (lengthOneSecond + _interItemSpacing)
#define postionOneThird (lengthOneThird + _interItemSpacing)
#define postionTwoThird (lengthTwoThird + _interItemSpacing)
#define postionOneFouth (lengthOneFouth + _interItemSpacing)
#define postionThreeFouth (lengthThreeFouth + _interItemSpacing)

@interface ISDynamicTemplate ()

@property(nonatomic) CGFloat itemWidth;
@property(nonatomic) CGFloat lineSpacing;
@property(nonatomic) CGFloat interItemSpacing;
@property(nonatomic) UIEdgeInsets edgeInset;
@property(nonatomic) NSInteger itemCount;

// 长宽比，宽/高
@property(nonatomic) CGFloat itemWidthToHeightRatio;

@end

@implementation ISDynamicTemplate

- (instancetype)init {
  self = [super init];
  if (self) {
    self.sectionIndex = -1;
    self.contentHeight = 0;

    _edgeInset = UIEdgeInsetsZero;

    _interItemSpacing = 3.0;
    _lineSpacing = 3.0;

    _itemWidthToHeightRatio = 1.0;

    _itemCount = 0;

    [self.itemFrameList removeAllObjects];
  }

  return self;
}

- (void)updateItemsFrameAndConetentHeightWithTopOffset:(CGFloat)topContentOffset
                                         numberOfItems:
                                             (NSInteger)numberOfItems {
  [super updateItemsFrameAndConetentHeightWithTopOffset:topContentOffset
                                          numberOfItems:numberOfItems];

  _itemCount = numberOfItems;

  CGFloat ratioForWidthToHeight = 0;
  if (_delegate && [_delegate respondsToSelector:@selector
                              (ratioForItemSizeSection:templateItem:)]) {
    ratioForWidthToHeight =
        [_delegate ratioForItemSizeSection:self.sectionIndex templateItem:self];
  }

  CGSize imageitemSize;
  if (_delegate && [_delegate respondsToSelector:@selector
                              (originalItemSizeSection:templateItem:)]) {
    imageitemSize =
        [_delegate originalItemSizeSection:self.sectionIndex templateItem:self];
    if (imageitemSize.width == 0 && imageitemSize.height == 0) {
      imageitemSize = CGSizeMake(kContentWidth, kContentHeight);
    }
  }

  CGFloat heightForHeader = 0;
  if (_delegate && [_delegate respondsToSelector:@selector
                              (heightForHeaderInSection:templateItem:)]) {
    heightForHeader = [_delegate heightForHeaderInSection:self.sectionIndex
                                             templateItem:self];
  }

  CGFloat heightForFooter = 0;
  if (_delegate && [_delegate respondsToSelector:@selector
                              (heightForFooterInSection:templateItem:)]) {
    heightForFooter = [_delegate heightForFooterInSection:self.sectionIndex
                                             templateItem:self];
  }

  CGFloat topInsetOfSection = 0;
  if (_delegate && [_delegate respondsToSelector:@selector
                              (topInsetOfSection:templateItem:)]) {
    topInsetOfSection =
        [_delegate topInsetOfSection:self.sectionIndex templateItem:self];
  }

  CGFloat bottomInsetOfSection = 0;
  if (_delegate && [_delegate respondsToSelector:@selector
                              (bottomInsetOfSection:templateItem:)]) {
    bottomInsetOfSection =
        [_delegate bottomInsetOfSection:self.sectionIndex templateItem:self];
  }

  CGFloat itemContentHeight = kContentHeight;
  if (_itemCount == 0) {
    itemContentHeight = 0;
  }

  for (NSInteger i = 0; i < _itemCount; i++) {
    CGSize itemSize = [self itemSizeAtRowIndex:i];
    CGFloat itemWidth = itemSize.width;
    CGFloat itemHeight = itemSize.height;

    if (ratioForWidthToHeight < 1 && ratioForWidthToHeight > 0) {
      if (imageitemSize.width != 0) {
        itemHeight = (imageitemSize.height > kContentHeight)
                         ? kContentHeight
                         : imageitemSize.height;
        itemWidth = ((itemHeight * ratioForWidthToHeight) < KDynamicPicMinWidth)
                        ? KDynamicPicMinWidth
                        : (itemHeight * ratioForWidthToHeight);
        itemContentHeight = itemHeight;
      } else {
        itemHeight = kContentHeight;
        itemWidth = itemHeight * ratioForWidthToHeight;
      }
    }

    if (ratioForWidthToHeight >= 1) {
      if (imageitemSize.width != 0) {
        itemWidth = (imageitemSize.width > kContentWidth) ? kContentWidth
                                                          : imageitemSize.width;
        itemHeight =
            ((itemWidth / ratioForWidthToHeight) < KDynamicPicMinHeight)
                ? KDynamicPicMinHeight
                : (itemWidth / ratioForWidthToHeight);
        itemContentHeight = itemHeight;
      } else {
        itemWidth = kContentWidth;
        itemHeight = itemWidth / ratioForWidthToHeight;
        itemContentHeight = itemHeight;
      }
    }

    CGPoint itemPostion = [self itemPostionAtRowIndex:i];
    CGRect itemFrame = CGRectMake(
        itemPostion.x,
        itemPostion.y + topContentOffset + topInsetOfSection + heightForHeader,
        itemWidth, itemHeight);

    [self.itemFrameList addObject:NSStringFromCGRect(itemFrame)];
  }

  self.headerFrame = CGRectMake(0, topContentOffset + topInsetOfSection,
                                kScreenWidth, heightForHeader);
  self.footerFrame = CGRectMake(0,
                                topContentOffset + topInsetOfSection +
                                    heightForHeader + itemContentHeight,
                                kScreenWidth, heightForFooter);
  self.contentHeight = (heightForHeader + itemContentHeight + heightForFooter +
                        topInsetOfSection + bottomInsetOfSection);

  BOOL shouldShowDecorationView = YES;
  if (_delegate &&
      [_delegate respondsToSelector:@selector
                 (shouldShowDecorationViewInSection:templateItem:)]) {
    shouldShowDecorationView =
        [_delegate shouldShowDecorationViewInSection:self.sectionIndex
                                        templateItem:self];
  }

  if (shouldShowDecorationView) {
    self.decorationFrame = CGRectMake(0, CGRectGetMaxY(self.headerFrame),
                                      kScreenWidth, itemContentHeight);
  } else {
    self.decorationFrame = CGRectZero;
  }
}

- (CGPoint)itemPostionAtRowIndex:(NSUInteger)itemRowIndex;
{
  CGFloat itemXPos = 0;
  CGFloat itemYPos = 0;

  if (itemRowIndex == 0 || (_itemCount == 4 && itemRowIndex == 2) ||
      (_itemCount == 5 && itemRowIndex == 3) ||
      (_itemCount == 6 && itemRowIndex == 3) ||
      (_itemCount == 7 && itemRowIndex == 4) ||
      (_itemCount == 8 && itemRowIndex == 4) ||
      (_itemCount == 9 && (itemRowIndex == 1 || itemRowIndex == 5))) {
    itemXPos = postionZero;
  }

  if (itemRowIndex == 0 || (_itemCount == 2 && itemRowIndex == 1) ||
      (_itemCount == 3 && itemRowIndex == 1) ||
      (_itemCount == 4 && itemRowIndex == 1) ||
      (_itemCount == 5 && itemRowIndex == 1) ||
      (_itemCount == 6 && itemRowIndex == 1) ||
      (_itemCount == 7 && (itemRowIndex == 1 || itemRowIndex == 2)) ||
      (_itemCount == 8 && itemRowIndex == 1)) {
    itemYPos = postionZero;
  }

  if ((_itemCount == 2 && itemRowIndex == 1) ||
      (_itemCount == 3 && (itemRowIndex == 1 || itemRowIndex == 2)) ||
      (_itemCount == 4 && (itemRowIndex == 1 || itemRowIndex == 3)) ||
      (_itemCount == 8 && itemRowIndex == 6) ||
      (_itemCount == 9 && (itemRowIndex == 3 || itemRowIndex == 7))) {
    itemXPos = postionOneSecond;
  }

  if ((_itemCount == 3 && itemRowIndex == 2) ||
      (_itemCount == 4 && (itemRowIndex == 2 || itemRowIndex == 3)) ||
      (_itemCount == 8 && itemRowIndex == 3) ||
      (_itemCount == 9 && (itemRowIndex == 1 || itemRowIndex == 2 ||
                           itemRowIndex == 3 || itemRowIndex == 4))) {
    itemYPos = postionOneSecond;
  }

  if ((_itemCount == 6 && itemRowIndex == 4) ||
      (_itemCount == 7 && (itemRowIndex == 1 || itemRowIndex == 5))) {
    itemXPos = postionOneThird;
  }

  if ((_itemCount == 5 && itemRowIndex == 2) ||
      (_itemCount == 6 && itemRowIndex == 2) ||
      (_itemCount == 7 && itemRowIndex == 3)) {
    itemYPos = postionOneThird;
  }

  if ((_itemCount == 5 &&
       (itemRowIndex == 1 || itemRowIndex == 2 || itemRowIndex == 4)) ||
      (_itemCount == 6 &&
       (itemRowIndex == 1 || itemRowIndex == 2 || itemRowIndex == 5)) ||
      (_itemCount == 7 &&
       (itemRowIndex == 2 || itemRowIndex == 3 || itemRowIndex == 6))) {
    itemXPos = postionTwoThird;
  }

  if ((_itemCount == 5 && (itemRowIndex == 3 || itemRowIndex == 4)) ||
      (_itemCount == 6 &&
       (itemRowIndex == 3 || itemRowIndex == 4 || itemRowIndex == 5)) ||
      (_itemCount == 7 &&
       (itemRowIndex == 4 || itemRowIndex == 5 || itemRowIndex == 6))) {
    itemYPos = postionTwoThird;
  }

  if ((_itemCount == 8 && itemRowIndex == 5) ||
      (_itemCount == 9 && (itemRowIndex == 2 || itemRowIndex == 6))) {
    itemXPos = postionOneFouth;
  }

  if (_itemCount == 8 && itemRowIndex == 2) {
    itemYPos = postionOneFouth;
  }

  if ((_itemCount == 8 && (itemRowIndex == 1 || itemRowIndex == 2 ||
                           itemRowIndex == 3 || itemRowIndex == 7)) ||
      (_itemCount == 9 && (itemRowIndex == 4 || itemRowIndex == 8))) {
    itemXPos = postionThreeFouth;
  }

  if ((_itemCount == 8 && (itemRowIndex == 4 || itemRowIndex == 5 ||
                           itemRowIndex == 6 || itemRowIndex == 7)) ||
      (_itemCount == 9 && (itemRowIndex == 5 || itemRowIndex == 6 ||
                           itemRowIndex == 7 || itemRowIndex == 8))) {
    itemYPos = postionThreeFouth;
  }

  return CGPointMake(itemXPos + kLeftAndRightInset, itemYPos);
}

- (CGSize)itemSizeAtRowIndex:(NSUInteger)itemRowIndex;
{
  CGFloat itemHeight = 0;
  CGFloat itemWidth = 0;

  if (_itemCount == 1) {
    itemHeight = lengthOne;
    itemWidth = itemHeight;
  }

  if (_itemCount == 2 || (_itemCount == 3 && itemRowIndex == 0)) {
    itemHeight = lengthOne;
    itemWidth = lengthOneSecond;
  }

  if ((_itemCount == 3 && (itemRowIndex == 1 || itemRowIndex == 2)) ||
      _itemCount == 4) {
    itemHeight = lengthOneSecond;
    itemWidth = itemHeight;
  }

  if ((_itemCount == 5 && itemRowIndex == 0) ||
      (_itemCount == 6 && itemRowIndex == 0)) {
    itemHeight = lengthTwoThird;
    itemWidth = itemHeight;
  }

  if (_itemCount == 5 && itemRowIndex == 3) {
    itemHeight = lengthOneThird;
    itemWidth = lengthTwoThird;
  }

  if ((_itemCount == 5 &&
       (itemRowIndex == 1 || itemRowIndex == 2 || itemRowIndex == 4)) ||
      (_itemCount == 6 && itemRowIndex > 0) ||
      (_itemCount == 7 && itemRowIndex > 1)) {
    itemHeight = lengthOneThird;
    itemWidth = itemHeight;
  }

  if (_itemCount == 7 && (itemRowIndex == 0 || itemRowIndex == 1)) {
    itemHeight = lengthTwoThird;
    itemWidth = lengthOneThird;
  }

  if ((_itemCount == 8 && itemRowIndex > 0) ||
      (_itemCount == 9 && itemRowIndex > 0)) {
    itemHeight = lengthOneFouth;
    itemWidth = itemHeight;
  }

  if (_itemCount == 8 && itemRowIndex == 0) {
    itemHeight = lengthThreeFouth;
    itemWidth = itemHeight;
  }

  if (_itemCount == 9 && itemRowIndex == 0) {
    itemHeight = lengthOneSecond;
    itemWidth = lengthOne;
  }

  return CGSizeMake(itemWidth, itemHeight);
}

@end

/*
 ┏━━━━━━━┓
 ┃       ┃
 ┃   0   ┃
 ┃       ┃
 ┗━━━━━━━┛
 ┏━━━┳━━━┓
 ┃   ┃   ┃
 ┃ 0 ┃ 1 ┃
 ┃   ┃   ┃
 ┗━━━┻━━━┛
 ┏━━━┳━━━┓
 ┃   ┃ 1 ┃
 ┃ 0 ┣━━━┫
 ┃   ┃ 2 ┃
 ┗━━━┻━━━┛
 ┏━━━┳━━━┓
 ┃ 1 ┃ 2 ┃
 ┣━━━╋━━━┫
 ┃ 3 ┃ 4 ┃
 ┗━━━┻━━━┛
 ┏━━━━━┳━┓
 ┃     ┣━┫
 ┣━━━━━╋━┫
 ┗━━━━━┻━┛
 ┏━━━━━┳━┓
 ┃     ┣━┫
 ┣━━┳━━╋━┫
 ┗━━┻━━┻━┛
 ┏━━┳━━┳━┓
 ┃  ┃  ┣━┫
 ┣━━╋━━╋━┫
 ┗━━┻━━┻━┛
 ┏━━━━━┳━┓
 ┃     ┣━┫
 ┃     ┣━┫
 ┣━┳━┳━╋━┫
 ┗━┻━┻━┻━┛
 ┏━━━━━━━┓
 ┃       ┃
 ┣━┳━┳━┳━┫
 ┣━╋━╋━╋━┫
 ┗━┻━┻━┻━┛
 
 */
