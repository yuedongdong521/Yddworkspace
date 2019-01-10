//
//  ViewController.m
//  Yddworkspace
//
//  Created by ispeak on 16/8/15.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "ViewController.h"
#import "YddImagePickerViewController.h"
#import "MyImagePickerViewController.h"
#import "MyTableViewController.h"
#import "AnimationViewController.h"
#import "Yddworkspace-Swift.h"
#import "CoreTextViewController.h"
#import "IntrinsicViewController.h"
#import "ZhengZeViewController.h"
#import "AVCaptureSessionViewController.h"
#import "BezierPathViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "PresentationViewController.h"
#import "TestCollectionCellPLayCollectionViewController.h"
#import "ISAssetsManager.h"
#import "ISPhotoAlbumViewController.h"

#define IS_iPhoneX [UIScreen mainScreen].bounds.size.height >= 812


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSArray* array;
@property(nonatomic, strong) UITableView* myTableView;
@property(nonatomic, strong) NSMutableArray* myTestMtbArray;
@property(nonatomic, strong) NSArray* swiftArray;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.navigationController.navigationBarHidden = NO;
  self.navigationController.navigationBar.translucent = YES;
  NSLog(@"tableViewFrame = %@", NSStringFromCGRect(_myTableView.frame));
  NSLog(@"ViewController.view.frame = %@", NSStringFromCGRect(self.view.frame));
  NSLog(@"ViewController.view.bounds = %@",
        NSStringFromCGRect(self.view.bounds));
  NSLog(@"ViewController.edgesForExtendedLayout = %lu",
        (unsigned long)self.edgesForExtendedLayout);
  NSLog(@"ViewController.translucent = %d",
        self.navigationController.navigationBar.translucent);

  if (@available(iOS 11.0, *)) {
    NSLog(@"ViewController.safeAreaInsets = %@",
          NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    NSLog(@"ViewController.tableView.SafeAreaInsets = %@",
          NSStringFromUIEdgeInsets(self.myTableView.safeAreaInsets));
    NSLog(@"ViewController.tableView.contentInset = %@",
          NSStringFromUIEdgeInsets(self.myTableView.contentInset));
    NSLog(@"ViewController.tableView.adjustedContentInset = %@",
          NSStringFromUIEdgeInsets(self.myTableView.adjustedContentInset));
  } else {
    // Fallback on earlier versions
  }
  NSLog(@"ViewController.tableView.contentInset = %@",
        NSStringFromUIEdgeInsets(self.myTableView.contentInset));
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.view.backgroundColor = [UIColor whiteColor];
  self.navigationController.navigationBar.translucent =
      YES;  // translucent设置为YES self.view的frame为屏幕的bounds，
            // 设置为NO时，self.view的frame
            // 的y坐标从导航栏底部位置开始，高度减去64
  /*
   ，iOS7中，UIViewController增加了一个新的属性：edgesForExtendedLayout，
   这个属性的默认值是UIRectEdgeAll。当你的容器是UINavigationController时，默认的布局就是从状态栏的顶部开始的，所以视图向上了66点，解决办法有两个：
   1.设置edgesForExtendedLayout属性设置为UIRectEdgeNone
   2.设置导航栏半透明属性UIBarStyleBlackTranslucent为NO
   */
  self.automaticallyAdjustsScrollViewInsets =
      NO;  //关闭系统scrollview 布局自动调整
  self.array = @[
    @[
      @"PlayerViewController",
      @"YddImagePickerViewController",
      @"MyImagePickerViewController",
      @"MyTableViewController",
      @"AnimationViewController",
      @"BarrageViewController",
      @"GraffitiViewController",
      @"IFlyViewController",
      @"SpeekViewController",
      @"HZAViewController",
      @"VoiceToWordViewController",
      @"IntrinsicViewController",
      @"CameraViewController",
      @"MySpeekViewController",
      @"ZhengZeViewController",
      @"AVCaptureSessionViewController",
      @"BezierPathViewController",
      @"DrawImageColorViewController",
      @"MutableThreadViewController",
      @"GameLiveHomeViewController",
      @"PresentationViewController",
      @"TQIOSViewController",
      @"TestCollectionCellPLayCollectionViewController",
      @"HardwareViewController",
      @"PCMTOWAVViewController",
      @"CustomPushAnimateViewController",
      @"OperatorViewController",
      @"MyURLClickViewController",
      @"StrToEmojiViewController",
      @"ThreadViewController",
      @"VoiceViewController",
      @"AudioUnitViewController",
      @"TestDownloadViewController",
      @"MyCollectionViewController",
      @"TestImageCollectionViewController",
      @"MyWebViewViewController",
      @"RuntimeViewController",
      @"InvocationMethodViewController",
      @"MyTextViewViewController",
      @"GifViewController",
      @"ISVideoSessionViewController",
      @"H264DecodeViewController",
      @"ISPhotoAlbumViewController",
      @"AudioQueueViewController",
      @"SaveCustomViewController",
      @"ScreenShotViewController",
      @"RunLoopViewController",
      @"TestKVOViewController",
      @"TestResponderViewController"
    ],
    @[
      @"CoreTextViewController", @"CTViewController",
      @"CoreTextTowViewController", @"MyCoreTextTestViewController",
      @"CoreTextSurroundViewController"
    ],
    @[ @"MyViewController", @"ClosureViewController", @"UserInfoController", @"SwiftJSONViewController" ]
  ];

  
  _myTestMtbArray =
      [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
  CGFloat navigMaxY = IS_iPhoneX ? 24 + 64 : 64;
  CGFloat tabHight = IS_iPhoneX ? 49 + 34 : 49;
  self.myTableView = [[UITableView alloc]
      initWithFrame:CGRectMake(0, navigMaxY, ScreenWidth, ScreenHeight - navigMaxY - tabHight)
              style:UITableViewStylePlain];
  self.myTableView.delegate = self;
  self.myTableView.dataSource = self;

  [self.view addSubview:self.myTableView];

  self.myTableView.estimatedRowHeight = 0;
  self.myTableView.estimatedSectionFooterHeight = 0;
  self.myTableView.estimatedSectionHeaderHeight = 0;
  if (@available(iOS 11.0, *)) {
    [UIScrollView appearance].contentInsetAdjustmentBehavior =
        UIScrollViewContentInsetAdjustmentNever;
  } else {
    // Fallback on earlier versions
  }

  [self.myTableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"reuse"];
  //    MyModule *myModule = [MyModule mymodule];
  //    NSString *str = [myModule getMyModuleTypeWithTag:0];
  //    NSLog(@"%@", str);
  
  
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForHeaderInSection:(NSInteger)section {
  return 30;
}

- (NSString*)tableView:(UITableView*)tableView
    titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"object_c";
  } else if (section == 1) {
    return @"图文混排";
  } else {
    return @"swift";
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return self.array.count;
}

- (NSInteger)tableView:(UITableView*)tableView
    numberOfRowsInSection:(NSInteger)section {
  NSArray* array = self.array[section];
  return array.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  UITableViewCell* cell =
      [tableView dequeueReusableCellWithIdentifier:@"reuse"
                                      forIndexPath:indexPath];
  NSArray* array = [self.array objectAtIndex:indexPath.section];
  cell.textLabel.text = [array objectAtIndex:indexPath.row];

  return cell;
}

- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];

  if (indexPath.section < 2) {
    NSArray* array = self.array[indexPath.section];
    NSString* itemStr = array[indexPath.row];
    if ([itemStr isEqualToString:
                     @"TestCollectionCellPLayCollectionViewController"]) {
      UICollectionViewFlowLayout* flayout =
          [[UICollectionViewFlowLayout alloc] init];
      flayout.scrollDirection = UICollectionViewScrollDirectionVertical;
      TestCollectionCellPLayCollectionViewController* testVC =
          [[TestCollectionCellPLayCollectionViewController alloc]
              initWithCollectionViewLayout:flayout];
      self.hidesBottomBarWhenPushed = YES;
      [self.navigationController pushViewController:testVC animated:YES];
      self.hidesBottomBarWhenPushed = NO;
      return;
    }
    Class class = NSClassFromString(itemStr);
    if (class) {
      UIViewController* viewController = class.new;
      if ([viewController isKindOfClass:[MyImagePickerViewController class]] ||
          [viewController
              isKindOfClass:[AVCaptureSessionViewController class]] ||
          [viewController isKindOfClass:[PresentationViewController class]]) {
        [self presentViewController:viewController animated:YES completion:nil];
        return;
      } else if ([viewController isKindOfClass:[ISPhotoAlbumViewController class]]) {
        NSArray *albumListArray = [[ISAssetsManager sharedInstancetype]
                                   fetchAllAlbumsWithAlbumContentTypeShowEmptyAlbum:NO
                                   showSmartAlbum:NO];
        ((ISPhotoAlbumViewController*)viewController).assetCollection = albumListArray.firstObject;
      }
      self.hidesBottomBarWhenPushed = YES;
      viewController.title = itemStr;
      //        viewController.view.backgroundColor = [UIColor whiteColor];
      [self.navigationController pushViewController:viewController
                                           animated:YES];
      self.hidesBottomBarWhenPushed = NO;
    }
  } else {
    self.hidesBottomBarWhenPushed = YES;
    NSArray* array = self.array[indexPath.section];
    NSString* itemStr = array[indexPath.row];
    if ([itemStr isEqualToString:@"MyViewController"]) {
      [self pushSwiftViewController];
    } else if ([itemStr isEqualToString:@"ClosureViewController"]) {
      ClosureViewController* viewController = [ClosureViewController new];
      viewController.title = itemStr;
      viewController.view.backgroundColor = [UIColor whiteColor];
      [self.navigationController pushViewController:viewController
                                           animated:YES];
    } else if ([itemStr isEqualToString:@"UserInfoController"]) {
      UserInfoController *infoVC = [[UserInfoController alloc] init];
      [self.navigationController pushViewController:infoVC animated:YES];
    } else if ([itemStr isEqualToString:@"SwiftJSONViewController"]) {
      SwiftJSONViewController *jsonVC = [[SwiftJSONViewController alloc] init];
      [self.navigationController pushViewController:jsonVC animated:YES];
    }
    self.hidesBottomBarWhenPushed = NO;
  }
}

