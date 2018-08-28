//
//  EditingPublishingDynamicViewController.m
//  iShow
//
//  Created by 胡阳阳 on 17/3/18.
//
//

#import "EditingPublishingDynamicViewController.h"
#import "MBProgressHUD.h"
#import "QiniuSDK.h"
// #import "AFNetworking.h"
// #import <CoreLocation/CoreLocation.h>
// #import "ISFriendInfoViewController.h"
#import "ISAlbumListViewController.h"
#import "ISVideoCameraTools.h"
#import "ISActionSheet.h"

#import "ISPublishTextView.h"
#import "ISPublishSettingPrice.h"

#import "ChannelStructure.h"
#import "ISViewUtil.h"
#import "ISPublishDynamicTools.h"
#import "CSRSheetPickView.h"
#import "ISConfigDataManager.h"
#import "Tools.h"

#import "AFNetworking.h"
#import "ISHUDManager.h"
// 活动详情页
#import "ActivityCenterViewController.h"

#define SCREEN_LayoutScaleBaseOnIPHEN6(x) \
  (([UIScreen mainScreen].bounds.size.width) / 375.00 * x)
#define kSignatureContextLengths 20

#define COLOR_FONT_LIGHTGRAY 0x999999
#define COLOR_LINEVIEW_DARKGRAY 0x666666
#define COLOR_BACKBG_DARKGRAY 0x666666
#define COLOR_FONT_YELLOW 0xFDD854
#define COLOR_FONT_WHITE 0xFFFFFF
#define CHANGE_IMG_TAG 1001

#define RGB16(rgbValue)                                                \
  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                  green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
                   blue:((float)(rgbValue & 0xFF)) / 255.0             \
                  alpha:1.0]

@interface EditingPublishingDynamicViewController () <
    UITextViewDelegate,
    PublishTextFieldDelegate> {
  MBProgressHUD* HUD;
  BOOL isExceed_cai;
  NSString* choosePriceStr;
  NSInteger minPrice;
  NSInteger maxPrice;
}

@property(nonatomic, strong) ISPublishTextView* publishTextView;
@property(nonatomic, strong) ISPublishSettingPrice* publishSetPriceView;

@property(nonatomic, strong) UIImage* videoCoverImg;

@property(strong, nonatomic) UILabel* limitLabel;
@property(strong, nonatomic) UITextView* contentTextField;

@property(nonatomic, strong) UIImageView* videoCoverImageView;
@property(nonatomic, strong) UIView* videoAndCoverView;
@property(nonatomic, strong) UIView* coverView;

// 礼物模型
@property(nonatomic, strong) GiftInfoStructure* giftModel;

@property(nonatomic, strong) NSMutableArray* settingPricePickerViewArray;

@end

