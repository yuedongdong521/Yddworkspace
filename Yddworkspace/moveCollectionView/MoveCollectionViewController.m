//
//  MoveCollectionViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/27.
//  Copyright © 2019 QH. All rights reserved.
//

#import "MoveCollectionViewController.h"
#import "CustomFlowLayout.h"
#import "YYPhotoGroupView.h"
#import "YYWebImage.h"
#import "PhotoGroupView.h"
#import "CollectionCell.h"
//#import "MoveView.h"
#import "PhotosDetailsViewController.h"
#import "CustomTransition.h"

@interface MoveCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, YYPhotoGroupViewDelegate, PhotoGroupViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray <PhotoGroupItem*>*mutArr;

@property (nonatomic, assign) BOOL canMove;

@property (nonatomic, strong) UILabel *deleteTipsLabel;

@property (nonatomic, assign) NSIndexPath *seletedIndexPath;

@property (nonatomic, assign) BOOL hidStatusBar;

@end

@implementation MoveCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor grayColor];
//    
//    MoveView *view = [[MoveView alloc] init];
//    [self.view addSubview:view];
//    
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsZero);
//    }];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [button setTitle:@"button" forState:UIControlStateNormal];
//    [self.view addSubview:button];
//    [button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_equalTo(0);
//        make.bottom.mas_equalTo(-150);
//        make.height.mas_equalTo(50);
//    }];
//
//    [self.view addSubview:self.deleteTipsLabel];
//    [self.deleteTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.mas_equalTo(0);
//        make.height.mas_equalTo(100);
//    }];
//
    [self.view addSubview:self.collectionView];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(0);
       ;
    }];

//
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return _hidStatusBar;
}


- (void)buttonAction:(UIButton *)btn
{
    NSLog(@"clicked");
}

- (void)movePoint:(CGPoint)point
{
    NSLog(@"movePoint : %@", NSStringFromCGPoint(point));
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
    static NSIndexPath *index = nil;
    CGPoint longPressPoint = [ges locationInView:ges.view];
    [self movePoint:longPressPoint];
    switch (ges.state) {
        case UIGestureRecognizerStateBegan: {
          
            index = [self.collectionView indexPathForItemAtPoint:longPressPoint];
            if (index) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:index];
            }
            
        } break;
        case UIGestureRecognizerStateChanged: {
            [self.collectionView updateInteractiveMovementTargetPosition:longPressPoint];
            
            
        } break;
        case UIGestureRecognizerStateEnded: {
            if (longPressPoint.y >= self.deleteTipsLabel.frame.origin.y) {
                [self.collectionView cancelInteractiveMovement];
                if (index) {
                    [self.mutArr removeObjectAtIndex:index.item];
                    [self.collectionView reloadData];
                }
            } else {
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
    cell.indexPath = indexPath;
    
    
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
    NSLog(@"moveItem : %d, toIndex : %d", sourceIndexPath.item, destinationIndexPath.item);
    PhotoGroupItem *item = self.mutArr[sourceIndexPath.item];
    [self.mutArr removeObjectAtIndex:sourceIndexPath.item];
    [self.mutArr insertObject:item atIndex:destinationIndexPath.item];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    self.seletedIndexPath = indexPath;
    PhotosDetailsViewController *vc = [[PhotosDetailsViewController alloc] init];
    vc.imageUrl = self.mutArr[indexPath.item].largeImageURL;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.hidStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIView *)getCurrentThumbViewWithPage:(NSInteger)page
{
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
}

- (UIView *)photoGroupView:(PhotoGroupView *)photoGroupView getThumbViewWithPage:(NSInteger)page
{
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
}

- (UIImage *)photoGroupView:(PhotoGroupView *)photoGroupView getImageWithPage:(NSInteger)page
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
                                                   @"https://upload-images.jianshu.io/upload_images/783864-75d618d20bff54d4.png?imageMogr2/auto-orient/",
                                                   @"http://pic1.win4000.com/pic/9/d8/d40783e51b_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/a/fa/21fad5eb9b_250_350.jpg",
                                                   @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=892932558,2928379420&fm=27&gp=0.jpg",
                                                   @"http://pic1.win4000.com/pic/a/a3/3af73c9e3b_250_350.jpg",
                                                   @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=511362691,3742913182&fm=27&gp=0.jpg",
                                                   @"http://pic1.win4000.com/pic/b/e9/b6c3874c76_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/2/06/df957155c4_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/d/48/f2835946f9_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/8/73/701918e37d_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/d/e6/19d99bb285_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/3/af/ed122ba858_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/5/6e/d9a960bc28_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/9/d8/d40783e51b_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/a/fa/21fad5eb9b_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/a/a3/3af73c9e3b_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/b/e9/b6c3874c76_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/2/06/df957155c4_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/d/48/f2835946f9_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/8/73/701918e37d_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/d/e6/19d99bb285_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/3/af/ed122ba858_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/5/6e/d9a960bc28_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/9/d8/d40783e51b_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/a/fa/21fad5eb9b_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/a/a3/3af73c9e3b_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/b/e9/b6c3874c76_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/2/06/df957155c4_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/d/48/f2835946f9_250_350.jpg",
                                                   @"http://pic1.win4000.com/pic/8/73/701918e37d_250_350.jpg"];
      
        
        [imageArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PhotoGroupItem *item = [[PhotoGroupItem alloc] init];
            item.largeImageURL = [NSURL URLWithString:obj];
            item.index = idx;
            [_mutArr addObject:item];
            if (idx == 7) {
                *stop = YES;
            }
        }];
        
    }
    return _mutArr;
}


- (void)dealloc
{
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
}

- (UIView *)transitionAnmateView
{
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.seletedIndexPath];
    return cell;
}
///**
// 为这个动画添加用户交互
// */
//- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController NS_AVAILABLE_IOS(7_0)
//{
//
//
//    return nil;
//}
//
///**
// 用来自定义转场动画
// 要返回一个准守UIViewControllerInteractiveTransitioning协议的对象,并在里面实现动画即可
// 1.创建继承自 NSObject 并且声明 UIViewControllerAnimatedTransitioning 的的动画类。
// 2.重载 UIViewControllerAnimatedTransitioning 中的协议方法。
// */
//- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                            animationControllerForOperation:(UINavigationControllerOperation)operation
//                                                         fromViewController:(UIViewController *)fromVC
//                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0)
//{
//    CustomTransition *transition = [[CustomTransition alloc] init];
//    if (operation == UINavigationControllerOperationPush) {
//        transition.animationStatus = AnimationStatus_push;
//        return transition;
//    } else {
//        transition.animationStatus = AnimationStatus_pop;
//        return transition;
//    }
//
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
