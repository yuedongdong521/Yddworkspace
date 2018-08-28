//
//  ISTakePhotoController.m
//  iShow
//
//  Created by run on 2017/10/28.
//

#import "ISTakePhotoController.h"
#import "VideoCameraView.h"
#import "ISEditingPhotoController.h"

@interface ISTakePhotoController () <VideoCameraViewDelegate> {
}

@end

@implementation ISTakePhotoController

- (instancetype)init {
  self = [super init];
  if (self) {
    _privateFlg = 0;
    _pageFromFlg = 0;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
  [ISPageStatisticsManager
      pageviewStartWithName:ISPageStatisticsCommonTakePhoto];
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [ISPageStatisticsManager pageviewEndWithName:ISPageStatisticsCommonTakePhoto];
  [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:YES];

  self.tabBarController.tabBar.hidden = YES;
  ISLog(@"%@创建了", self.class);
  [self createVideoCameraView];
}

- (void)createVideoCameraView {
  bool needNewVideoCamera = YES;
  for (UIView* subView in self.view.subviews) {
    if ([subView isKindOfClass:[VideoCameraView class]]) {
      needNewVideoCamera = NO;
    }
  }
  if (needNewVideoCamera) {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    CGRect frame = [[UIScreen mainScreen] bounds];
    VideoCameraView* videoCameraView =
        [[VideoCameraView alloc] initWithFrame:frame
                                   WithMaxTime:10.0
                                   WithMinTime:3.0];
    videoCameraView.videoCameraType = VideoCameraViewTypePic;
    ISLog(@"仅拍照");
    videoCameraView.delegate = self;
    [self.view addSubview:videoCameraView];
  }
}
#pragma mark - delegate -
// 退出
- (void)didClickBackToHomeBtn {
  // [self clickBackHome];
  ISLog(@"拍照界面 退出");
  if (_ispushToController) {
    [self.navigationController popViewControllerAnimated:NO];
  } else {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
  }
}

// 拍照完成
- (void)didFinishTakePhoto:(UIImage*)image
              goToNextPage:(void (^)(void))goToNextPage {
  ISEditingPhotoController* photoController =
      [[ISEditingPhotoController alloc] init];
  photoController.photoImage = image;
  photoController.isPrivateAlbum = self.privateFlg;
  photoController.pageFromFlg = self.pageFromFlg;
  photoController.activeId = _activeId;
  photoController.actTitle = _actTitle;
  photoController.isFromTakePhoto = YES;
  self.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:photoController animated:NO];

  if (goToNextPage) {
    goToNextPage();
  }
}
@end
