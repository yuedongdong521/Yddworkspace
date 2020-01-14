//
//  KXLuckDrawView.m
//  Yddworkspace
//
//  Created by ydd on 2019/12/17.
//  Copyright © 2019 QH. All rights reserved.
//

#import "KXLuckDrawView.h"

@interface KXLuckDrawCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *title;

@end

@implementation KXLuckDrawCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        [self addSubview:self.title];
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.imageView.mas_bottom);
            make.bottom.left.right.mas_equalTo(0);
        }];
    }
    return self;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor redColor];
        _imageView.layer.cornerRadius = 15;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)title
{
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textAlignment = NSTextAlignmentCenter;
    }
    return _title;
}

@end

@interface KXLuckDrawView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger allCount;

@property (nonatomic, assign) BOOL scrolling;

@property (nonatomic, assign) NSInteger curCount;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation KXLuckDrawView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        for (int i = 0; i < 20; i++) {
            [self.dataArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
        self.allCount = self.dataArr.count * 1000;
        
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(60);
        }];
        
        UIView *luckView = [[UIView alloc] init];
        luckView.backgroundColor = [UIColor greenColor];
        [self addSubview:luckView];
        [luckView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(2, 10));
            make.centerX.equalTo(self);
        }];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"开始抽奖" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.collectionView.mas_bottom);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(80, 40));
        }];
        [self resetCollectionView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollStopCheck];
        });
    }
    return self;
}

- (void)resetCollectionView
{
    NSInteger row = self.dataArr.count * 500 + self.curCount % self.dataArr.count;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    
}

- (void)buttonAction:(UIButton *)btn
{
    
    [self getCurCellCount];
    self.scrolling = YES;
    self.collectionView.userInteractionEnabled = NO;
    [self scrollAnimated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrolling = NO;
        self.collectionView.userInteractionEnabled = YES;
    });
    
}

- (void)getCurCellCount
{
    NSArray *cells = [self.collectionView visibleCells];
    KXLuckDrawCell *curCell = nil;
    CGFloat space = -1;
    CGFloat centerX = self.collectionView.center.x;
    for (KXLuckDrawCell *cell in cells) {
        CGPoint p = [cell convertPoint:cell.center toView:self.collectionView];
        CGFloat edge = fabs(p.x - centerX);
        if (space == -1) {
            space = edge;
            curCell = cell;
        } else {
            if (edge < space) {
                space = edge;
                curCell = cell;
            }
        }
    }
    
    self.curCount = [self.collectionView indexPathForCell:curCell].item;
}

- (void)scrollStopCheck
{
    NSArray *cells = [self.collectionView visibleCells];
    KXLuckDrawCell *curCell = nil;
    CGFloat offset = 0;
    CGFloat space = -1;
    CGFloat centerX = self.collectionView.center.x;
    for (KXLuckDrawCell *cell in cells) {
        CGPoint p = [cell convertPoint:cell.contentView.center toView:self];
        CGFloat cellOffset = p.x - centerX;
        CGFloat fOffset = fabs(cellOffset);
        if (space == -1) {
            space = fOffset;
            offset = cellOffset;
            curCell = cell;
        } else {
            if (fOffset < space) {
                space = fOffset;
                offset = cellOffset;
                curCell = cell;
            }
        }
    }
    if (curCell) {
        CGPoint p = self.collectionView.contentOffset;
        p.x += offset;
        [UIView animateWithDuration:0.3 animations:^{
            [self.collectionView setContentOffset:p];
        }];
        
    }

}

- (void)scrollAnimated
{
    if (self.scrolling) {
        [self getCurCellCount];
        
        self.curCount += self.dataArr.count + arc4random() % self.dataArr.count;
        if (self.curCount < self.allCount) {
             [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.curCount inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            
        }
        
    } else {
        [self resetCollectionView];
    }
   
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollAnimated];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        [self scrollStopCheck];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate && scrollView == self.collectionView){
        NSLog(@"%@: decelerate = %d", NSStringFromSelector(_cmd), decelerate);
        [self scrollStopCheck];
    }
     
}



- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(50, 50);
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[KXLuckDrawCell class] forCellWithReuseIdentifier:@"KXLuckDrawCell"];
        _collectionView.pagingEnabled = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KXLuckDrawCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KXLuckDrawCell" forIndexPath:indexPath];
    cell.title.text = [NSString stringWithFormat:@"%ld", indexPath.row % self.dataArr.count];
    return cell;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allCount;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}


@end
