//
//  MenueScrollView.m
//  Yddworkspace
//
//  Created by ydd on 2020/11/5.
//  Copyright © 2020 QH. All rights reserved.
//

#import "MenueScrollView.h"

@interface MenueCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) BOOL didSelected;

@end

@implementation MenueCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}

- (void)updateCellSelected:(BOOL)selected
{
    _didSelected = selected;
    if (_didSelected) {
        self.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        self.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    } else {
        self.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        self.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
    }
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

- (void)selectedAnimation:(BOOL)selected
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self updateCellSelected:selected];
    } completion:^(BOOL finished) {
        if (!finished) {
            [self updateCellSelected:selected];
        }
    }];
}

@end


@interface MenueScrollView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, assign) NSInteger currIndex;


@end

@implementation MenueScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        [self.collectionView addSubview:self.lineView];
        
        
        self.currIndex = 0;
       
    }
    return self;
}

- (void)setMenues:(NSArray *)menues
{
    _menues = menues;
    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self lineViewAnimation:NO index:self.currIndex completed:nil];
    });
    
    
}

- (void)setCurrIndex:(NSInteger)currIndex
{
    if (_currIndex != currIndex) {
        MenueCell *lastCell = [self getCellWithIndex:_currIndex];
        MenueCell *curCell = [self getCellWithIndex:currIndex];
        [lastCell selectedAnimation:NO];
        [curCell selectedAnimation:YES];
    }
    _currIndex = currIndex;
}

- (void)setSeletcedIndex:(NSInteger)seletcedIndex
{
    if (seletcedIndex >= [self.collectionView numberOfItemsInSection:0]) {
        return;
    }
    
    if (seletcedIndex < 0) {
        seletcedIndex = 0;
    } else if (seletcedIndex >= self.menues.count) {
        seletcedIndex = self.menues.count - 1;
    }
    
   
    self.currIndex = seletcedIndex;
    _seletcedIndex = seletcedIndex;


    [CATransaction begin];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:seletcedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    if ([self.delegate respondsToSelector:@selector(menue:selectedIndex:)]) {
        [self.delegate menue:self selectedIndex:seletcedIndex];
    }
    [CATransaction setCompletionBlock:^{
        [self lineViewAnimation:NO index:self.currIndex completed:nil];
    }];
    [CATransaction commit];
}