@implementation EditingPublishingDynamicViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    _activeId = 0;
    _actTitle = @"";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [[IQKeyboardManager sharedManager] setEnable:YES];
  [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
  [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;

  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  self.view.backgroundColor = [UIColor whiteColor];

  [self setupNavigationBarView];

  NSString* videoURLString = [[_videoURL absoluteString]
      stringByReplacingOccurrencesOfString:@"file://"
                                withString:@""];
  _videoCoverImg =
      [[AppDelegate appDelegate].cmImageSize getImage:videoURLString];

  UIScrollView* scrollView = [[UIScrollView alloc]
      initWithFrame:CGRectMake(0, kStatusAndNavBarHeight, ScreenWidth,
                               ScreenHeight - kStatusAndNavBarHeight)];
  [self.view addSubview:scrollView];
  if (_isPriveteDynamicType) {
    scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenWidth + 292.0);
  } else {
    scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenWidth + 130.0);
  }

  UIView* itemSuperView = scrollView;

  _videoAndCoverView = [self setupVideoAndCoverView];
  itemSuperView.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
  [itemSuperView addSubview:_videoAndCoverView];
  _videoAndCoverView.frame =
      CGRectMake(0, 0, CGRectGetWidth(itemSuperView.frame),
                 CGRectGetWidth(itemSuperView.frame));
  //
  CGFloat textLength =
      [ISViewUtil calculateTextLengthWithFont:[UIFont systemFontOfSize:15.0]
                                         text:@"保存到本地"] +
      30.0;

  UIButton* changeVideoBackgroundImageButton =
      [UIButton buttonWithType:UIButtonTypeCustom];
  changeVideoBackgroundImageButton.titleLabel.font =
      [UIFont systemFontOfSize:15.0];
  [changeVideoBackgroundImageButton setTitleColor:[UIColor whiteColor]
                                         forState:UIControlStateNormal];
  changeVideoBackgroundImageButton.backgroundColor =
      [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
  [changeVideoBackgroundImageButton setTitle:@"更换封面"
                                    forState:UIControlStateNormal];
  changeVideoBackgroundImageButton.layer.cornerRadius = 17.5;
  changeVideoBackgroundImageButton.clipsToBounds = YES;
  [changeVideoBackgroundImageButton
             addTarget:self
                action:@selector(changeVideoBackgroundImageButtonClick:)
      forControlEvents:UIControlEventTouchUpInside];
  [_videoAndCoverView addSubview:changeVideoBackgroundImageButton];
  [changeVideoBackgroundImageButton
      mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.mas_equalTo((ScreenWidth - textLength * 2 - 20) / 2);
        make.bottom.equalTo(_videoAndCoverView.mas_bottom).with.offset(-20.0);
        make.size.mas_equalTo(CGSizeMake(textLength, 35));
      }];

  NSString* placeHolderStr = @"写点什么吧~~";
  if (_activeId > 0) {
    placeHolderStr =
        [NSString stringWithFormat:@" #%@#写点什么吧~~", _actTitle];
  }
  // placeHolderStr = [NSString stringWithFormat:@"%@",placeHolderStr];
  _publishTextView =
      [[ISPublishTextView alloc] initWithPlaceHolder:placeHolderStr
                                            maxCount:100];
  [itemSuperView addSubview:_publishTextView];
  _publishTextView.frame =
      CGRectMake(0, CGRectGetMaxY(_videoAndCoverView.frame), ScreenWidth, 162);
  self.contentTextField = _publishTextView.signTextView;
  if (_isPriveteDynamicType) {
    _publishSetPriceView =
        [[ISPublishSettingPrice alloc] initWithTitle:@"设置价格"
                                           giftModel:self.giftModel];
    [itemSuperView addSubview:_publishSetPriceView];
    _publishSetPriceView.frame =
        CGRectMake(0, CGRectGetMaxY(_publishTextView.frame), ScreenWidth, 90);
    _publishSetPriceView.delegate = self;
    minPrice = _publishSetPriceView.minPrice;
    maxPrice = _publishSetPriceView.maxPrice;
  } else {
    if (_publishSetPriceView) {
      [_publishSetPriceView removeFromSuperview];
      [self setPublishSetPriceView:nil];
    }
  }
  [self setLayoutCoverView];
  [self updateNavigationBarView];

  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(getNewCoverImage:)
             name:@"IS_EDIT_DYNAMIC_VIDEO_COVER"
           object:nil];
  // 异地登录
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(backToRootViewControl)
             name:kExitTaiKuRtmpPlayPageNotify
           object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [ISPageStatisticsManager pageviewStartWithName:[self navigationBarTitle]];
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [ISPageStatisticsManager pageviewEndWithName:[self navigationBarTitle]];
  [super viewDidDisappear:animated];
}

