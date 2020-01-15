//
//  ISAlbumListViewController.m
//  iShow
//
//  Created by admin on 2017/5/18.
//
//ISAlbumListViewController

#import "ISAlbumListViewController.h"
#import "ISPhotoAlbumViewController.h"
#import "ISAlbumListTableViewCell.h"
#import "ISAssetsManager.h"

@interface ISAlbumListViewController () <UITableViewDelegate,
                                         UITableViewDataSource>

@property(nonatomic, strong) UITableView* albumListTableView;
@property(nonatomic, strong) NSArray* albumListArray;

@property(nonatomic, assign) BOOL isFirst;

@end

@implementation ISAlbumListViewController

#pragma mark - init
- (instancetype)init {
  self = [super init];
  if (self) {
    _albumType = 0;
    _hasImageCount = 0;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (!self.isFirst) {
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    if (oldStatus == PHAuthorizationStatusAuthorized) {
      [self createTableView];
    } else {
      [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (status == PHAuthorizationStatusAuthorized) {
            [self createTableView];
          } else if (oldStatus != PHAuthorizationStatusNotDetermined &&
                     status == PHAuthorizationStatusDenied) {
        
          }
        });
      }];
    }
  } else {
    [self.albumListTableView reloadData];
  }
}


- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor whiteColor];

  _albumListArray = [[NSArray alloc] init];
  self.isFirst = NO;
  [self.view addSubview:self.albumListTableView];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(didSelectImageSource:)
             name:@"sendPho"
           object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(dismissAction:)
                                               name:@"dismissNotification"
                                             object:nil];
}

- (void)dismissAction:(NSNotification*)notify {
  if (_delegate && [_delegate respondsToSelector:@selector
                              (dismissAlbumListViewController:)]) {
    [_delegate dismissAlbumListViewController:self];
  }
}

// 获取到相册资源
- (void)didSelectImageSource:(NSNotification*)notify {
  NSArray* photoImageArray = [notify object];
  if (!photoImageArray || [photoImageArray isKindOfClass:[NSNull class]]) {
    return;
  }
  if (photoImageArray.count == 0) {
    return;
  }
  if (_delegate && [_delegate respondsToSelector:@selector
                              (albumListViewController:didSelectImageList:)]) {
    [_delegate albumListViewController:self didSelectImageList:photoImageArray];
  }
  if (_delegate && [_delegate respondsToSelector:@selector
                              (dismissAlbumListViewController:)]) {
    [_delegate dismissAlbumListViewController:self];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createTableView {
  _albumListArray = [[ISAssetsManager sharedInstancetype]
      fetchAllAlbumsWithAlbumContentTypeShowEmptyAlbum:NO
                                        showSmartAlbum:NO];
  if (_albumListArray.count > 0) {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([self.albumListTableView.delegate
            respondsToSelector:@selector
            (tableView:willSelectRowAtIndexPath:)]) {
      [self.albumListTableView.delegate tableView:self.albumListTableView
                           canFocusRowAtIndexPath:indexPath];
    }
    [self.albumListTableView
        selectRowAtIndexPath:indexPath
                    animated:NO
              scrollPosition:UITableViewScrollPositionNone];
    if ([self.albumListTableView.delegate
            respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
      [self.albumListTableView.delegate tableView:self.albumListTableView
                          didSelectRowAtIndexPath:indexPath];
    }
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (UITableView*)albumListTableView {
  if (!_albumListTableView) {
    _albumListTableView = [[UITableView alloc]
        initWithFrame:CGRectMake(0, kNavBarHeight, ScreenWidth,
                                 ScreenHeight - kNavBarHeight)];
    _albumListTableView.delegate = self;
    _albumListTableView.dataSource = self;
    _albumListTableView.rowHeight = 80;
    _albumListTableView.backgroundColor = [UIColor clearColor];
    if (IS_IPHONE_X) {
      _albumListTableView.contentInset =
          UIEdgeInsetsMake(0, 0, IS_BOTTOM_HEIGHT, 0);
      _albumListTableView.scrollIndicatorInsets =
          UIEdgeInsetsMake(0, 0, IS_BOTTOM_HEIGHT, 0);
    }
  }
  return _albumListTableView;
}

#pragma mark -  UIAlertView Delegate
- (void)alertView:(UIAlertView*)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    if (alertView.tag == 100) {
      [self rightBtnPressed];
    }
  }
}

- (NSInteger)tableView:(UITableView*)tableView
    numberOfRowsInSection:(NSInteger)section {
  return _albumListArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  NSString* identifier = @"AlbumList";
  ISAlbumListTableViewCell* cell =
      [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[ISAlbumListTableViewCell alloc]
          initWithStyle:UITableViewCellStyleDefault
        reuseIdentifier:identifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  PHAssetCollection* assetCollection = _albumListArray[indexPath.row];
  PHAsset* asset = [[ISAssetsManager sharedInstancetype]
      fetchNewAssetWithAssetCollection:assetCollection];
  CGSize size = CGSizeMake(80 * ScreenScale, 80 * ScreenScale);
  [[ISAssetsManager sharedInstancetype]
      posterImageWithPHAsset:asset
               imageWithSize:size
                 contentMode:PHImageContentModeDefault
                  completion:^(UIImage* AssetImage) {
                    cell.albumImageView.image = AssetImage;
                  }];
  NSInteger photoIndex = [[ISAssetsManager sharedInstancetype]
      fetchAlbumsCountWithAssetCollection:assetCollection];
  cell.albumNameLable.text =
      [NSString stringWithFormat:@"%@ (%lu)", assetCollection.localizedTitle,
                                 (unsigned long)photoIndex];

  return cell;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  return 80;
}
- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  PHAssetCollection* assetCollection = _albumListArray[indexPath.row];
  if (!assetCollection) {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"出错了"
                                                    message:@"相册可能不存在"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    return;
  }
  ISPhotoAlbumViewController* photoAlbum =
      [[ISPhotoAlbumViewController alloc] init];
  photoAlbum.assetCollection = assetCollection;
  photoAlbum.hasImageCount = self.hasImageCount;
  photoAlbum.albumType = self.albumType;
 
  self.isFirst = YES;
}

- (void)rightBtnPressed {
 
  NSArray* viewcontrollers = self.navigationController.viewControllers;
  if (viewcontrollers.count > 1) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
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
