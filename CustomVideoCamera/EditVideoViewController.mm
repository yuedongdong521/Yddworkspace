//
// EditVideoViewController.m
// iShow
//
// Created by ydd on 17/3/8.
//
//

#import "EditVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "MusicItemCollectionViewCell.h"

#import "MBProgressHUD.h"
 #import "SDAVAssetExportSession.h"
#import "GPUImage.h"
#import "LFGPUImageEmptyFilter.h"
#import "ISVideoCameraTools.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_LayoutScaleBaseOnIPHEN6(x) \
  (([UIScreen mainScreen].bounds.size.width) / 375.00 * x)

#pragma mark - MusicData -
@interface MusicData : NSObject

@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* eid;
@property(nonatomic, strong) NSString* musicPath;
@property(nonatomic, strong) NSString* iconPath;
@property(nonatomic, assign) BOOL isSelected;

@end
@implementation MusicData

@end

#pragma mark - filterData -
@interface FilterData : NSObject

@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* value;
@property(nonatomic, strong) NSString* fillterName;
@property(nonatomic, strong) NSString* iconPath;
@property(nonatomic, assign) BOOL isSelected;

@end
@implementation FilterData

@end

#pragma mark - EditVideoViewController -
typedef NS_ENUM(NSUInteger, choseType) {
  choseFilter = 1,  // 滤镜
  choseMusic = 2,  // 音乐
};

@interface EditVideoViewController () <UITextFieldDelegate,
                                       UICollectionViewDelegate,
                                       UICollectionViewDataSource>

@property(nonatomic, strong) AVPlayer* audioPlayer;
@property(nonatomic, strong) NSMutableArray<MusicData*>* musicAry;
@property(nonatomic, strong) NSMutableArray<FilterData*>* filterAry;
@property(nonatomic, strong) UIVisualEffectView*
    visualEffectView;  // 毛玻璃效果的背景 （滤镜，音乐视图）
@property(nonatomic, strong) UIView* musicBottomBar;  // 底部滤镜 音乐视图
@property(nonatomic, strong) NSString* audioPath;

@property(nonatomic, strong) NSString* filtClassName;
@property(nonatomic, assign) BOOL isdoing;
@property(nonatomic, assign) choseType choseEditType;  // 滤镜 音乐 的编辑类型
@property(nonatomic, strong)
    UICollectionView* musicCollectionView;  // 音乐 collectionView
@property(nonatomic, strong)
    UICollectionView* collectionView;  // 滤镜 collectionView
@property(nonatomic, strong) UIButton* filterBtn;  // 滤镜 按钮
@property(nonatomic, strong) UIButton* musicBtn;  // 音乐 按钮
@property(nonatomic, strong)
    UIButton* editTheOriginaBtn;  // 剔除原声 (switch左边的文字)
@property(nonatomic, strong) UISwitch* editTheOriginaSwitch;  // 剔除原始 switch
@property(nonatomic, strong) GPUImageView* filterView;  // 播放视频的视图
@property(nonatomic, assign) CGFloat saturationValue;
@property(nonatomic, strong) NSIndexPath* lastMusicIndex;
@property(nonatomic, strong) NSIndexPath* lastFilterIndex;
@property(nonatomic, strong)
    UIImageView* bgImageView;  // 刚进入编辑界面的 封面视图

@end

@implementation EditVideoViewController {
  GPUImageMovie* movieFile;
  GPUImageMovie* endMovieFile;
  GPUImageOutput<GPUImageInput>* filter;

  AVPlayerItem* audioPlayerItem;
  MBProgressHUD* HUD;

  AVPlayer* mainPlayer;
  AVPlayerItem* playerItem;
  GPUImageMovieWriter* movieWriter;
}

#pragma mark - life cycle -