- (UIView*)setupVideoAndCoverView {
  UIView* videoAndCoverView = [[UIView alloc] init];

  UIImageView* bgImgView = [[UIImageView alloc] init];
  bgImgView.image = _videoCoverImg;
  [videoAndCoverView addSubview:bgImgView];
  [bgImgView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];

  // 毛玻璃视图
  UIBlurEffect* blurEffrct =
      [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  UIVisualEffectView* visualEffectView =
      [[UIVisualEffectView alloc] initWithEffect:blurEffrct];
  visualEffectView.alpha = 0.9;
  [videoAndCoverView addSubview:visualEffectView];
  [visualEffectView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];

  _coverView = [self setupCoverView];
  [videoAndCoverView addSubview:_coverView];
  [_coverView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.centerX.equalTo(videoAndCoverView);
    make.top.equalTo(videoAndCoverView).offset(20);
    make.bottom.equalTo(videoAndCoverView).offset(-20.0);
  }];

  CGFloat textLength =
      [ISViewUtil calculateTextLengthWithFont:[UIFont systemFontOfSize:15.0]
                                         text:@"保存到本地"] +
      30.0;

  UIButton* saveVideoToLocalButton =
      [UIButton buttonWithType:UIButtonTypeCustom];
  saveVideoToLocalButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
  [saveVideoToLocalButton setTitleColor:[UIColor whiteColor]
                               forState:UIControlStateNormal];
  saveVideoToLocalButton.backgroundColor =
      [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
  //  saveVideoToLocalButton.backgroundColor =
  //      [[UIColor blackColor] colorWithAlphaComponent:0.8];
  [saveVideoToLocalButton setTitle:@"保存到本地" forState:UIControlStateNormal];
  saveVideoToLocalButton.layer.cornerRadius = 17.5;
  saveVideoToLocalButton.clipsToBounds = YES;
  [saveVideoToLocalButton addTarget:self
                             action:@selector(saveVideoToLocalButtonClick:)
                   forControlEvents:UIControlEventTouchUpInside];
  [videoAndCoverView addSubview:saveVideoToLocalButton];
  [saveVideoToLocalButton mas_makeConstraints:^(MASConstraintMaker* make) {
    make.bottom.equalTo(videoAndCoverView.mas_bottom).with.offset(-20.0);
    make.size.mas_equalTo(CGSizeMake(textLength, 35.0));
    make.right.mas_equalTo(-(ScreenWidth - textLength * 2 - 20) / 2);
  }];

  return videoAndCoverView;
}

- (UIView*)setupCoverView {
  UIView* coverView = [[UIView alloc] init];
  coverView.clipsToBounds = YES;
  coverView.layer.cornerRadius = 3.0;

  _videoCoverImageView = [[UIImageView alloc] init];
  _videoCoverImageView.image = _videoCoverImg;
  _videoCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
  _videoCoverImageView.tag = CHANGE_IMG_TAG;
  [coverView addSubview:_videoCoverImageView];
  [_videoCoverImageView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
  }];
  return coverView;
}

- (void)setupNavigationBarView {
  UIView* headerBar = [[UIView alloc] init];
  headerBar.tag = 1000;
  [self.view addSubview:headerBar];
  headerBar.backgroundColor = [UIColor whiteColor];
  [headerBar mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.equalTo(self.view).with.offset(kStatusBarHeight);
    make.left.right.equalTo(self.view);
    make.height.equalTo(@(44));
  }];

  UILabel* titleLabel = [[UILabel alloc] init];
  titleLabel.tag = 1001;
  titleLabel.font = [UIFont systemFontOfSize:18];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.textColor = [UIColor blackColor];
  [headerBar addSubview:titleLabel];
  [titleLabel mas_makeConstraints:^(MASConstraintMaker* make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];

  UIButton* leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
  leftBarButton.tag = 1002;
  [leftBarButton setTitle:@"取消" forState:UIControlStateNormal];
  [leftBarButton
      setTitleColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]
           forState:UIControlStateNormal];
  [leftBarButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
  [leftBarButton addTarget:self
                    action:@selector(leftBarButtonClick:)
          forControlEvents:UIControlEventTouchUpInside];
  [headerBar addSubview:leftBarButton];
  [leftBarButton mas_makeConstraints:^(MASConstraintMaker* make) {
    make.left.bottom.top.equalTo(headerBar);
    make.width.equalTo(@(50.0));
  }];

  UIButton* rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
  rightBarButton.tag = 1003;
  [rightBarButton setTitle:@"发布" forState:UIControlStateNormal];
  [rightBarButton
      setTitleColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]
           forState:UIControlStateNormal];
  [rightBarButton setTitleColor:[UIColor grayColor]
                       forState:UIControlStateDisabled];
  [rightBarButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
  [rightBarButton addTarget:self
                     action:@selector(rightBarButtonClick:)
           forControlEvents:UIControlEventTouchUpInside];
  [headerBar addSubview:rightBarButton];
  [rightBarButton mas_makeConstraints:^(MASConstraintMaker* make) {
    make.right.bottom.top.equalTo(headerBar);
    make.width.equalTo(@(50.0));
  }];
}

