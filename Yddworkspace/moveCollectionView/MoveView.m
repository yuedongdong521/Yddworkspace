//
//  MoveView.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/27.
//  Copyright © 2019 QH. All rights reserved.
//

#import "MoveView.h"
#import "CustomFlowLayout.h"
#import "YYPhotoGroupView.h"
#import "YYWebImage.h"
#import "KXPhotoGroupView.h"
#import "CollectionCell.h"

@interface MoveView ()<UICollectionViewDelegate, UICollectionViewDataSource, YYPhotoGroupViewDelegate, KXPhotoGroupViewDelegate>
{
    dispatch_semaphore_t _deleteCellSemaphore;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray <KXPhotoGroupItem *>*mutArr;
@property (nonatomic, strong) NSMutableArray *deleteDataArr;

@property (nonatomic, assign) BOOL canMove;

@property (nonatomic, strong) UILabel *deleteTipsLabel;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) NSIndexPath *deleteIndexPath;

@property (nonatomic, weak) CollectionCell *curMoveCell;


@end

@implementation MoveView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"button" forState:UIControlStateNormal];
        [self addSubview:button];
        _button = button;
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-150);
            make.height.mas_equalTo(50);
        }];
        
        [self addSubview:self.deleteTipsLabel];
        [self.deleteTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(100);
        }];
        
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.mas_equalTo(0);
            ;
        }];
        
        _deleteCellSemaphore = dispatch_semaphore_create(0);
        
    }
    
    return self;
}

- (void)buttonAction:(UIButton *)btn
{
    NSLog(@"clicked");
}

- (void)movePoint:(CGPoint)point
{
    CGFloat alpha = (point.y - self.deleteTipsLabel.frame.origin.y) / self.deleteTipsLabel.frame.size.height;
    alpha = alpha < 0 ? 0 : alpha;
    self.deleteTipsLabel.alpha = alpha;
    
}


- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        CustomFlowLayout *flowlayout = [[CustomFlowLayout alloc] init];
        
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:@"cell"];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        longPress.minimumPressDuration = 0.5;
        [_collectionView addGestureRecognizer:longPress];
        
    }
    return _collectionView;
}

- (UILabel *)deleteTipsLabel
{
    if (!_deleteTipsLabel) {
        _deleteTipsLabel = [[UILabel alloc] init];
        _deleteTipsLabel.textAlignment = NSTextAlignmentCenter;
        _deleteTipsLabel.text = @"拖到此处删除";
        _deleteTipsLabel.alpha = 0;
        _deleteTipsLabel.backgroundColor = [UIColor redColor];
    }
    return _deleteTipsLabel;
}


