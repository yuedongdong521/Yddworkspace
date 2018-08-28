//
//  ISVideoCameraBeautySelecteView.m
//  iShow
//
//  Created by student on 2017/7/24.
//
//

#import "ISVideoCameraBeautySelecteView.h"
#import "UIColor+Hex.h"

typedef NS_ENUM(NSInteger, TagType) {
  TagTypeSliderBackView = 143,
  TagTypeTipView = 144,
  TagTypeBottomSelectedView = 145
};

@interface ISVideoCameraBeautySelecteView ()

@property(nonatomic, assign, readwrite)
    NSInteger selectedCount;  // 选中的button，0 - 5

@property(nonatomic, strong) NSArray* defaultSliderArr;
@property(nonatomic, strong) NSMutableDictionary* tempDictionary;
@property(nonatomic, strong) UIView* bottomBackView;
@property(nonatomic, strong) UISlider* whiteSlider;
@property(nonatomic, strong) UISlider* buffingSlider;
// @property (nonatomic, strong) UISlider *bigEyesSlider;
// @property (nonatomic, strong) UISlider *thinFaceSlider;

@end

static NSString* const whiteSliderValue = @"whiteSliderValue";
static NSString* const buffingSliderValue = @"buffingSliderValue";
static NSString* const bigEyesSliderValue = @"bigEyesSliderValue";
static NSString* const thinFaceSliderValue = @"thinFaceSliderValue";

@implementation ISVideoCameraBeautySelecteView

- (instancetype)init {
  self = [super init];
  if (self) {
    [self initDefaultData];
    [self createView];
  }
  return self;
}

- (void)initDefaultData {
  _defaultSliderArr = @[
    @{
      whiteSliderValue : @(0),
      buffingSliderValue : @(0),
      bigEyesSliderValue : @(0),
      thinFaceSliderValue : @(0)
    },
    @{
      whiteSliderValue : @(0.2),
      buffingSliderValue : @(0.2),
      bigEyesSliderValue : @(0.2),
      thinFaceSliderValue : @(0.2)
    },
    @{
      whiteSliderValue : @(0.35),
      buffingSliderValue : @(0.4),
      bigEyesSliderValue : @(0.4),
      thinFaceSliderValue : @(0.4)
    },
    @{
      whiteSliderValue : @(0.5),
      buffingSliderValue : @(0.55),
      bigEyesSliderValue : @(0.6),
      thinFaceSliderValue : @(0.6)
    },
    @{
      whiteSliderValue : @(0.65),
      buffingSliderValue : @(0.7),
      bigEyesSliderValue : @(0.8),
      thinFaceSliderValue : @(0.8)
    },
    @{
      whiteSliderValue : @(0.75f),
      buffingSliderValue : @(0.85f),
      bigEyesSliderValue : @(1.f),
      thinFaceSliderValue : @(1.f)
    }
  ];

  NSNumber* value = [[NSUserDefaults standardUserDefaults]
      objectForKey:@"ISVideoCameraBeautyValue"];
  if (value != nil) {
    NSInteger count = [value integerValue];
    _selectedCount = count;
  } else {
    _selectedCount = 0;
  }

  NSDictionary* selectedDic = [[NSUserDefaults standardUserDefaults]
      objectForKey:@"ISVideoCameraTemDictionary"];
  if ([selectedDic isKindOfClass:[NSDictionary class]]) {
    _tempDictionary = selectedDic.mutableCopy;
  } else {
    selectedDic = _defaultSliderArr[_selectedCount];
    _tempDictionary = selectedDic.mutableCopy;
  }
}

- (void)createView {
  self.backgroundColor = [UIColor clearColor];
  self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);

  UIView* topView = [[UIView alloc] init];
  topView.backgroundColor = [UIColor clearColor];
  topView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 242);
  [self addSubview:topView];

  UITapGestureRecognizer* tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(tapClick:)];
  [topView addGestureRecognizer:tap];

  _bottomBackView = [[UIView alloc] init];
  _bottomBackView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 242);
  _bottomBackView.backgroundColor = [UIColor clearColor];
  [self addSubview:_bottomBackView];
  [self creatSubViewsOfBottomBackView];
}