- (void)setScrollIndex:(CGFloat)scrollIndex
{
    NSLog(@"scrollIndex : %.2f", scrollIndex);
    if (scrollIndex < 0) {
        scrollIndex = 0;
    } else if (scrollIndex >= self.menues.count - 1) {
        scrollIndex = self.menues.count - 1;
    }
    
    if (self.currIndex > scrollIndex) {
        if (self.currIndex - scrollIndex >= 1) {
            self.currIndex -= 1;
        }
        if (self.currIndex < 0) {
            self.currIndex = 0;
            CGRect curFrame = [self getCellFrameWithIndex:self.currIndex];
            CGRect lineFrame = [self getLineFrameWithCellFrame:curFrame];
            self.lineView.frame = lineFrame;
            return;
        }
        
        
        CGRect curFrame = [self getCellFrameWithIndex:self.currIndex];
        CGRect newFrame = [self getCellFrameWithIndex:floor(scrollIndex)];
        CGFloat space = CGRectGetMidX(curFrame) - CGRectGetMidX(newFrame);
        CGRect lineFrame = [self getLineFrameWithCellFrame:curFrame];
        CGFloat roat =  ceil(scrollIndex) - scrollIndex;
        
        if (self.animationType == MenueAnimationType_line) {
            if (roat <= 0.5) {
                lineFrame.size.width += (space * roat * 2);
                lineFrame.origin.x -= (space * roat * 2);
            } else {
                lineFrame.origin.x -= space;
                lineFrame.size.width = (lineFrame.size.width + space) - (space * (roat - 0.5) * 2);
            }
        } else {
            lineFrame.origin.x -= space * roat;
        }
        
        
        
        NSLog(@">>>>>>> {");
        NSLog(@"space : %.2f, roat : %.2f", space, roat);
        NSLog(@"lineFrame.origin.x : %.2f, w : %.2f", lineFrame.origin.x, lineFrame.size.width);
        NSLog(@"curIndex : %ld", (long)self.currIndex);
        NSLog(@">>>>>>> }");
        
        self.lineView.frame = lineFrame;
    } else if (self.currIndex < scrollIndex) {
        if (scrollIndex - self.currIndex >= 1) {
            self.currIndex += 1;
        }
        
        if (self.currIndex >= self.menues.count) {
            self.currIndex = self.menues.count - 1;
            CGRect curFrame = [self getCellFrameWithIndex:self.currIndex];
            CGRect lineFrame = [self getLineFrameWithCellFrame:curFrame];
            self.lineView.frame = lineFrame;
            return;
        }
        
        
        CGRect curFrame = [self getCellFrameWithIndex:self.currIndex];
        CGRect newFrame = [self getCellFrameWithIndex:ceil(scrollIndex)];
        CGFloat space = CGRectGetMidX(newFrame) - CGRectGetMidX(curFrame);
        CGRect lineFrame = [self getLineFrameWithCellFrame:curFrame];
        CGFloat roat = scrollIndex - floor(scrollIndex);
        
        if (self.animationType == MenueAnimationType_line) {
            if (roat <= 0.5) {
                lineFrame.size.width += (space * roat * 2);
            } else {
                lineFrame.size.width = (lineFrame.size.width + space) - (space * (roat - 0.5) * 2);
                lineFrame.origin.x += (space * (roat - 0.5) * 2);
            }
        } else {
            lineFrame.origin.x += space * roat;
        }
        
        
        
        NSLog(@"<<<<<<< {");
        NSLog(@"space : %.2f, roat : %.2f", space, roat);
        NSLog(@"lineFrame.origin.x : %.2f, w : %.2f", lineFrame.origin.x, lineFrame.size.width);
        NSLog(@"curIndex : %ld", (long)self.currIndex);
        NSLog(@"<<<<<<< }");
        self.lineView.frame = lineFrame;
    } else {
        NSLog(@"======= {");
        NSLog(@"lineFrame.origin.x : %.2f", self.lineView.frame.origin.x);
        NSLog(@"curIndex : %ld", (long)self.currIndex);
        NSLog(@"======= }");
    }
}

- (MenueCell *)getCellWithIndex:(NSInteger)index
{
    if (index >= [self.collectionView numberOfItemsInSection:0]) {
        return nil;
    }
    return (MenueCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (CGRect)getCellFrameWithIndex:(NSInteger)index
{
    if (index >= [self.collectionView numberOfItemsInSection:0]) {
        return CGRectZero;
    }
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return attributes.frame;
}

- (CGRect)getLineFrameWithCellFrame:(CGRect)frame
{
    return CGRectMake(CGRectGetMidX(frame) - 5, CGRectGetMaxY(frame) - 2, 10, 2);
}

- (void)lineViewAnimation:(BOOL)animation index:(NSInteger)index completed:(void(^)(void))completed
{

    CGRect frame = [self getCellFrameWithIndex:self.currIndex];
 
    CGRect rect = [self getLineFrameWithCellFrame:frame];
    NSLog(@" cell : %@", NSStringFromCGRect(frame));
    NSLog(@" rect : %@ ", NSStringFromCGRect(rect));
    NSLog(@" content : %@ ", NSStringFromCGSize(self.collectionView.contentSize));
    if (animation) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.lineView.frame = rect;
        } completion:^(BOOL finished) {
            if (!finished) {
                self.lineView.frame = rect;
            }
            if (completed) {
                completed();
            }
        }];
    } else {
        self.lineView.frame = rect;
        if (completed) {
            completed();
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, _leftSpace, 0, _rightSpace);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.menues[indexPath.item];
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    CGFloat w = [att boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width + 1;
    if (w < 30) {
        w = 30;
    }
    return CGSizeMake(w, self.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return _space;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.menues.count;
}



- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MenueCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.text = self.menues[indexPath.item];
    [cell updateCellSelected:indexPath.item == self.currIndex];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.seletcedIndex = indexPath.item;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat x = scrollView.contentOffset.x;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor greenColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[MenueCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}


- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor redColor];
    }
    return _lineView;
}


@end