- (instancetype)init {
  self = [super init];
  if (self) {
    _pageFromFlg = 0;
    _isPrivateAlbum = NO;
    _activeId = 0;
    _actTitle = @"";
  }
  return self;
}
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  NSLog(@"EditVideoViewController 释放了");
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _musicAry = [NSMutableArray arrayWithArray:[self creatMusicData]];
  _filterAry = [NSMutableArray arrayWithArray:[self creatFilterData]];
  _audioPlayer = [[AVPlayer alloc] init];

  _lastMusicIndex = [NSIndexPath indexPathForRow:0 inSection:0];
  _lastFilterIndex = [NSIndexPath indexPathForRow:0 inSection:0];

  [[AVAudioSession sharedInstance]
      setCategory:AVAudioSessionCategoryPlayAndRecord
      withOptions:AVAudioSessionCategoryOptionMixWithOthers
            error:nil];
  // [self playMusic];

  self.view.backgroundColor = [UIColor blackColor];
  self.title = @"预览";

  mainPlayer = [[AVPlayer alloc] init];
  playerItem = [[AVPlayerItem alloc] initWithURL:_videoURL];
  [mainPlayer replaceCurrentItemWithPlayerItem:playerItem];

  movieFile = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
  movieFile.runBenchmark = YES;
  movieFile.playAtActualSpeed = YES;

  filter = [[LFGPUImageEmptyFilter alloc] init];

  _filtClassName = @"LFGPUImageEmptyFilter";
  [movieFile addTarget:filter];

  // 播放的视图
  _filterView = [[GPUImageView alloc]
      initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
  _filterView.center = self.view.center;
  _filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
  [self.view addSubview:_filterView];
  [filter addTarget:_filterView];
  // 刚进时的静态图片
  _bgImageView = [[UIImageView alloc] init];
//  _bgImageView.image = [[AppDelegate appDelegate].cmImageSize
//      getImage:[[_videoURL absoluteString]
//                   stringByReplacingOccurrencesOfString:@"file://"
//                                             withString:@""]];
  _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
  [self.view addSubview:_bgImageView];
  [_bgImageView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.bottom.left.right.equalTo(_filterView);
  }];

  UIImageView* PlayImge = [[UIImageView alloc] init];
  PlayImge.image = [UIImage imageNamed:@"播放按钮-1"];
  [_bgImageView addSubview:PlayImge];
  [PlayImge mas_makeConstraints:^(MASConstraintMaker* make) {
    make.center.equalTo(_bgImageView);
    make.width.height.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(60)));
  }];

  // playImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
  // playImg.center = CGPointMake(videoWidth/2, videoWidth/2);
  // [playImg setImage:[UIImage imageNamed:@"videoPlay"]];
  // [playerLayer addSublayer:playImg.layer];
  // playImg.hidden = YES;

  // create ui
  // 导航栏
  CGFloat addHeight = 0;
  if (IS_IPHONE_X) {
    addHeight = 34.f;
  }
  UIView* headerBar = [[UIView alloc] init];
  [self.view addSubview:headerBar];
  headerBar.backgroundColor = [UIColor blackColor];
  [headerBar mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.left.right.equalTo(self.view);
    make.height.equalTo(@(44 + addHeight));
  }];
  headerBar.alpha = .8;

  UILabel* titleLabel = [[UILabel alloc] init];
  titleLabel.text = @"编辑";
  titleLabel.textColor = [UIColor whiteColor];
  [headerBar addSubview:titleLabel];
  [titleLabel mas_makeConstraints:^(MASConstraintMaker* make) {
    make.centerX.equalTo(headerBar);
    make.centerY.equalTo(headerBar).offset(addHeight / 2.f);
  }];

  UIButton* nextBtn = [[UIButton alloc] init];
  [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
  [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
  [nextBtn addTarget:self
                action:@selector(clickNextBtn)
      forControlEvents:UIControlEventTouchUpInside];
  [headerBar addSubview:nextBtn];
  [nextBtn mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.equalTo(headerBar).offset(addHeight);
    make.right.bottom.equalTo(headerBar);
    make.width.equalTo(@(80));
  }];
  // 返回按钮
  UIButton* BackToVideoCammer = [[UIButton alloc] init];
  [BackToVideoCammer setImage:[UIImage imageNamed:@"BackToVideoCammer"]
                     forState:UIControlStateNormal];
  [BackToVideoCammer addTarget:self
                        action:@selector(clickBackToVideoCammer)
              forControlEvents:UIControlEventTouchUpInside];
  [headerBar addSubview:BackToVideoCammer];
  [BackToVideoCammer mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.equalTo(headerBar).offset(addHeight);
    make.left.bottom.equalTo(headerBar);
    make.width.equalTo(@(60));
  }];

  // 底部滤镜 音乐视图
  _musicBottomBar = [[UIView alloc] init];
  [self.view addSubview:_musicBottomBar];
  [_musicBottomBar mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.equalTo(
        @(ScreenHeight - 160 - IS_BOTTOM_HEIGHT)) /*.offset(160)*/;
    make.left.right.equalTo(self.view);
    make.height.equalTo(@(160 + IS_BOTTOM_HEIGHT));
  }];

  UIBlurEffect* blurEffrct =
      [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  // 毛玻璃视图
  _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct];
  [_musicBottomBar addSubview:_visualEffectView];
  [_visualEffectView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.right.left.top.bottom.equalTo(_musicBottomBar);
  }];

  _filterBtn = [[UIButton alloc] init];
  [_filterBtn setTitle:@"滤镜" forState:UIControlStateNormal];
  [_filterBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
  [_filterBtn setTitleColor:[UIColor colorWithRed:250 / 256.0
                                            green:211 / 256.0
                                             blue:75 / 256.0
                                            alpha:1]
                   forState:UIControlStateSelected];
  [_filterBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
  _filterBtn.backgroundColor = [UIColor clearColor];
  [_filterBtn addTarget:self
                 action:@selector(clickFilterBtn)
       forControlEvents:UIControlEventTouchUpInside];
  [_musicBottomBar addSubview:_filterBtn];
  [_filterBtn mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.left.equalTo(_musicBottomBar);
    make.height.equalTo(@(45));
    make.width.equalTo(@(83));
  }];
  _filterBtn.selected = YES;
  self.choseEditType = choseFilter;

  _musicBtn = [[UIButton alloc] init];
  [_musicBtn setTitle:@"音乐" forState:UIControlStateNormal];
  [_musicBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
  [_musicBtn setTitleColor:[UIColor colorWithRed:250 / 256.0
                                           green:211 / 256.0
                                            blue:75 / 256.0
                                           alpha:1]
                  forState:UIControlStateSelected];
  [_musicBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
  _musicBtn.backgroundColor = [UIColor clearColor];
  [_musicBtn addTarget:self
                action:@selector(clickmusicBtn)
      forControlEvents:UIControlEventTouchUpInside];
  [_musicBottomBar addSubview:_musicBtn];
  [_musicBtn mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.equalTo(_musicBottomBar);
    make.left.equalTo(_filterBtn.mas_right).offset(0);
    make.height.equalTo(@(45));
    make.width.equalTo(@(83));
  }];

  // 剔除原始 switch
  _editTheOriginaSwitch = [[UISwitch alloc] init];
  _editTheOriginaSwitch.onTintColor = [UIColor colorWithRed:253.0 / 255
                                                      green:215.0 / 255
                                                       blue:4.0 / 255
                                                      alpha:1.0];
  [_editTheOriginaSwitch addTarget:self
                            action:@selector(clickEditOriginalBtn)
                  forControlEvents:UIControlEventTouchUpInside];
  [_musicBottomBar addSubview:_editTheOriginaSwitch];
  [_editTheOriginaSwitch mas_makeConstraints:^(MASConstraintMaker* make) {
    make.centerY.equalTo(_musicBtn);
    make.right.equalTo(_musicBottomBar).offset(-8);
    make.height.equalTo(@(30));
    make.width.equalTo(@(50));
  }];
  _editTheOriginaSwitch.hidden = YES;

  _editTheOriginaBtn = [[UIButton alloc] init];
  [_editTheOriginaBtn setTitle:@"剔除原声" forState:UIControlStateNormal];
  [_editTheOriginaBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
  [_editTheOriginaBtn setTitleColor:[UIColor colorWithRed:250 / 256.0
                                                    green:211 / 256.0
                                                     blue:75 / 256.0
                                                    alpha:1]
                           forState:UIControlStateSelected];
  [_editTheOriginaBtn setTitleColor:[UIColor grayColor]
                           forState:UIControlStateNormal];
  _editTheOriginaBtn.backgroundColor = [UIColor clearColor];
  // [_editTheOriginaBtn addTarget:self action:@selector(clickEditOriginalBtn) forControlEvents:UIControlEventTouchUpInside];
  [_musicBottomBar addSubview:_editTheOriginaBtn];
  [_editTheOriginaBtn mas_makeConstraints:^(MASConstraintMaker* make) {
    make.top.equalTo(_musicBottomBar);
    make.right.equalTo(_editTheOriginaSwitch.mas_left).offset(0);
    make.height.equalTo(@(45));
    make.width.equalTo(@(83));
  }];
  _editTheOriginaBtn.hidden = YES;

  // 滤镜 音乐下的分割线
  UIView* lineView = [[UIView alloc] init];
  lineView.backgroundColor = [UIColor grayColor];
  [_musicBottomBar addSubview:lineView];
  [lineView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.bottom.equalTo(_musicBtn);
    make.left.right.equalTo(_musicBottomBar);
    make.height.equalTo(@(.5));
  }];

  // collectionView
  UICollectionViewFlowLayout* layout =
      [[UICollectionViewFlowLayout alloc] init];
  layout.itemSize = CGSizeMake(83, 115);
  layout.estimatedItemSize = CGSizeMake(83, 115);

  // 设置分区的头视图和尾视图是否始终固定在屏幕上边和下边
  // layout.sectionFootersPinToVisibleBounds = YES;
  // layout.sectionHeadersPinToVisibleBounds = YES;

  // 设置水平滚动方向
  // 水平滚动
  layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  // 设置额外滚动区域
  layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
  // 设置cell间距
  // 设置水平间距, 注意点:系统可能会跳转(计算不准确)
  layout.minimumInteritemSpacing = 0;
  // 设置垂直间距
  layout.minimumLineSpacing = 0;
  _collectionView = [[UICollectionView alloc]
             initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 115)
      collectionViewLayout:layout];
  // 设置背景颜色
  _collectionView.backgroundColor = [UIColor clearColor];
  // 设置数据源,展示数据
  _collectionView.dataSource = self;
  // 设置代理,监听
  _collectionView.delegate = self;
  // 注册cell
  [_collectionView registerClass:[MusicItemCollectionViewCell class]
      forCellWithReuseIdentifier:@"MyCollectionCell"];
  /* 设置UICollectionView的属性 */
  // 设置滚动条
  _collectionView.showsHorizontalScrollIndicator = NO;
  _collectionView.showsVerticalScrollIndicator = NO;
  // 设置是否需要弹簧效果
  _collectionView.bounces = YES;
  [_musicBottomBar addSubview:_collectionView];

  // collectionView
  UICollectionViewFlowLayout* layout2 =
      [[UICollectionViewFlowLayout alloc] init];
  layout2.itemSize = CGSizeMake(83, 115);
  layout2.estimatedItemSize = CGSizeMake(83, 115);
  // 设置分区的头视图和尾视图是否始终固定在屏幕上边和下边
  // layout2.sectionFootersPinToVisibleBounds = YES;
  // layout2.sectionHeadersPinToVisibleBounds = YES;
  // 设置水平滚动方向
  // 水平滚动
  layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  // 设置额外滚动区域
  layout2.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
  // 设置cell间距
  // 设置水平间距, 注意点:系统可能会跳转(计算不准确)
  layout2.minimumInteritemSpacing = 0;
  // 设置垂直间距
  layout2.minimumLineSpacing = 0;

  _musicCollectionView = [[UICollectionView alloc]
             initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 115)
      collectionViewLayout:layout2];
  // 设置背景颜色
  _musicCollectionView.backgroundColor = [UIColor clearColor];
  // 设置数据源,展示数据
  _musicCollectionView.dataSource = self;
  // 设置代理,监听
  _musicCollectionView.delegate = self;

  // 注册cell
  [_musicCollectionView registerClass:[MusicItemCollectionViewCell class]
           forCellWithReuseIdentifier:@"MyCollectionCell2"];
  /*设置UICollectionView的属性 */
  // 设置滚动条
  _musicCollectionView.showsHorizontalScrollIndicator = NO;
  _musicCollectionView.showsVerticalScrollIndicator = NO;

  // 设置是否需要弹簧效果
  _musicCollectionView.bounces = YES;
  [_musicBottomBar addSubview:_musicCollectionView];
  _musicCollectionView.hidden = YES;

  HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  HUD.hidden = YES;
  // 保存到相册
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        [mainPlayer play];
        [movieFile startProcessing];
      });
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        _bgImageView.hidden = YES;
      });
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(playingEnd:)
             name:AVPlayerItemDidPlayToEndTimeNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(onApplicationWillResignActive)
             name:UIApplicationWillResignActiveNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(onApplicationDidBecomeActive)
             name:UIApplicationDidBecomeActiveNotification
           object:nil];
  /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notCloseCor)
                                                 name:@"closeVideoCamerTwo"
                                               object:nil];
     */
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [_audioPlayer pause];
  [mainPlayer pause];
  [movieFile endProcessing];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