- (void)creatSubViewsOfBottomBackView {
  UIView* sliderBackView = [[UIView alloc] init];
  sliderBackView.tag = TagTypeSliderBackView;
  sliderBackView.backgroundColor = [UIColor clearColor];
  sliderBackView.frame = CGRectMake(0, 0, ScreenWidth, 92);
  [_bottomBackView addSubview:sliderBackView];
  [self createSliderViewSubViews:sliderBackView];

  UIView* tipView = [[UIView alloc] init];
  tipView.tag = TagTypeTipView;
  tipView.backgroundColor =
      [UIColor colorWithRed:0 / 255.f green:0 / 255.f blue:0 / 255.f alpha:0.6];
  tipView.frame =
      CGRectMake(0, CGRectGetMaxY(sliderBackView.frame), ScreenWidth, 45);
  [_bottomBackView addSubview:tipView];
  [self createTipView:tipView];

  UIView* lineView = [[UIView alloc] init];
  lineView.backgroundColor = [UIColor whiteColor];
  lineView.frame =
      CGRectMake(0, CGRectGetMaxY(tipView.frame) - 1, ScreenWidth, 0.7);
  [_bottomBackView addSubview:lineView];

  UIView* bottomSelectedView = [[UIView alloc] init];
  bottomSelectedView.tag = TagTypeBottomSelectedView;
  bottomSelectedView.backgroundColor =
      [UIColor colorWithRed:0 / 255.f green:0 / 255.f blue:0 / 255.f alpha:0.6];
  bottomSelectedView.frame = CGRectMake(
      0, CGRectGetMaxY(tipView.frame), ScreenWidth,
      _bottomBackView.frame.size.height - CGRectGetMaxY(tipView.frame));
  [_bottomBackView addSubview:bottomSelectedView];
  [self createBottomSelectedView:bottomSelectedView];
}

- (void)createSliderViewSubViews:(UIView*)sliderBackView {
  UIView* whiteSliderView = [self
      createSliderViewWithTitle:@"美白"
                     completion:^(UISlider* sender) {
                       [sender addTarget:self
                                     action:@selector(whiteSliderValueChanged:)
                           forControlEvents:UIControlEventValueChanged];
                       _whiteSlider = sender;
                     }];
  whiteSliderView.frame = CGRectMake(0, 30, ScreenWidth / 2, 35);
  [sliderBackView addSubview:whiteSliderView];

  UIView* buffingSliderView =
      [self createSliderViewWithTitle:@"磨皮"
                           completion:^(UISlider* sender) {
                             [sender addTarget:self
                                           action:@selector
                                           (buffingSliderValueChanged:)
                                 forControlEvents:UIControlEventValueChanged];
                             _buffingSlider = sender;
                           }];

  buffingSliderView.frame =
      CGRectMake(ScreenWidth / 2, 30, ScreenWidth / 2, 35);
  [sliderBackView addSubview:buffingSliderView];

  /*
    UIView *bigEyeSliderView = [self createSliderViewWithTitle:@"大眼" completion:^(UISlider *sender) {
        [sender addTarget:self action:@selector(bigEyesSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _bigEyesSlider = sender;
   
    }];
    bigEyeSliderView.frame = CGRectMake(0, 40, ScreenWidth/2, 55);
    [sliderBackView addSubview:bigEyeSliderView];
   
    UIView *thinFaceSliderView = [self createSliderViewWithTitle:@"瘦脸" completion:^(UISlider *sender) {
        [sender addTarget:self action:@selector(thinFaceSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _thinFaceSlider = sender;
   
    }];
    thinFaceSliderView.frame = CGRectMake(ScreenWidth/2, 40, ScreenWidth/2, 55);
    [sliderBackView addSubview:thinFaceSliderView];
    */
}