- (void)pushMyCoreTextViewController {
  CoreTextViewController* coreText = [[CoreTextViewController alloc] init];
  coreText.view.backgroundColor = [UIColor whiteColor];
  coreText.navigationController.title = @"CoreText";
  [self.navigationController pushViewController:coreText animated:YES];
}

- (void)pushSwiftViewController {
  MyViewController* myViewController = [[MyViewController alloc] init];
  myViewController.testArray = [NSMutableArray arrayWithArray:_myTestMtbArray];
  myViewController.p_testArray = _myTestMtbArray;
  NSMutableArray* array = _myTestMtbArray;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [_myTestMtbArray removeLastObject];
                   NSLog(@"array = %@", array);
                 });
  [self.navigationController pushViewController:myViewController animated:YES];
  //    [self.navigationController presentViewController:myViewController
  //    animated:YES completion:nil];
  //    [self presentSemiViewController:myViewController withOptions:@{
  //                                                                  KNSemiModalOptionKeys.pushParentBack
  //                                                                  : @(YES),
  //                                                                  KNSemiModalOptionKeys.animationDuration
  //                                                                  : @(0.6),
  //                                                                  KNSemiModalOptionKeys.shadowOpacity
  //                                                                  : @(0.3),
  //                                                                  KNSemiModalOptionKeys.backgroundView
  //                                                                  :
  //                                                                  [[UIImageView
  //                                                                  alloc]
  //                                                                  initWithImage:[UIImage
  //                                                                  imageNamed:@"background_01"]]
  //                                                                  }];
}

- (void)pushAnimationViewController {
  AnimationViewController* animationViewController =
      [[AnimationViewController alloc] init];
  [self.navigationController pushViewController:animationViewController
                                       animated:YES];
}

- (void)pushMyTableViewController {
  MyTableViewController* myTableViewController =
      [[MyTableViewController alloc] init];
  [self.navigationController pushViewController:myTableViewController
                                       animated:YES];
}


- (void)pushYddImagePickerViewController {
  YddImagePickerViewController* imagePickerVC =
      [[YddImagePickerViewController alloc] init];
  imagePickerVC.isCamera = YES;
  [self.navigationController pushViewController:imagePickerVC animated:YES];
}

- (void)pushMyImagePickerViewController {
  MyImagePickerViewController* myImageVC =
      [[MyImagePickerViewController alloc] init];
  [self.navigationController pushViewController:myImageVC animated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
