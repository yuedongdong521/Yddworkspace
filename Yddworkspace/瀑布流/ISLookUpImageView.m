//
//  ISLookUpImageView.m
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "ISLookUpImageView.h"
#import "ISLookUpImageCell.h"
#import "TestImageModel.h"
#import "Masonry.h"

@interface ISLookUpImageView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ISLookUpImageCellDelegate>

@property(nonatomic, assign) UICollectionViewScrollDirection scrollDirection;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *imageList;

@end

@implementation ISLookUpImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame scrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
  self = [super initWithFrame:frame];
  if (self) {
    self.imageList = [NSMutableArray array];
    _scrollDirection = scrollDirection == UICollectionViewScrollDirectionHorizontal ? scrollDirection : UICollectionViewScrollDirectionVertical;
    [self addSubview:self.collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
  }
  return self;
}

- (void)reloadWithImageList:(NSArray *)imageList currentIndex:(NSInteger)index
{
  self.imageList = [NSMutableArray arrayWithArray:[imageList copy]];
  [self.collectionView reloadData];
  if (index < self.imageList.count && index != 0) {
    UICollectionViewScrollPosition scrollPosition = _scrollDirection == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:scrollPosition animated:YES];
  }
}

- (UICollectionView *)collectionView
{
  if (!_collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:_scrollDirection];
    layout.minimumLineSpacing = 0.0f;
    layout.minimumInteritemSpacing = 0.0f;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
      _collectionView.pagingEnabled = YES;
    }
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [_collectionView registerClass:[ISLookUpImageCell class] forCellWithReuseIdentifier:@"lookUpImageCell"];
  }
  return _collectionView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  CGFloat height = self.frame.size.height;
  if (_scrollDirection == UICollectionViewScrollDirectionVertical) {
    TestImageModel *model = _imageList[indexPath.item];
    CGFloat roat = model.size.width / model.size.height;
    height = self.frame.size.width / roat;
  }
  return CGSizeMake(self.frame.size.width - 5.0 * (_imageList.count - 1) / (CGFloat)_imageList.count, height - 5.0 * (_imageList.count - 1) / (CGFloat)_imageList.count);
  
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
  return 5.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
  return 5.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
  return UIEdgeInsetsMake(0.1f, 1.0f, 0.1f, 1.0f);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return _imageList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  ISLookUpImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lookUpImageCell" forIndexPath:indexPath];
  TestImageModel *imageModel = _imageList[indexPath.item];
  cell.imageModel = imageModel;
  cell.delegate = self;
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
  
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
  if ([cell isKindOfClass:[ISLookUpImageCell class]]) {
    ISLookUpImageCell *imageCell = (ISLookUpImageCell *)cell;
    [imageCell resetImageZoomScale];
  }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  
}

- (void)releaseLookUpViewDelegate
{
  if (_tapBlock) {
    _tapBlock();
  }
  [self removeFromSuperview];
  
}

- (void)dealloc
{
  NSLog(@"ISLookUpImageView释放了");
}

@end
