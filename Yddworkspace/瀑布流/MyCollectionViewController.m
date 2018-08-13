//
//  MyCollectionViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/5/18.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "MyCollectionViewLayout.h"
#import "CollectionDataModel.h"
#import "CustomCollectionViewLayout.h"

@interface MyCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *collectionArray;


@end

@implementation MyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.navigationController.navigationBar.translucent = NO;
  self.view.backgroundColor = [UIColor whiteColor];
  [self initData];
  [self reloadCollection];
}

- (void)reloadCollection
{
//  MyCollectionViewLayout *layout = (MyCollectionViewLayout *)self.collectionView.collectionViewLayout;
  CustomCollectionViewLayout *layout = (CustomCollectionViewLayout *)self.collectionView.collectionViewLayout;
//  layout.itemListArray = self.collectionArray;
  [layout invalidateLayout];
  [self.collectionView setCollectionViewLayout:layout animated:YES];
  [self.collectionView reloadData];
}

- (NSMutableArray *)collectionArray
{
  if (!_collectionArray) {
    _collectionArray = [NSMutableArray array];
  }
  return _collectionArray;
}

- (void)initData
{
  for (int i = 0; i < 10; i++) {
    int item = arc4random() % 2;
    CollectionDataModel *dataModel = [[CollectionDataModel alloc] init];
    if (item == 0) {
      int row = arc4random() % 6 + 1;
      for (int j = 0; j < row; j++) {
        CollectionCellModel *cellMode = [[CollectionCellModel alloc] init];
        cellMode.contentFrame = CGRectMake(0, 0,arc4random() % 60 + 40, 60);
        [dataModel.cellModelArray addObject:cellMode];
      }
      
    } else {
      CollectionCellModel *cellMode = [[CollectionCellModel alloc] init];
      cellMode.contentFrame = CGRectMake(0, 0,80, 300);
      [dataModel.cellModelArray addObject:cellMode];
    }
    [self.collectionArray addObject:dataModel];
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionView *)collectionView
{
  if (!_collectionView) {
//    MyCollectionViewLayout *layout = [[MyCollectionViewLayout alloc] init];
    CustomCollectionViewLayout *layout = [[CustomCollectionViewLayout alloc] init];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.bounces = YES;
    _collectionView.alwaysBounceVertical = YES;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:_collectionView];
  }
  return _collectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return self.collectionArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  CollectionDataModel *dataModel = self.collectionArray[section];
  
  return dataModel.cellModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
  cell.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 256 / 255.0 blue:arc4random() % 255 / 255.0 alpha:1];
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
  
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
  
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