#pragma mark - init Data -
- (NSArray*)creatMusicData {
  NSString* configPath =
      [[NSBundle mainBundle] pathForResource:@"music2" ofType:@"json"];
  NSData* configData = [NSData dataWithContentsOfFile:configPath];
  NSDictionary* dic =
      [NSJSONSerialization JSONObjectWithData:configData
                                      options:NSJSONReadingAllowFragments
                                        error:nil];
  NSArray* items = dic[@"music"];
  int i = 529;
  NSMutableArray* array = [NSMutableArray array];

  MusicData* effect = [[MusicData alloc] init];
  effect.name = @"原始";
  effect.iconPath =
      [[NSBundle mainBundle] pathForResource:@"nilMusic" ofType:@"png"];
  effect.isSelected = YES;
  [array addObject:effect];

  for (NSDictionary* item in items) {
    // NSString *path = [baseDir stringByAppendingPathComponent:item[@"resourceUrl"]];
    MusicData* effect = [[MusicData alloc] init];
    effect.name = item[@"name"];
    effect.eid = item[@"id"];
    effect.musicPath = [[NSBundle mainBundle]
        pathForResource:[NSString stringWithFormat:@"audio%d", i]
                 ofType:@"mp3"];
    effect.iconPath = [[NSBundle mainBundle]
        pathForResource:[NSString stringWithFormat:@"icon%d", i]
                 ofType:@"png"];
    [array addObject:effect];
    i++;
  }

  return array;
}