- (NSString*)navigationBarTitle {
  if (_isPriveteDynamicType) {
    return ISPageStatisticsCommonPublishPrivateVideoAlbum;
  } else {
    return ISPageStatisticsCommonPublishVideoDynamic;
  }
}

- (void)updateNavigationBarView {
  UIView* navigationBarView = [self.view viewWithTag:1000];
  UILabel* titleLabel = (UILabel*)[navigationBarView viewWithTag:1001];
  titleLabel.text = [self navigationBarTitle];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // 纪录当前页
  [AppDelegate appDelegate].ssSpeedingPushTag =
      SPEEDINGPUSHTAG_DynamicPublishVedio;

  // 、self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
  // 隐藏状态栏
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  // 键盘
  [[IQKeyboardManager sharedManager] setEnable:YES];
  [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
  [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  // 键盘
  [[IQKeyboardManager sharedManager] setEnable:NO];
}

#pragma mark - PublishTextFieldDelegate
- (void)textFiledChangedEvent:(UITextField*)textField {
  // 过滤表情
  BOOL isHasEmoji = IOSTools::containEmoji(textField.text);
  if (isHasEmoji) {
    [self.view endEditing:YES];
    [[AppDelegate appDelegate]
        appDontCoverLoadingViewShowForContext:@"不能包含特殊字符!"
                                  ForTypeShow:1
                       ForChangeFrameSizeType:0
                                  ForFrameFlg:0
                                ForCancelTime:2.0];
    return;
  }

  // 记录选择的价格
  choosePriceStr =
      [NSString stringWithFormat:@"%d", [textField.text intValue] / 1];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  [_contentTextField resignFirstResponder];
}

#pragma mark - textViewDelegate -

- (BOOL)textViewShouldBeginEditing:(UITextView*)textView {
  if (textView.tag == 0) {
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    textView.tag = 1;
  }
  return YES;
}

- (void)textViewDidChange:(UITextView*)textView {
  NSString* lengthString;
  if ([textView.text length] > kSignatureContextLengths) {
    lengthString =
        [[NSString alloc] initWithFormat:@"内容超出:%lu/%d",
                                         (unsigned long)[textView.text length],
                                         kSignatureContextLengths];
    _limitLabel.textColor = [UIColor redColor];
    isExceed_cai = YES;
  } else {
    lengthString = [[NSString alloc]
        initWithFormat:@"%lu/%d", (unsigned long)[textView.text length],
                       kSignatureContextLengths];
    _limitLabel.textColor = [UIColor blackColor];
    isExceed_cai = NO;
  }
  _limitLabel.text = lengthString;
}

- (BOOL)textViewShouldEndEditing:(UITextView*)textView {
  if ([textView.text length] == 0) {
    NSString* placeHolderStr = @"写点什么吧~~";
    if (_activeId > 0) {
      placeHolderStr =
          [NSString stringWithFormat:@" #%@#写点什么吧~~", _actTitle];
    }
    textView.textColor = [UIColor lightGrayColor];
    textView.tag = 0;
  }
  return YES;
}

// 点击键盘完成后 收键盘
- (BOOL)textView:(UITextView*)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString*)text {
  if ([text isEqualToString:@"\n"]) {
    [_contentTextField resignFirstResponder];
    return NO;
  }

  return YES;
}

- (GiftInfoStructure*)giftModel {
  if (!_giftModel) {
    _giftModel = [self getPrivatePhotoStructure];
  }
  return _giftModel;
}

// 私密照礼物字典
- (GiftInfoStructure*)getPrivatePhotoStructure {
  NSMutableArray* privatePhotosGroupArray =
      [[AppDelegate appDelegate]
              .appGeneralProperty.privatePhotosGiftMtbDictionary
          objectForKey:kDKey];
  if ([privatePhotosGroupArray count] > 0) {
    PresentGroupStructure* presentGroupStructure =
        [privatePhotosGroupArray objectAtIndex:0];
    NSArray* giftArray = presentGroupStructure.presentGroupMtbArray;

    for (GiftInfoStructure* giftInfoStructure in giftArray) {
      if (giftInfoStructure) {
        // 当私密照礼物存在多个时，优先使用第一个礼物数据
        return giftInfoStructure;
      }
    }
  }
  return [GiftInfoStructure alloc];
}

- (void)leftBarButtonClick:(id)sender {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 保存到相册

- (void)saveVideoToLocalButtonClick:(UIButton*)sender {
  HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  HUD.labelText = @"保存成功";
  [HUD hide:YES afterDelay:1.0];
  UISaveVideoAtPathToSavedPhotosAlbum(
      [[_videoURL absoluteString]
          stringByReplacingOccurrencesOfString:@"file://"
                                    withString:@""],
      nil, nil, nil);
}
#pragma mark - 发布视频 -
// 右上角按钮
- (void)rightBarButtonClick:(UIButton*)sender {
  // 判断网络
  BOOL is_yes = [[AppDelegate appDelegate] thirdNetworkNotReportStateDetection];
  if (is_yes == NO) {
    [[AppDelegate appDelegate] appDontCoverLoadingViewShowForContext:
                                   kNETWORH_AVAILABLE_NOTHAVE_AVAILABLE
                                                         ForTypeShow:1
                                              ForChangeFrameSizeType:0
                                                         ForFrameFlg:0
                                                       ForCancelTime:2.0];
    return;
  }

  /*私密专辑需要主播权限
  if (self.isPriveteDynamicType == ISPublishDynamicPrivite) {
      // 判断主播
      [self getTheUserIsTheHostWithFlg:0];
  }
  else {
      [self limitCondetion];
  }
   */

  [self limitCondetion];
}

// 限制条件
- (void)limitCondetion {
  // 判断字数
  NSString* contentStr = self.publishTextView.signTextView.text;
  if ([contentStr length] > 100) {
    // 提示不超过100
    [[AppDelegate appDelegate]
        appDontCoverLoadingViewShowForContext:@"输入文字不能超过100个"
                                  ForTypeShow:1
                       ForChangeFrameSizeType:0
                                  ForFrameFlg:0
                                ForCancelTime:2.0];
    [self.view endEditing:YES];
    return;
  }
  if (![[AppDelegate appDelegate].cmCommonMethod
          isspecialCharacters:contentStr]) {
    // 特殊表情
    [self.view endEditing:YES];
      [[AppDelegate appDelegate]
       appDontCoverLoadingViewShowForContext:@"不能包含特殊字符!"
       ForTypeShow:1
       ForChangeFrameSizeType:0
       ForFrameFlg:0
       ForCancelTime:2.0];
    return;
  }
  else {
      BOOL isHasEmoji = IOSTools::containEmoji(contentStr);
      if (isHasEmoji) {
          // 特殊表情
          [self.view endEditing:YES];
          [[AppDelegate appDelegate]
           appDontCoverLoadingViewShowForContext:@"不能包含表情!"
           ForTypeShow:1
           ForChangeFrameSizeType:0
           ForFrameFlg:0
           ForCancelTime:2.0];
          return;
      }
  }

  // 私密状态
  if (self.isPriveteDynamicType == ISPublishDynamicPrivite) {
    // 价格
    if (self.publishSetPriceView.textField.text.length == 0) {
      [[AppDelegate appDelegate]
          appDontCoverLoadingViewShowForContext:@"请设置专辑的价格"
                                    ForTypeShow:1
                         ForChangeFrameSizeType:0
                                    ForFrameFlg:0
                                  ForCancelTime:2.0];
      [self performSelector:@selector(textFieldBecomeFirstResponder)
                 withObject:self
                 afterDelay:2.0];
      return;
    }
    // 设置数值范围
    NSInteger giftCount =
        [self.publishSetPriceView.textField.text integerValue];
    if (giftCount < minPrice || giftCount > maxPrice) {
      if ([self.publishSetPriceView.textField isFirstResponder]) {
        [self.publishSetPriceView.textField resignFirstResponder];
      }

      // NSString *tips = [NSString stringWithFormat:@"请输入%ld-%ld以内的整数",
      // minPrice, maxPrice];
      NSString* giftExName = ([self.giftModel.exnameString length] > 0)
                                 ? self.giftModel.exnameString
                                 : @"朵";
      NSString* giftName = ([self.giftModel.presentNameString length] > 0)
                               ? self.giftModel.presentNameString
                               : @"玫瑰";
      NSString* tips =
          [NSString stringWithFormat:@"价格有效范围%ld-%ld%@%@", (long)minPrice,
                                     (long)maxPrice, giftExName, giftName];
      [[AppDelegate appDelegate] appDontCoverLoadingViewShowForContext:tips
                                                           ForTypeShow:1
                                                ForChangeFrameSizeType:0
                                                           ForFrameFlg:0
                                                         ForCancelTime:2.0];
      return;
    }
  }

  // 发布
  [self publishDynamicToServers];
  // 返回
  [self backToRootViewControl];
}

#if 0
// 获取是否是主播
- (void)getTheUserIsTheHostWithFlg:(int)flag {
  
    ISHUDManager *hudManager = [ISHUDManager manager];
    dispatch_async(dispatch_get_main_queue(), ^{
        [hudManager IS_show_HUD_type:ISHUDCycle text:@"" enable:NO afterDelay:0];
    });
  
    [[AppDelegate appDelegate].cmCommonMethod getdateSeverForFlg:0 forBack:^(unsigned int timestamp) {
        NSString *apiString = nil;
        if (flag == 0) {
            apiString = kAllAPIURL;
        }else if (flag == 1) {
            apiString = kAllAPIURL2;
        }else {
            apiString = kAllAPIURL3;
        }
      
        NSString *hoststring = [NSString stringWithFormat:@"live/%d/sign",[AppDelegate appDelegate].appDelegatePlatformUserStructure.platformUserId];
        NSDictionary *dict = @{@"sign_type":@"sign_type=md5",@"time":[NSString stringWithFormat:@"time=%d",timestamp]};
        NSString *keystring = kIShowAllRequestKey;
        NSArray *cmArray = [NSArray arrayWithObjects:hoststring,dict,keystring, nil];
        [[AppDelegate appDelegate].cmCommonMethod cmSignOneKeyTypesettingAndEncryptionForDict:cmArray blockcompletion:^(NSString *md5SignString) {
            NSString* requesturl = [NSString stringWithFormat:@"%@%@?sign_type=md5&time=%d&sign=%@",apiString,hoststring,timestamp,md5SignString];
          
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript",nil];
            [manager GET:requesturl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [hudManager IS_hidden_HUD_normal];
                int error_code = -1;
                NSDictionary* responseDic = nil;
                if (responseObject != nil) {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        responseDic = responseObject;
                        if ([responseDic objectForKey:@"code"]) {
                            error_code = [[responseDic objectForKey:@"code"] intValue];
                            if (error_code == 0) {
                                [[AppDelegate appDelegate].appDelegatePlatformUserStructure.ksyDic setValuesForKeysWithDictionary:responseDic];
                                //
                                if ([responseDic objectForKey:@"signed_showid"] && ![[responseDic objectForKey:@"signed_showid"]isKindOfClass:[NSNull class]]) {
                                    [AppDelegate appDelegate].appDelegatePlatformUserStructure.signedShowid = [[responseDic objectForKey:@"signed_showid"]integerValue];
                                }
                                //
                                NSString *showroomidString = [[AppDelegate appDelegate].cmCommonMethod cmGetDictionaryOfValueForKey:@"showid" forDict:[AppDelegate appDelegate].appDelegatePlatformUserStructure.ksyDic];
                              
                              
                                if (showroomidString != nil && ![showroomidString isEqualToString:@" "] && ![showroomidString isEqualToString:@"0"])
                                {
                                  
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self limitCondetion];
                                        [hudManager IS_hidden_HUD_normal];
                                    });
                                }
                                else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        // [hudManager IS_show_HUD_type:ISHUDCycle text:@"暂未开放" enable:NO afterDelay:1.5];
                                        [[AppDelegate appDelegate] cancelCmLoadingView:0];
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                                            message:@"稍后开放，敬请期待！"
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:@"关闭"
                                                                                  otherButtonTitles:nil, nil];
                                        [alertView show];
                                    });
                                }
                            }
                        }
                    }
                }
                if (error_code != 0) {
                    NSString *errorStr = @"";
                    switch (error_code) {
                        case 403:
                            errorStr = @"您已被禁播，\n请与管理员联系";
                            break;
                        
                        default:
                            errorStr = [NSString stringWithFormat:@"code = %@",errorStr];
                            break;
                    }
                    // 弹框
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hudManager IS_show_HUD_type:ISHUDFailure text:errorStr enable:YES afterDelay:2.0];
                    });
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (flag < 2) {
                    [self getTheUserIsTheHostWithFlg:flag + 1];
                    return;
                }
                // 弹框
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hudManager IS_show_HUD_type:ISHUDFailure text:kOffline enable:YES afterDelay:2.0];
                });
            }];
        }];
    }];
}
#endif

