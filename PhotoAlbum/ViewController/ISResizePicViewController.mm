//
//  ISResizePicViewController.m
//  iShow
//
//  Created by ispeak on 2018/4/12.
//

#import "ISResizePicViewController.h"
#import "ISImageresizerView.h"
#import "Masonry.h"

@interface ISResizePicViewController ()
@property(nonatomic, strong) UIButton* recoveryBtn;
@property(nonatomic, strong) UIButton* goBackBtn;
@property(nonatomic, strong) UIButton* resizeBtn;
@property(nonatomic, weak) ISImageresizerView* imageresizerView;

@end

@implementation ISResizePicViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  self.view.backgroundColor = self.configure.bgColor;
  [self.view addSubview:self.goBackBtn];
  [self.view addSubview:self.resizeBtn];

  // __weak typeof(self) wSelf = self;
  UIEdgeInsets contentInsets = UIEdgeInsetsMake(44, 0, 90, 0);
  JPImageresizerConfigure* configure = [JPImageresizerConfigure
      blurMaskTypeConfigureWithResizeImage:self.selectedImage
                                   isLight:NO
                                      make:^(
                                          JPImageresizerConfigure* configure){
                                      }];
  configure.jp_contentInsets(contentInsets);
  self.configure = configure;
  ISImageresizerView* imageresizerView = [ISImageresizerView
      imageresizerViewWithConfigure:self.configure
          imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
          }
       imageresizerIsPrepareToScale:^(BOOL isPrepareToScale){
       }];
  imageresizerView.frameType = JPClassicFrameType;
  [self.view insertSubview:imageresizerView atIndex:0];
  self.imageresizerView = imageresizerView;
  self.configure = nil;
  [self setViewLayout];
}
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIButton*)goBackBtn {
  if (!_goBackBtn) {
    _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_goBackBtn addTarget:self
                   action:@selector(pop:)
         forControlEvents:UIControlEventTouchUpInside];
    _goBackBtn.backgroundColor = [UIColor clearColor];
    _goBackBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _goBackBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_goBackBtn setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [_goBackBtn setTitle:@"返回" forState:UIControlStateNormal];
  }
  return _goBackBtn;
}
- (UIButton*)resizeBtn {
  if (!_resizeBtn) {
    _resizeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resizeBtn addTarget:self
                   action:@selector(resize:)
         forControlEvents:UIControlEventTouchUpInside];
    _resizeBtn.backgroundColor = [UIColor clearColor];
    _resizeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _resizeBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_resizeBtn setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [_resizeBtn setTitle:@"选取" forState:UIControlStateNormal];
  }
  return _resizeBtn;
}
- (void)setViewLayout {
  [self.goBackBtn mas_makeConstraints:^(MASConstraintMaker* make) {
    make.left.mas_equalTo(20);
    make.bottom.mas_equalTo(-30);
    make.size.mas_equalTo(CGSizeMake(80, 40));
  }];
  [self.resizeBtn mas_makeConstraints:^(MASConstraintMaker* make) {
    make.right.mas_equalTo(-20);
    make.bottom.mas_equalTo(-30);
    make.size.mas_equalTo(CGSizeMake(80, 40));
  }];
}
- (void)recovery:(id)sender {
  [self.imageresizerView recovery];
}
- (void)resize:(id)sender {
  self.recoveryBtn.enabled = NO;

  __weak typeof(self) weakSelf = self;
  [self.imageresizerView imageresizerWithComplete:^(UIImage* resizeImage) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) return;
    if (!resizeImage) {
      resizeImage = self.imageresizerView.resizeImage;
      NSLog(@"没有裁剪图片");
      return;
    }
    NSDictionary* dict = @{
      @"AssetPhotoImage" : resizeImage,
      @"AlbumType" : [NSNumber
          numberWithInteger:CONTACT_PHOTOLIST_WITH_DYNAMIC_VIDEO_COVER]
    };
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"IS_EDIT_DYNAMIC_VIDEO_COVER"
                      object:nil
                    userInfo:dict];
    dispatch_async(dispatch_get_main_queue(), ^{
      NSArray* viewControllers = self.navigationController.viewControllers;
      if (viewControllers.count > 1) {
        [self.navigationController
            popToViewController:viewControllers[viewControllers.count - 4]
                       animated:YES];
      } else {
        [self.presentingViewController.presentingViewController
                .presentingViewController dismissViewControllerAnimated:YES
                                                             completion:nil];
      }
    });
    strongSelf.recoveryBtn.enabled = YES;
  }];
}

- (void)pop:(id)sender {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)lockFrame:(UIButton*)sender {
  sender.selected = !sender.selected;
  self.imageresizerView.isLockResizeFrame = sender.selected;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)dealloc {
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