- (NSArray*)creatFilterData {
  FilterData* filter1 = [self createWithName:@"Empty"
                                 andFlieName:@"LFGPUImageEmptyFilter"
                                    andValue:nil];
  filter1.isSelected = YES;
  FilterData* filter2 = [self createWithName:@"Amatorka"
                                 andFlieName:@"GPUImageAmatorkaFilter"
                                    andValue:nil];
  FilterData* filter3 = [self createWithName:@"MissEtikate"
                                 andFlieName:@"GPUImageMissEtikateFilter"
                                    andValue:nil];
  FilterData* filter4 = [self createWithName:@"Sepia"
                                 andFlieName:@"GPUImageSepiaFilter"
                                    andValue:nil];
  FilterData* filter5 = [self createWithName:@"Sketch"
                                 andFlieName:@"GPUImageSketchFilter"
                                    andValue:nil];
  FilterData* filter6 = [self createWithName:@"SoftElegance"
                                 andFlieName:@"GPUImageSoftEleganceFilter"
                                    andValue:nil];
  FilterData* filter7 = [self createWithName:@"Toon"
                                 andFlieName:@"GPUImageToonFilter"
                                    andValue:nil];

  FilterData* filter8 = [[FilterData alloc] init];
  filter8.name = @"Saturation0";
  filter8.iconPath =
      [[NSBundle mainBundle] pathForResource:@"GPUImageSaturationFilter0"
                                      ofType:@"png"];
  filter8.fillterName = @"GPUImageSaturationFilter";
  filter8.value = @"0";

  FilterData* filter9 = [[FilterData alloc] init];
  filter9.name = @"Saturation2";
  filter9.iconPath =
      [[NSBundle mainBundle] pathForResource:@"GPUImageSaturationFilter2"
                                      ofType:@"png"];
  filter9.fillterName = @"GPUImageSaturationFilter";
  filter9.value = @"2";

  return [NSArray arrayWithObjects:filter1, filter2, filter3, filter4, filter5,
                                   filter6, filter7, filter8, filter9, nil];
}