- (void)textFieldBecomeFirstResponder {
  if (![self.publishSetPriceView.textField isFirstResponder]) {
    [self.publishSetPriceView.textField becomeFirstResponder];
  }
}

// 发布
- (void)publishDynamicToServers {
  NSString* contentStr = _contentTextField.text;
  // 字符串去掉前后空行， 中间有多个空行，保留一个
  // 设计 臧萌萌 修改者caoshurun 2018/01/08
  contentStr = [contentStr trimmingStringByDynamicRegular];
  // 发布录制动态小视频
  ISPublishVideoModel* model = [[ISPublishVideoModel alloc] init];
  model.isPrivateViedo = _isPriveteDynamicType;
  model.videoURL = _videoURL;
  model.coverImage = _videoCoverImg;
  model.contentStr = contentStr;
  model.privatePrice = [choosePriceStr integerValue];
  model.page = _pageFromFlg;  // 来源页面
  model.activeId = _activeId;
  model.actTitle = _actTitle;
  ISPublishDynamicTools* tools = [ISPublishDynamicTools sharePublishTolls];
  [tools uploadVideo:model];
}

// 返回
- (void)backToRootViewControl {
  // 首页
  [[ISPublishDynamicTools sharePublishTolls]
      processDynaicTipViewStateByChangeAccountLogic];

  if (self.pageFromFlg == ISPublishDynamicProgressPageHome) {
    //
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTabBarHiddenNONotification
                      object:self];
    // [[AppDelegate appDelegate].appViewService
    // tabbarFOrSelectedIndex:kHomepageviewIndexD];

  }
  // 活动
  else if (self.pageFromFlg == ISPublishDynamicProgressPageActive) {
    for (UINavigationController* control in self.navigationController
             .viewControllers) {
      if ([control isKindOfClass:[ActivityCenterViewController class]]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kTabBarHiddenYESNotification
                          object:self];
        ActivityCenterViewController* activeControl =
            (ActivityCenterViewController*)control;
        [self.navigationController popToViewController:activeControl
                                              animated:YES];
      }
    }
  } else {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kTabBarHiddenNONotification
                      object:self];
    [self.navigationController
        popToViewController:self.navigationController.viewControllers[1]
                   animated:YES];
  }
}