/**
 *返回列数
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(CustomFlowLayout *)collectionViewLayout columnCountForSection:(NSInteger)section
{
    return 4;
}
/**
 *返回每行之间的间隙
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(CustomFlowLayout*)collectionViewLayout rowMarginForSectionAtIndex:(NSInteger)section
{
    return 10;
}
/**
 *返回每列之间的间隙
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(CustomFlowLayout*)collectionViewLayout columnMarginForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(CustomFlowLayout*)collectionViewLayout heightForWidth:(CGFloat)width indexPath:(NSIndexPath*)indexPath
{
    return width;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(CustomFlowLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (void)longPressAction:(UIGestureRecognizer *)ges
{
    CGPoint longPressPoint = [ges locationInView:ges.view];
    [self movePoint:longPressPoint];
    switch (ges.state) {
        case UIGestureRecognizerStateBegan: {
            
            NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:longPressPoint];
            if (index && index.item != self.mutArr.count - 1) {
                self.curMoveCell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:index];
                self.deleteDataArr = [self.mutArr mutableCopy];
                self.deleteIndexPath = index;
                
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:index];
            }
            
        } break;
        case UIGestureRecognizerStateChanged: {
            [self.collectionView updateInteractiveMovementTargetPosition:longPressPoint];
        } break;
        case UIGestureRecognizerStateEnded: {
//            dispatch_semaphore_wait(_deleteCellSemaphore, DISPATCH_TIME_FOREVER);
            
            
            if (longPressPoint.y >= self.deleteTipsLabel.frame.origin.y) {
                _curMoveCell.hidden = YES;
                [self.collectionView cancelInteractiveMovement];
                if (self.deleteIndexPath) {
                    NSLog(@"删除前\n deleteData (%@),\n sourceData (%@)", self.deleteDataArr, self.mutArr);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.mutArr removeObjectAtIndex:self.deleteIndexPath.item];
                        NSLog(@"删除后\n deleteData (%@),\n sourceData (%@)", self.deleteDataArr, self.mutArr);
                        [self.collectionView reloadData];
                        self.deleteIndexPath = nil;
                    });
                    self.deleteTipsLabel.alpha = 0;
                }
            } else {
                
                NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:longPressPoint];
                if (!index || index.item >= self.mutArr.count - 1) {
                    [self.collectionView cancelInteractiveMovement];
                    return;
                }
                
                [self.collectionView  endInteractiveMovement];
            }
        } break;
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell.imageView yy_setImageWithURL:self.mutArr[indexPath.item].largeImageURL options:YYWebImageOptionUseNSURLCache];
//    cell.label.text = (NSString *)self.mutArr[indexPath.item];
    
    cell.indexPath = indexPath;
//    cell.alpha = 1;
    
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mutArr.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;//_canMove;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    KXPhotoGroupItem *item = self.mutArr[sourceIndexPath.item];
    [self.mutArr removeObjectAtIndex:sourceIndexPath.item];
    [self.mutArr insertObject:item atIndex:destinationIndexPath.item];
//    [self.collectionView reloadData];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        dispatch_semaphore_signal(_deleteCellSemaphore);
//    });

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    YYPhotoGroupItem *item = self.mutArr[indexPath.item];
    //    item.thumbView = [collectionView cellForItemAtIndexPath:indexPath];
    
    //    YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:self.mutArr];
    //    v.delegate = self;
    ////    [v presentFromImageView:item.thumbView toContainer:self.view animated:YES completion:nil];
    //    [v presentFromCurItem:indexPath.item toContainer:self.view animated:YES ompletion:nil];
    
    KXPhotoGroupView *view = [[KXPhotoGroupView alloc] initWithGroupItems:self.mutArr];
    view.delegate = self;
    [view hiddenPageControl:YES];
    [view presentFromCurItem:indexPath.item toContainer:self animated:YES ompletion:^{

    }];
    
}

- (UIView *)getCurrentThumbViewWithPage:(NSInteger)page
{
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
}

- (UIView *)photoGroupView:(KXPhotoGroupView *)photoGroupView getThumbViewWithPage:(NSInteger)page
{
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
}

- (UIImage *)photoGroupView:(KXPhotoGroupView *)photoGroupView getImageWithPage:(NSInteger)page
{
    CollectionCell *cell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
    return cell.imageView.image;
}

- (NSMutableArray *)mutArr
{
    if (!_mutArr) {

        _mutArr = [NSMutableArray array];
        
        NSArray<NSString *>*imageArr = @[@"http://pic1.win4000.com/pic/d/e6/19d99bb285_250_350.jpg",
                                         @"http://pic1.win4000.com/pic/3/af/ed122ba858_250_350.jpg",
                                         @"http://pic1.win4000.com/pic/5/6e/d9a960bc28_250_350.jpg",
                                         @"http://pic1.win4000.com/pic/b/e9/b6c3874c76_250_350.jpg",
                                         @"http://pic1.win4000.com/pic/2/06/df957155c4_250_350.jpg",
                                         @"http://pic1.win4000.com/pic/d/48/f2835946f9_250_350.jpg",
                                         @"http://pic1.win4000.com/pic/8/73/701918e37d_250_350.jpg",
                                         @"http://pic1.win4000.com/pic/d/e6/19d99bb285_250_350.jpg"];
        
        
        [imageArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            KXPhotoGroupItem *item = [[KXPhotoGroupItem alloc] init];
            item.largeImageURL = [NSURL URLWithString:obj];
            item.index = idx;
            [_mutArr addObject:item];
        }];
        
        KXPhotoGroupItem *addItem = [[KXPhotoGroupItem alloc] init];
        addItem.largeImageURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"addImage" ofType:@"jpg"]];
        addItem.index = _mutArr.count;
        [_mutArr addObject:addItem];
//        _mutArr = [NSMutableArray arrayWithArray:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"]];
    }
    return _mutArr;
}



- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.button.frame, point)) {
        return self.button;
    }
    return [super hitTest:point withEvent:event];
}


- (void)dealloc
{
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
}






@end