- (FilterData*)createWithName:(NSString*)name
                  andFlieName:(NSString*)fileName
                     andValue:(NSString*)value {
  FilterData* filter1 = [[FilterData alloc] init];
  filter1.name = name;
  filter1.iconPath =
      [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
  filter1.fillterName = fileName;
  if (value) {
    filter1.value = value;
  }
  return filter1;
}
#pragma mark -  action sheet -

- (void)clickBackToVideoCammer {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.navigationController popViewControllerAnimated:YES];
}

// 下一步
- (void)clickNextBtn {
  HUD.hidden = NO;
  if ([_filtClassName isEqualToString:@"LFGPUImageEmptyFilter"]) {
    // 无滤镜效果
    if (_audioPath) {
      // 音乐混合
      [self mixAudioAndVidoWithInputURL:_videoURL];
    } else {
      HUD.labelText = @"视频处理中...";
      [self compressVideoWithInputVideoUrl:_videoURL];
    }
  } else {
    // 添加滤镜效果
    [self mixFiltWithVideoAndInputVideoURL:_videoURL];
  }
}
// 剔除原声
- (void)clickEditOriginalBtn {
  if (!_editTheOriginaBtn.selected) {
    _editTheOriginaBtn.selected = YES;
    [mainPlayer setVolume:0];
  } else {
    [mainPlayer setVolume:1];
    _editTheOriginaBtn.selected = NO;
  }
}
// 点击音乐
- (void)clickmusicBtn {
  if (self.choseEditType == choseMusic) {
  } else {
    self.choseEditType = choseMusic;

    _musicBtn.selected = YES;
    _filterBtn.selected = NO;
    _collectionView.hidden = YES;
    _musicCollectionView.hidden = NO;
  }
  if (_audioPath) {
    _editTheOriginaBtn.hidden = NO;
    _editTheOriginaSwitch.hidden = NO;
  }
}

// 点击滤镜
- (void)clickFilterBtn {
  _editTheOriginaBtn.hidden = YES;
  _editTheOriginaSwitch.hidden = YES;
  if (self.choseEditType == choseFilter) {
  } else {
    self.choseEditType = choseFilter;

    _musicBtn.selected = NO;
    _filterBtn.selected = YES;
    _collectionView.hidden = NO;
    _musicCollectionView.hidden = YES;
  }
}
/*
- (void)showEditMusicBar:(UIButton*)sendr
{
    if (!sendr.selected) {
        sendr.selected = YES;
        [_musicBottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
        }];
        // 更新约束
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }else
    {
        [_musicBottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(160);
        }];
        // 更新约束
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        sendr.selected = NO;
    }
}
*/

#pragma mark - notification -
- (void)playingEnd:(NSNotification*)notification {
  [self pressPlayButton];
}