#pragma mark - 更换封面照 -
// 更换封面
- (void)changeVideoBackgroundImageButtonClick:(UIButton*)sender {
  [self.view endEditing:YES];  // 结束编辑
  ISActionSheet* actionSheet = [ISActionSheet
      actionSheetWithStyle:ISActionSheetStyleWeChat
                     title:nil
                optionsArr:@[ @"从相册选择" ]
               cancelTitle:@"取消"
             selectedBlock:^(NSInteger row, NSString* _Nonnull title) {
               [self getImageFormSystemAlbum];
             }
               cancelBlock:^{

               }];
  [actionSheet showInView:self.view];
}

- (void)getImageFormSystemAlbum {
  if ([UIImagePickerController
          isSourceTypeAvailable:
              UIImagePickerControllerSourceTypePhotoLibrary]) {
    ISAlbumListViewController* albumListView =
        [[ISAlbumListViewController alloc] init];
    albumListView.albumType = CONTACT_PHOTOLIST_WITH_DYNAMIC_VIDEO_COVER;
    UIViewController* currentVC =
        [[AppDelegate appDelegate] getNewCurrentViewController];
    currentVC.hidesBottomBarWhenPushed = YES;
    [currentVC presentViewController:albumListView animated:NO completion:nil];
  } else {
    [[AppDelegate appDelegate]
        appDontCoverLoadingViewShowForContext:kDontSupportPhoto
                                  ForTypeShow:1
                       ForChangeFrameSizeType:0
                                  ForFrameFlg:YES
                                ForCancelTime:2.0];
  }
}

