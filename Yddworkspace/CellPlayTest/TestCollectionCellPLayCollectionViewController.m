//
//  TestCollectionCellPLayCollectionViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/12/27.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "TestCollectionCellPLayCollectionViewController.h"
#import "ISMyCollectionPlayerView.h"

@interface TestCollectionCellPLayCollectionViewController ()<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) ISMyCollectionPlayerView *playerView;

@end

@implementation TestCollectionCellPLayCollectionViewController

static NSString * const reuseIdentifier = @"Cell";



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"reload" style:UIBarButtonItemStyleDone target:self action:@selector(reloadItem)];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)reloadItem
{
    [self.collectionView reloadData];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ScreenWidth, ScreenWidth);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return 10;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    if (indexPath.item == 0) {
        _playerView = [self
                       creatPlayerViewWithFrame:cell.contentView.bounds
                       WithURL:[NSURL URLWithString:@"http://img.ispeak.cn/ishowapp/2017/1214/1513235442-104015397-FvZmPL0LsMSDbs4Mj4lYaln_scy4-1103-v128x264.mp4"]];
        if (_playerView.superview) {
            [_playerView removeFromSuperview];
        }
        [cell.contentView addSubview:_playerView];
    } else {

    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>


- (ISMyCollectionPlayerView*)creatPlayerViewWithFrame:(CGRect)frame
                                              WithURL:(NSURL*)url {
    if (_playerView == nil) {
        CGRect playerFrame =
        CGRectMake(15, 10, frame.size.width - 30, frame.size.height - 20);
        
        _playerView = [[ISMyCollectionPlayerView alloc] initWithFrame:playerFrame
                                                              WithURL:url];
        _playerView.layer.masksToBounds = YES;
    }
    return _playerView;
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