- (void)onApplicationWillResignActive {
  [mainPlayer pause];
  [movieFile endProcessing];
  if (_isdoing) {
    [movieWriter cancelRecording];
    [endMovieFile endProcessing];
  }
}

- (void)onApplicationDidBecomeActive {
  [playerItem seekToTime:kCMTimeZero];
  [mainPlayer play];
  [movieFile startProcessing];

  if (_isdoing) {
  }
}
/*
- (void)notCloseCor
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
    [self.navigationController popToRootViewControllerAnimated:NO];
}
*/
#pragma mark - collection Datasource and delegate -
- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView*)collectionView {
  return 1;
}

// 告诉系统每组多少个
- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section {
  if (collectionView == _collectionView) {
    return _filterAry.count;

  } else {
    return _musicAry.count;
  }
}

// 告诉系统每个Cell如何显示
- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath {
  // 1.从缓存池中取
  if (collectionView == _collectionView) {
    static NSString* cellID = @"MyCollectionCell";
    MusicItemCollectionViewCell* cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:cellID
                                                  forIndexPath:indexPath];
    FilterData* data = [_filterAry objectAtIndex:indexPath.row];
    cell.iconImgView.image = [UIImage imageWithContentsOfFile:data.iconPath];
    cell.nameLabel.text = data.name;

    cell.CheckMarkImgView.hidden = !data.isSelected;
    return cell;
  } else {
    static NSString* cellID2 = @"MyCollectionCell2";
    MusicItemCollectionViewCell* cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:cellID2
                                                  forIndexPath:indexPath];
    MusicData* data = [_musicAry objectAtIndex:indexPath.row];
    UIImage* image = [UIImage imageWithContentsOfFile:data.iconPath];
    cell.iconImgView.image = image;
    cell.nameLabel.text = data.name;
    cell.CheckMarkImgView.hidden = !data.isSelected;
    return cell;
  }

  // static NSString *cellID = @"MyCollectionCell";
  // MusicItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
  //
  // if (self.choseEditType == choseFilter) {
  //   FilterData *data = [_filterAry objectAtIndex:indexPath.row];
  //   cell.iconImgView.image = [UIImage imageWithContentsOfFile:data.iconPath];
  //   cell.nameLabel.text = data.name;
  //   return cell;
  // }else {
  //   MusicData *data = [_musicAry objectAtIndex:indexPath.row];
  //   UIImage *image = [UIImage imageWithContentsOfFile:data.iconPath];
  //   cell.iconImgView.image = image;
  //   cell.nameLabel.text = data.name;
  //   return cell;
  // }
}

- (void)collectionView:(UICollectionView*)collectionView
    didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
  if (collectionView == _collectionView) {  // 滤镜

    if (_lastFilterIndex == indexPath) {
      return;
    }

    // 1.修改数据源
    FilterData* dataNow = [_filterAry objectAtIndex:indexPath.row];
    dataNow.isSelected = YES;
    [_filterAry replaceObjectAtIndex:indexPath.row withObject:dataNow];
    FilterData* dataLast = [_filterAry objectAtIndex:_lastFilterIndex.row];
    dataLast.isSelected = NO;
    [_filterAry replaceObjectAtIndex:_lastFilterIndex.row withObject:dataLast];
    // 2.刷新collectionView
    [_collectionView reloadData];
    _lastFilterIndex = indexPath;

    [movieFile removeAllTargets];
    FilterData* data = [_filterAry objectAtIndex:indexPath.row];
    _filtClassName = data.fillterName;

    if (indexPath.row == 0) {
      filter = [[NSClassFromString(_filtClassName) alloc] init];
      [movieFile addTarget:filter];
      [filter addTarget:_filterView];

    } else {
      if ([data.fillterName isEqualToString:@"GPUImageSaturationFilter"]) {
        GPUImageSaturationFilter* xxxxfilter =
            [[NSClassFromString(_filtClassName) alloc] init];
        xxxxfilter.saturation = [data.value floatValue];
        _saturationValue = [data.value floatValue];
        filter = xxxxfilter;

      } else {
        filter = [[NSClassFromString(_filtClassName) alloc] init];
      }
      [movieFile addTarget:filter];

      // Only rotate the video for display, leave orientation the same for recording
      // GPUImageView *filterView = (GPUImageView *)self.view;
      [filter addTarget:_filterView];
    }

  } else {  // 音乐

    if (indexPath == _lastMusicIndex) {
      return;
    }

    // 1.修改数据源
    MusicData* dataNow = [_musicAry objectAtIndex:indexPath.row];
    dataNow.isSelected = YES;
    [_musicAry replaceObjectAtIndex:indexPath.row withObject:dataNow];
    MusicData* dataLast = [_musicAry objectAtIndex:_lastMusicIndex.row];
    dataLast.isSelected = NO;
    [_musicAry replaceObjectAtIndex:_lastMusicIndex.row withObject:dataLast];
    // 刷新collectionView
    [_musicCollectionView reloadData];
    _lastMusicIndex = indexPath;

    if (indexPath.row == 0) {
      _audioPath = nil;
      [_audioPlayer pause];

      _editTheOriginaBtn.hidden = YES;
      _editTheOriginaSwitch.hidden = YES;
      [mainPlayer setVolume:1];
      _editTheOriginaBtn.selected = NO;
      _editTheOriginaSwitch.on = NO;

    } else {
      MusicData* data = [_musicAry objectAtIndex:indexPath.row];
      _audioPath = data.musicPath;
      [self pressPlayButton];
      [self playMusic];
      _editTheOriginaBtn.hidden = NO;
      _editTheOriginaSwitch.hidden = NO;
    }
  }
}