- (void)getNewCoverImage:(NSNotification*)noti {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self getAlbumPhotoImageWithDic:noti.userInfo];
  });
}
// SendHostCoverImageForPrepareLiveView
- (void)getAlbumPhotoImageWithDic:(NSDictionary*)albumDic {
  UIImage* photoImage = [albumDic objectForKey:@"AssetPhotoImage"];
  _videoCoverImg = photoImage;
  _videoCoverImageView.image = photoImage;
  [self setLayoutCoverView];
}
- (void)setLayoutCoverView {
  CGSize size = [self changeImageSize];
  [_coverView mas_updateConstraints:^(MASConstraintMaker* make) {
    make.width.mas_equalTo(size.width);
    make.height.mas_equalTo(size.height);
    make.top.mas_equalTo(
        (self.videoAndCoverView.frame.size.height - size.height) / 2);
    make.bottom.mas_equalTo(
        -(self.videoAndCoverView.frame.size.height - size.height) / 2);
  }];
}
#pragma mark 计算图片比例大小{
- (CGSize)changeImageSize {
  UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
  CGFloat width = (self.videoAndCoverView.size.width - contentInsets.left -
                   contentInsets.right);
  CGFloat height = (self.videoAndCoverView.frame.size.height -
                    contentInsets.top - contentInsets.bottom);
  CGFloat maxW = width - 5;
  CGFloat maxH = height - 5;
  CGFloat whScale = _videoCoverImg.size.width / _videoCoverImg.size.height;
  CGFloat w = maxW;
  CGFloat h = w / whScale;
  if (h > maxH) {
    h = maxH;
    w = h * whScale;
  }
  CGSize imagesize;
  imagesize.width = w;
  imagesize.height = h;
  return imagesize;
}
#pragma mark }
#pragma mark - other -

- (void)dealloc {
  ISLog(@"%@释放了", self.class);
  // 关闭三方键盘
  [[IQKeyboardManager sharedManager] setEnable:NO];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
@end
