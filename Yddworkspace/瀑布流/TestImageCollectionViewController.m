//
//  TestImageCollectionViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "TestImageCollectionViewController.h"
#import "TestCollectionViewCell.h"
#import "TestImageModel.h"
#import "UIImage+ImageSizeWithURL.h"
#import "ISLookUpImageView.h"
#import "FullImageAnimateView.h"
#import "JKRFallsLayout.h"


@interface TestImageCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JKRFallsLayoutDelegate>

@property(nonatomic, strong) NSMutableArray <TestImageModel*>* imageListArr;
@property(nonatomic, strong) UICollectionView *collectionView;


@end

@implementation TestImageCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
  self.navigationController.navigationBar.translucent = YES;
  [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
  [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
  self.view.backgroundColor = [UIColor grayColor];
  _imageListArr = [NSMutableArray array];
  
  [self createImageListData];
    
    // Register cell classes
  
  JKRFallsLayout *flow = [[JKRFallsLayout alloc] init];
//  [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
  flow.cellSizeArray = self.imageListArr;
  flow.delegate = self;
  CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
  CGFloat h = ScreenHeight - y;
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, y, ScreenWidth, h) collectionViewLayout:flow];
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  [self.collectionView registerClass:[TestCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
  [self.view addSubview:self.collectionView];
    // Do any additional setup after loading the view.
}

- (void)reloadCollectionView
{
  JKRFallsLayout *flow = (JKRFallsLayout *)self.collectionView.collectionViewLayout;
  [flow invalidateLayout];
  flow.cellSizeArray = self.imageListArr;
  [self.collectionView setCollectionViewLayout:flow animated:YES];
  [self.collectionView reloadData];
}

- (CGFloat)columnCountInFallsLayout:(JKRFallsLayout *)fallsLayout
{
  return 1;
}

- (void)createImageListData
{
  NSArray *urlArr = @[@"http://pic1.win4000.com/pic/d/e6/19d99bb285_250_350.jpg",
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
  
  dispatch_group_t group = dispatch_group_create();
  for (int i = 0; i < urlArr.count; i++) {
    TestImageModel *model = [[TestImageModel alloc] initWithUrl:urlArr[i]];
    [_imageListArr addObject:model];
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      model.size = [UIImage getImageSizeWithURL:model.urlStr];
    });
  }
  [self reloadCollectionView];
  dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self reloadCollectionView];
    });
  });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _imageListArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
  TestImageModel *model = _imageListArr[indexPath.item];
  [cell setImageURL:model.urlStr];
    return cell;
}

/*

// 定义每个item的大小
- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath {
  TestImageModel *model = _imageListArr[indexPath.item];
  CGFloat roat = model.size.width / model.size.height;
  
  return CGSizeMake(ScreenWidth - 20, (ScreenWidth - 20) / roat);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
  return UIEdgeInsetsMake(5.0, 0, 5.0, 0);
}

// 每个item之间的间距
- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
  return 10.0f;
}

*/

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  TestCollectionViewCell *cell = (TestCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
  
  ISLookUpImageView *imageView = [[ISLookUpImageView alloc] initWithFrame:self.view.bounds scrollDirection:UICollectionViewScrollDirectionHorizontal];
  [imageView reloadWithImageList:self.imageListArr currentIndex:indexPath.item];
  [self.view addSubview:imageView];
  imageView.hidden = YES;
  
  FullImageAnimateView *fullView = [[FullImageAnimateView alloc] initWithFrame:self.view.bounds image:cell.imageview.image];
  [self.view addSubview:fullView];
  [fullView beganAnimateTargetView:cell inView:self.view finish:^(BOOL finished) {
    imageView.hidden = NO;
  }];
  
  imageView.tapBlock = ^{
    [fullView endAnimationFinish:^(bool finished) {
      
    }];
  };
  
}


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