#pragma mark - private -
- (void)playMusic {
  // 路径
  NSURL* audioInputUrl = [NSURL fileURLWithPath:_audioPath];
  // 声音来源
  // NSURL *audioInputUrl = [NSURL URLWithString:_audioPath];
  audioPlayerItem = [AVPlayerItem playerItemWithURL:audioInputUrl];

  [_audioPlayer replaceCurrentItemWithPlayerItem:audioPlayerItem];

  [_audioPlayer play];
}

- (void)pressPlayButton {
  [playerItem seekToTime:kCMTimeZero];
  [mainPlayer play];
  if (_audioPath) {
    [audioPlayerItem seekToTime:kCMTimeZero];
    [_audioPlayer play];
  }
}
#pragma mark -压缩导出视频
- (void)compressVideoWithInputVideoUrl:(NSURL*)inputVideoUrl {
  // Url Should be a file Url, so here we check and convert it into a file Url
  NSDictionary* options =
      @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
  AVAsset* asset = [AVURLAsset URLAssetWithURL:inputVideoUrl options:options];

  [ISVideoCameraTools
      compressVideo:asset
          finalSize:CGSizeMake(360, 640)
         completion:^(BOOL isSucceed, NSURL* videoUrl) {
           if (isSucceed) {
             NSLog(@"Compression Export Completed Successfully");

             HUD.hidden = YES;
             [[NSNotificationCenter defaultCenter] removeObserver:self];
           
             [self.navigationController popViewControllerAnimated:YES];
           } else {
             HUD.label.text = @"Compression Failed";
             dispatch_after(
                 dispatch_time(DISPATCH_TIME_NOW,
                               (int64_t)(1.5 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [[NSNotificationCenter defaultCenter] removeObserver:self];
                   [self.navigationController
                       popToRootViewControllerAnimated:YES];
                 });
           }
         }];
}

#pragma mark -添加滤镜效果
- (void)mixFiltWithVideoAndInputVideoURL:(NSURL*)inputURL {
  HUD.label.text = @"滤镜合成中...";
  _isdoing = YES;
  NSURL* sampleURL = inputURL;
  endMovieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
  endMovieFile.runBenchmark = YES;
  endMovieFile.playAtActualSpeed = NO;

  GPUImageOutput<GPUImageInput>* endFilter;
  if ([_filtClassName isEqualToString:@"GPUImageSaturationFilter"]) {
    GPUImageSaturationFilter* xxxxfilter =
        [[NSClassFromString(_filtClassName) alloc] init];
    xxxxfilter.saturation = _saturationValue;
    endFilter = xxxxfilter;

  } else {
    endFilter = [[NSClassFromString(_filtClassName) alloc] init];
  }
  [endMovieFile addTarget:endFilter];

  // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
  // unlink([pathToMovie UTF8String]);
  NSURL* outPutFilterMovieURL = [ISVideoCameraTools getMixFilterOutPutVideoURL];

  movieWriter =
      [[GPUImageMovieWriter alloc] initWithMovieURL:outPutFilterMovieURL
                                               size:CGSizeMake(720.0, 1280.0)];
  [endFilter addTarget:movieWriter];
  movieWriter.shouldPassthroughAudio = YES;
  endMovieFile.audioEncodingTarget = movieWriter;
  [endMovieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
  [movieWriter startRecording];
  [endMovieFile startProcessing];

  __weak GPUImageMovieWriter* weakmovieWriter = movieWriter;
  typeof(self) __weak weakself = self;
  [movieWriter setCompletionBlock:^{
    [endFilter removeTarget:weakmovieWriter];
    [weakmovieWriter finishRecording];

    if (weakself.audioPath) {
      [weakself mixAudioAndVidoWithInputURL:outPutFilterMovieURL];
      // 音乐混合
    } else {
      // 压缩
      [weakself compressVideoWithInputVideoUrl:outPutFilterMovieURL];
    }
  }];
}
#pragma mark -音乐混合
- (void)mixAudioAndVidoWithInputURL:(NSURL*)inputURL {
  // audio529

  // 路径
  HUD.labelText = @"音乐合成中...";
  // 声音来源
  NSURL* audioInputUrl = [NSURL fileURLWithPath:_audioPath];

  // 视频来源
  NSURL* videoInputUrl = inputURL;

  // 最终合成输出路径
  NSURL* outputFileUrl = [ISVideoCameraTools getMixMusicOutPutVideoURL];

  // 时间起点
  CMTime nextClistartTime = kCMTimeZero;

  // 创建可变的音视频组合
  AVMutableComposition* comosition = [AVMutableComposition composition];

  // 视频采集
  NSDictionary* options =
      @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
  AVURLAsset* videoAsset =
      [[AVURLAsset alloc] initWithURL:videoInputUrl options:options];

  // 视频时间范围
  CMTimeRange videoTimeRange =
      CMTimeRangeMake(kCMTimeZero, videoAsset.duration);

  // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
  AVMutableCompositionTrack* videoTrack =
      [comosition addMutableTrackWithMediaType:AVMediaTypeVideo
                              preferredTrackID:kCMPersistentTrackID_Invalid];

  // 视频采集通道
  AVAssetTrack* videoAssetTrack =
      [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];

  // 把采集轨道数据加入到可变轨道之中
  [videoTrack insertTimeRange:videoTimeRange
                      ofTrack:videoAssetTrack
                       atTime:nextClistartTime
                        error:nil];

  // 声音采集
  AVURLAsset* audioAsset =
      [[AVURLAsset alloc] initWithURL:audioInputUrl options:options];

  // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
  CMTimeRange audioTimeRange = videoTimeRange;

  // 音频通道
  AVMutableCompositionTrack* audioTrack =
      [comosition addMutableTrackWithMediaType:AVMediaTypeAudio
                              preferredTrackID:kCMPersistentTrackID_Invalid];

  // 音频采集通道
  AVAssetTrack* audioAssetTrack =
      [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

  // 加入合成轨道之中
  [audioTrack insertTimeRange:audioTimeRange
                      ofTrack:audioAssetTrack
                       atTime:nextClistartTime
                        error:nil];

  /*
     // 调整视频音量
     AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
     // Create the audio mix input parameters object.
     AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
     // Set the volume ramp to slowly fade the audio out over the duration of the composition.
     // [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
     [mixParameters setVolume:.05f atTime:kCMTimeZero];
     // Attach the input parameters to the audio mix.
     mutableAudioMix.inputParameters = @[mixParameters];
   
    // 原音频轨道
    AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
    */

  if (!_editTheOriginaBtn.selected) {
    AVMutableAudioMix* mutableAudioMix = [AVMutableAudioMix audioMix];
    // Create the audio mix input parameters object.
    AVMutableAudioMixInputParameters* mixParameters =
        [AVMutableAudioMixInputParameters
            audioMixInputParametersWithTrack:audioTrack];
    // Set the volume ramp to slowly fade the audio out over the duration of the composition.
    // [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
    [mixParameters setVolume:0.5f atTime:kCMTimeZero];
    // Attach the input parameters to the audio mix.
    mutableAudioMix.inputParameters = @[ mixParameters ];

    AVMutableCompositionTrack* audioTrack2 =
        [comosition addMutableTrackWithMediaType:AVMediaTypeAudio
                                preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack* audioAssetTrack2 =
        [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

    [audioTrack2 insertTimeRange:audioTimeRange
                         ofTrack:audioAssetTrack2
                          atTime:nextClistartTime
                           error:nil];

    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc]
        initWithAsset:comosition
           presetName:AVAssetExportPreset1280x720];

    assetExport.audioMix = mutableAudioMix;
    // 输出类型
    assetExport.outputFileType = AVFileTypeMPEG4;

    // 输出地址
    assetExport.outputURL = outputFileUrl;

    // 优化
    assetExport.shouldOptimizeForNetworkUse = YES;

    // 合成完毕
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
      // 回到主线程
      dispatch_async(dispatch_get_main_queue(), ^{
        [self compressVideoWithInputVideoUrl:outputFileUrl];
      });
    }];
  } else {
    // 创建一个输出
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc]
        initWithAsset:comosition
           presetName:AVAssetExportPreset1280x720];
    // assetExport.audioMix = mutableAudioMix;
    // 输出类型
    assetExport.outputFileType = AVFileTypeMPEG4;
    // 输出地址
    assetExport.outputURL = outputFileUrl;
    // 优化
    assetExport.shouldOptimizeForNetworkUse = YES;
    // 合成完毕
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
      // 回到主线程
      dispatch_async(dispatch_get_main_queue(), ^{
        [self compressVideoWithInputVideoUrl:outputFileUrl];
      });
    }];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