- (void)createTipView:(UIView*)tipView {
  UILabel* label = [[UILabel alloc] init];
  label.frame = CGRectMake(15, 15, 30, 15);
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [UIColor colorWithHexString:@"ffffff"];
  label.text = @"美颜";
  label.font = [UIFont boldSystemFontOfSize:14];
  [tipView addSubview:label];

  UIButton* recoverDefaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  recoverDefaultBtn.tag = 10086;
  recoverDefaultBtn.frame = CGRectMake(ScreenWidth - 91, 10, 76, 25);
  recoverDefaultBtn.layer.cornerRadius = 25 / 2.f;
  recoverDefaultBtn.clipsToBounds = YES;
  recoverDefaultBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
  recoverDefaultBtn.layer.backgroundColor =
      [[UIColor colorWithHexString:@"636363"] CGColor];
  [recoverDefaultBtn setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
  [recoverDefaultBtn setTitle:@"恢复默认" forState:UIControlStateNormal];
  recoverDefaultBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
  [recoverDefaultBtn addTarget:self
                        action:@selector(recoverDefaultBtnClick:)
              forControlEvents:UIControlEventTouchUpInside];
  [tipView addSubview:recoverDefaultBtn];
}

- (void)createBottomSelectedView:(UIView*)seletedView {
  for (NSInteger i = 0; i < 6; i++) {
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 100 + i;

    CGFloat marginH = (ScreenWidth - 23 * 2 - 6 * 40) / 5.f;
    CGFloat originX = 23 + (marginH + 40.f) * i;
    btn.frame = CGRectMake(originX, 32, 40, 40);
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = 20.f;
    btn.titleLabel.font = [UIFont systemFontOfSize:24];

    [btn setTitle:[NSString stringWithFormat:@"%ld", (long)i]
         forState:UIControlStateNormal];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    if (i == self.selectedCount) {
      btn.backgroundColor = [UIColor whiteColor];
      [btn setTitleColor:[UIColor colorWithHexString:@"202020"]
                forState:UIControlStateNormal];
    } else {
      btn.backgroundColor = [UIColor clearColor];
      [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [btn addTarget:self
                  action:@selector(seletedBtnClick:)
        forControlEvents:UIControlEventTouchUpInside];
    [seletedView addSubview:btn];
  }
}

#pragma mark - action sheet -

- (void)whiteSliderValueChanged:(UISlider*)sender {
  if ([_delegate
          respondsToSelector:@selector(selecteView:whiteSliderChanged:)]) {
    [_delegate selecteView:self whiteSliderChanged:sender];
  }

  if (_tempDictionary == nil) {
    return;
  }
  _tempDictionary[whiteSliderValue] = @(sender.value);
}

- (void)buffingSliderValueChanged:(UISlider*)sender {
  if ([_delegate
          respondsToSelector:@selector(selecteView:buffingSliderChanged:)]) {
    [_delegate selecteView:self buffingSliderChanged:sender];
  }

  if (_tempDictionary == nil) {
    return;
  }
  _tempDictionary[buffingSliderValue] = @(sender.value);
}

// - (void)bigEyesSliderValueChanged:(UISlider *)sender
// {
//    if ([_delegate respondsToSelector:@selector(selecteView:bigEyesSliderChanged:)]) {
//        [_delegate selecteView:self bigEyesSliderChanged:sender];
//    }
//
//    if (_tempDictionary == nil) {
//        return;
//    }
//     _tempDictionary[bigEyesSliderValue] = @(sender.value);
//
// }

// - (void)thinFaceSliderValueChanged:(UISlider *)sender
// {
//    if ([_delegate respondsToSelector:@selector(selecteView:thinFaceSliderChanged:)]) {
//        [_delegate selecteView:self thinFaceSliderChanged:sender];
//    }
//
//    if (_tempDictionary == nil) {
//        return;
//    }
//     _tempDictionary[thinFaceSliderValue] = @(sender.value);
//
// }

- (void)tapClick:(UITapGestureRecognizer*)tap {
  [self dismissView:^{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];

    [[NSUserDefaults standardUserDefaults]
        setValue:@(_selectedCount)
          forKey:@"ISVideoCameraBeautyValue"];

    [userDefaults setObject:_tempDictionary
                     forKey:@"ISVideoCameraTemDictionary"];

    [[NSUserDefaults standardUserDefaults] synchronize];
  }];
}
// 恢复默认
- (void)recoverDefaultBtnClick:(UIButton*)sender {
  [self setDefaultSliderValue];
}

- (void)seletedBtnClick:(UIButton*)sender {
  UIView* selectedView =
      [_bottomBackView viewWithTag:TagTypeBottomSelectedView];
  UIButton* oldButton = [selectedView viewWithTag:self.selectedCount + 100];
  UIButton* currentButton = sender;
  if (currentButton == oldButton) {
    return;
  }

  oldButton.backgroundColor = [UIColor clearColor];
  [oldButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

  [currentButton setTitleColor:[UIColor colorWithHexString:@"202020"]
                      forState:UIControlStateNormal];
  currentButton.backgroundColor = [UIColor whiteColor];
  self.selectedCount = currentButton.tag - 100;
}

#pragma mark - private -
- (void)setSliderViewAndRecoverDefaultButtonState {
  BOOL isZeroSelectedCount = (_selectedCount == 0);
  UIView* sliderBackView = [_bottomBackView viewWithTag:TagTypeSliderBackView];
  sliderBackView.hidden = isZeroSelectedCount;

  UIView* tipBackView = [_bottomBackView viewWithTag:TagTypeTipView];
  UIButton* recoverDefaultBtn = [tipBackView viewWithTag:10086];
  recoverDefaultBtn.hidden = isZeroSelectedCount;
}

- (void)setTempSliderValue {
  if (_tempDictionary == nil) {
    return;
  }
  _whiteSlider.value = [_tempDictionary[whiteSliderValue] floatValue];
  _buffingSlider.value = [_tempDictionary[buffingSliderValue] floatValue];
  //    _bigEyesSlider.value = [_tempDictionary[bigEyesSliderValue] floatValue];
  //    _thinFaceSlider.value = [_tempDictionary[thinFaceSliderValue] floatValue];

  if ([_delegate
          respondsToSelector:@selector(selecteView:whiteSliderChanged:)]) {
    [_delegate selecteView:self whiteSliderChanged:_whiteSlider];
  }

  if ([_delegate
          respondsToSelector:@selector(selecteView:buffingSliderChanged:)]) {
    [_delegate selecteView:self buffingSliderChanged:_buffingSlider];
  }

  //    if ([_delegate respondsToSelector:@selector(selecteView:bigEyesSliderChanged:)]) {
  //        [_delegate selecteView:self bigEyesSliderChanged:_bigEyesSlider];
  //    }

  //    if ([_delegate respondsToSelector:@selector(selecteView:thinFaceSliderChanged:)]) {
  //        [_delegate selecteView:self thinFaceSliderChanged:_thinFaceSlider];
  //    }
}

- (void)setDefaultSliderValue {
  if (_defaultSliderArr.count > _selectedCount) {
    NSDictionary* dic = _defaultSliderArr[_selectedCount];
    _whiteSlider.value = [dic[whiteSliderValue] floatValue];
    _buffingSlider.value = [dic[buffingSliderValue] floatValue];
    //        _bigEyesSlider.value = [dic[bigEyesSliderValue] floatValue];
    //        _thinFaceSlider.value = [dic[thinFaceSliderValue] floatValue];

    _tempDictionary[whiteSliderValue] = dic[whiteSliderValue];
    _tempDictionary[buffingSliderValue] = dic[buffingSliderValue];
    _tempDictionary[bigEyesSliderValue] = dic[bigEyesSliderValue];
    _tempDictionary[thinFaceSliderValue] = dic[thinFaceSliderValue];

    if ([_delegate
            respondsToSelector:@selector(selecteView:whiteSliderChanged:)]) {
      [_delegate selecteView:self whiteSliderChanged:_whiteSlider];
    }

    if ([_delegate
            respondsToSelector:@selector(selecteView:buffingSliderChanged:)]) {
      [_delegate selecteView:self buffingSliderChanged:_buffingSlider];
    }

    //        if ([_delegate respondsToSelector:@selector(selecteView:bigEyesSliderChanged:)]) {
    //            [_delegate selecteView:self bigEyesSliderChanged:_bigEyesSlider];
    //        }
    //
    //        if ([_delegate respondsToSelector:@selector(selecteView:thinFaceSliderChanged:)]) {
    //            [_delegate selecteView:self thinFaceSliderChanged:_thinFaceSlider];
    //        }
  }
}

- (void)setSelectedCount:(NSInteger)selectedCount {
  _selectedCount = selectedCount;
  [self setSliderViewAndRecoverDefaultButtonState];
  [self setDefaultSliderValue];
  if ([_delegate respondsToSelector:@selector(selecteView:didSelctedItem:)]) {
    [_delegate selecteView:self didSelctedItem:self.selectedCount];
  }
}

- (UIView*)createSliderViewWithTitle:(NSString*)title
                          completion:(void (^)(UISlider* sender))completion {
  UIView* view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];

  UILabel* leftLabel = [[UILabel alloc] init];
  leftLabel.text = title;
  leftLabel.frame = CGRectMake(15, 20, 30, 15);
  leftLabel.font = [UIFont boldSystemFontOfSize:14];
  leftLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
  leftLabel.textAlignment = NSTextAlignmentLeft;
  leftLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
  leftLabel.shadowOffset = CGSizeMake(0, 1);
  [view addSubview:leftLabel];

  UISlider* sliderView = [[UISlider alloc] init];
  sliderView.minimumTrackTintColor = [UIColor colorWithHexString:@"ffdd00"];
  sliderView.layer.shadowColor =
      [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor];
  sliderView.layer.shadowOffset = CGSizeMake(1, 1);
  sliderView.maximumTrackTintColor = [UIColor whiteColor];
  [sliderView
      setThumbImage:[UIImage imageNamed:@"icon_videoCamera_slider_thumb"]
           forState:UIControlStateNormal];
  sliderView.frame = CGRectMake(15 + 30 + 12, 20, ScreenWidth / 2 - 72.f, 15);
  [view addSubview:sliderView];

  if (completion) {
    completion(sliderView);
  }

  return view;
}

#pragma mark - public method -
- (void)dismissView:(void (^)(void))completion {
  if ([_delegate respondsToSelector:@selector(selecteViewWillDismiss)]) {
    [_delegate selecteViewWillDismiss];
  }

  if (self.superview) {
    [UIView animateWithDuration:0.25
        animations:^{
          _bottomBackView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 242);
        }
        completion:^(BOOL finished) {
          [self removeFromSuperview];
          if (completion) {
            completion();
          }
        }];
  }
}

- (void)showInView:(UIView*)supView completion:(void (^)(void))completion {
  if (supView == nil) {
    return;
  }
  _bottomBackView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 242);

  [supView addSubview:self];

  [UIView animateWithDuration:0.25
                   animations:^{
                     _bottomBackView.frame =
                         CGRectMake(0, ScreenHeight - 242, ScreenWidth, 242);
                   }];

  if (completion) {
    completion();
  }
}

- (void)recoveryBeforeState {
  [self setSliderViewAndRecoverDefaultButtonState];
  if ([_delegate respondsToSelector:@selector(selecteView:didSelctedItem:)]) {
    [_delegate selecteView:self didSelctedItem:self.selectedCount];
  }
  [self setTempSliderValue];
}

@end
