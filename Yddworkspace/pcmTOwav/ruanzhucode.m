//
//  ruanzhucode.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/10.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "ruanzhucode.h"

@implementation ruanzhucode

@implementation PromptView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithText:(NSString*)text WithFontSize:(CGFloat)size {
  self = [super init];
  if (self) {
    CGSize contentSize =
        [CmCommonMethod contentString:text
                           cmFontSize:[UIFont systemFontOfSize:size]
                               cmSize:CGSizeMake(1000, 1000)];
    UIView* bgView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, contentSize.width + contentSize.height,
                                 contentSize.height + 6)];
    bgView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    bgView.layer.cornerRadius = bgView.frame.size.height / 2.0;
    bgView.layer.masksToBounds = YES;
    [self addSubview:bgView];
    UILabel* label = [[UILabel alloc] initWithFrame:bgView.bounds];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];

    UIImage* image = [UIImage imageNamed:kFriendInfo_morecontent1];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(
        label.frame.size.width / 2.0 - image.size.width / 2.0,
        label.frame.size.height, image.size.width, image.size.height);
    imageView.transform = CGAffineTransformMakeRotation(M_PI);
    [self addSubview:imageView];

    self.frame = CGRectMake(0, 0, bgView.frame.size.width,
                            bgView.frame.size.height + image.size.height);
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

@end

- (void)creatSpeekUI {
  UIButton* iFlyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
  UIImage* speekImage = [UIImage imageNamed:@"speekTouchUp"];
  if (SCREEN_MODE_IPHONE6) {
    iFlyBtn.frame =
        CGRectMake(jsSharingClass.commentSenBtn.frame.origin.x + 35 + 5,
                   jsSharingClass.commentSenBtn.frame.origin.y,
                   speekImage.size.width, speekImage.size.height);
  } else
    iFlyBtn.frame =
        CGRectMake(jsSharingClass.commentSenBtn.frame.origin.x + 35 + 10,
                   jsSharingClass.commentSenBtn.frame.origin.y,
                   speekImage.size.width, speekImage.size.height);
  [iFlyBtn addTarget:self
                action:@selector(startIFly:)
      forControlEvents:UIControlEventTouchDown];
  [iFlyBtn addTarget:self
                action:@selector(endTouchAction:forEvent:)
      forControlEvents:UIControlEventTouchUpInside];
  [iFlyBtn addTarget:self
                action:@selector(endTouchAction:forEvent:)
      forControlEvents:UIControlEventTouchUpOutside];
  [iFlyBtn addTarget:self
                action:@selector(touchDragAction:forEvent:)
      forControlEvents:UIControlEventTouchDragOutside];
  [iFlyBtn addTarget:self
                action:@selector(touchDragAction:forEvent:)
      forControlEvents:UIControlEventTouchDragInside];
  [iFlyBtn addTarget:self
                action:@selector(iflyBtnTouchCancel:)
      forControlEvents:UIControlEventTouchCancel];
  _iFlyBtn = iFlyBtn;
  [_self_BgView addSubview:_iFlyBtn];
  _iFlyBtn.alpha = 0;
  _iFlyBtnImage = [[UIImageView alloc] initWithImage:speekImage];
  _iFlyBtnImage.frame = iFlyBtn.bounds;
  [iFlyBtn addSubview:_iFlyBtnImage];

  _speekPrompt = [[PromptView alloc]
      initWithText:@"说话可以送礼物哦,例:\"送一朵鲜花\""
      WithFontSize:10];
  _speekPrompt.hidden = NO;
  _speekPrompt.center = CGPointMake(iFlyBtn.frame.size.width / 2.0,
                                    -(_speekPrompt.frame.size.height / 2.0));
  [_iFlyBtn addSubview:_speekPrompt];

  [self performSelector:@selector(peekPromptenable)
             withObject:nil
             afterDelay:5];
}

- (void)peekPromptenable {
  if (_speekPrompt.hidden == NO) {
    _speekPrompt.hidden = YES;
  }
}

- (void)changeAudioSessionPlayToSpeaker {
  AVAudioSession* session = [AVAudioSession sharedInstance];
  AVAudioSessionCategoryOptions opts = [session categoryOptions];
  opts |= AVAudioSessionCategoryOptionDefaultToSpeaker;
  [session setCategory:AVAudioSessionCategoryPlayAndRecord
           withOptions:AVAudioSessionCategoryOptionMixWithOthers
                 error:nil];
  [session setCategory:session.category withOptions:opts error:nil];
  [session setActive:YES error:nil];
  [_player setVolume:2.0 rigthVolume:2.0];
}

- (void)returnErrorCode:(int)code {
  _player.shouldMute = NO;

  [self changeAudioSessionPlayToSpeaker];
  if (code == 20001) {
    [[AppDelegate appDelegate]
        appDontCoverLoadingViewShowForContext:@"网络出问题了哦!"
                                  ForTypeShow:1
                       ForChangeFrameSizeType:1
                                  ForFrameFlg:YES
                                ForCancelTime:2];
  } else if (code == 20006) {
    [self openAVAudioSession];
  } else if (code != 0) {
    [[AppDelegate appDelegate]
        appDontCoverLoadingViewShowForContext:
            [NSString
                stringWithFormat:@"录音失败,请稍后重试!(%d)", code]
                                  ForTypeShow:1
                       ForChangeFrameSizeType:1
                                  ForFrameFlg:YES
                                ForCancelTime:2];
  }
}

- (NSInteger)getNumberStr:(NSString*)str {
  NSInteger value;
  NSScanner* scanner = [NSScanner scannerWithString:(str != nil ? str : @"")];
  [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet]
                          intoString:nil];
  BOOL isInt = [scanner scanInteger:&value];
  if (isInt) {
    return value;
  }

  NSDictionary* dic = @{
    @"零" : [NSNumber numberWithInteger:0],
    @"一" : [NSNumber numberWithInteger:1],
    @"二" : [NSNumber numberWithInteger:2],
    @"两" : [NSNumber numberWithInteger:2],
    @"三" : [NSNumber numberWithInteger:3],
    @"四" : [NSNumber numberWithInteger:4],
    @"五" : [NSNumber numberWithInteger:5],
    @"六" : [NSNumber numberWithInteger:6],
    @"七" : [NSNumber numberWithInteger:7],
    @"八" : [NSNumber numberWithInteger:8],
    @"九" : [NSNumber numberWithInteger:9],
    @"十" : [NSNumber numberWithInteger:10],
    @"百" : [NSNumber numberWithInteger:100],
    @"千" : [NSNumber numberWithInteger:1000],
    @"万" : [NSNumber numberWithInteger:10000],
    @"亿" : [NSNumber numberWithInteger:100000000]
  };

  NSString* numStr = @"";
  for (int i = 0; i < str.length; i++) {
    NSString* subStr = [str substringWithRange:NSMakeRange(i, 1)];
    if ([dic objectForKey:subStr] &&
        ![[dic objectForKey:subStr] isKindOfClass:[NSNull class]]) {
      numStr = [numStr stringByAppendingString:subStr];
    }
  }

  NSInteger a = 0;  //数值
  NSInteger b = 1;  //单位
  NSInteger c = 0;  //大于一亿以上的数
  NSInteger s = 0;  //结果
  for (NSInteger index = 0; index < numStr.length; index++) {
    NSString* tmpStr = [numStr substringWithRange:NSMakeRange(index, 1)];
    NSInteger tmpNum = 0;
    if ([dic objectForKey:tmpStr] &&
        ![[dic objectForKey:tmpStr] isKindOfClass:[NSNull class]]) {
      tmpNum = [[dic objectForKey:tmpStr] integerValue];

      if (tmpNum < 10) {
        a = tmpNum;
        if (index == numStr.length - 1) {
          s += a;
          a = 0;
        }
      } else {
        if (index == 0) {
          a = tmpNum;
          s = s + a * b;
          a = 0;
        } else {
          if (tmpNum == 100000000) {
            b = tmpNum;
            c = (s + a) * b;
            a = 0;
            s = 0;
            b = 1;
          } else {
            if (b > tmpNum) {
              b = tmpNum;
              s = s + a * b;
              a = 0;
            } else {
              b = tmpNum;
              s = (s + a) * b;
              a = 0;
            }
          }
        }
      }
    }
  }
  s = s + c;
  return s;
}

- (BOOL)speekSendGiftForStr:(NSString*)resultStr {
  //@"送XXX个XXX。"
  NSArray* unitArr =
      @[ @"个", @"朵", @"座", @"支", @"根", @"辆", @"艘", @"只",
         @"颗" ];
  for (int i = 0; i < unitArr.count; i++) {
    NSString* str = unitArr[i];
    NSRange rang2 = [resultStr rangeOfString:str];
    if (rang2.location != NSNotFound) {
      NSRange rang1 = [resultStr rangeOfString:@"送"];
      NSRange rang3 = [resultStr rangeOfString:@"。"];
      if (rang1.location != NSNotFound && rang2.location != NSNotFound &&
          rang3.location != NSNotFound) {
        NSRange numRang =
            NSMakeRange(rang1.location + rang1.length,
                        rang2.location - rang1.location - rang1.length);
        NSRange nameRang =
            NSMakeRange(rang2.location + rang2.length,
                        rang3.location - rang2.location - rang2.length);
        if ((resultStr.length > numRang.location + numRang.length) &&
            (resultStr.length > nameRang.location + nameRang.length)) {
          NSString* numStr = [resultStr substringWithRange:numRang];
          NSString* nameStr = [resultStr substringWithRange:nameRang];
          NSInteger num = [self getNumberStr:numStr];
          NSMutableArray* cmMtbArray =
              [[ViewsTalkServer shareViewsTalkServer].talkGiftMtbDictionary
                  objectForKey:kCKey];
          PresentGroupStructure* presentGroupStructure =
              [cmMtbArray objectAtIndex:0];
          //③
          for (int j = 0; j < presentGroupStructure.presentGroupMtbArray.count;
               j++) {
            GiftInfoStructure* giftInfoStructure =
                [presentGroupStructure.presentGroupMtbArray objectAtIndex:j];
            if ([giftInfoStructure.presentNameString
                    rangeOfString:(nameStr != nil ? nameStr : @" ")]
                        .location != NSNotFound ||
                [nameStr rangeOfString:giftInfoStructure.presentNameString]
                        .location != NSNotFound) {
              if (num > 0) {
                [LivingGiftManager setlastGiftNum:num];
              } else {
                [LivingGiftManager setlastGiftNum:1];
              }
              _giftViewPreIndex = j;

              [self limitSendGiftType:sendGiftTypeSpeek];
              return YES;
            }
          }
        }
      }

      break;
    }
  }

  return NO;
}

- (void)returnResultStr:(NSString*)resultStr {
  //.
  if (resultStr && resultStr.length == 0) {
    [[AppDelegate appDelegate] appDontCoverLoadingViewShowForContext:
                                   @"亲，好像不能识别您说的话哦!"
                                                         ForTypeShow:1
                                              ForChangeFrameSizeType:0
                                                         ForFrameFlg:YES
                                                       ForCancelTime:1];
    return;
  }
  //.
  if ([self speekSendGiftForStr:resultStr]) {
    return;
  }
  //.
  PriaseSendStructure* priase = [[PriaseSendStructure alloc] init];
  priase.username = @"";
  [priase
      createPraiseSendStructturewithUid:[ViewsTalkServer shareViewsTalkServer]
                                            .userStructure.platformUserId
                           withUserNAme:[ViewsTalkServer shareViewsTalkServer]
                                            .userStructure
                                            .platformUserNicknameString
                             withSHowId:[ViewsTalkServer shareViewsTalkServer]
                                            .userStructure.platformViewId
                          withIconIndex:[ViewsTalkServer shareViewsTalkServer]
                                            .userStructure.selfIconIndex
                            withCOntent:resultStr
                         withTimeString:@""
                               withType:3
                                withSex:0
                                WithSeq:0
                               withRank:0];
  priase.type = 12222222;
  priase.content = [[[[AppDelegate appDelegate] sharedProtoEngine]
      sharedPlatformEngine] filter_text:priase.content];
  //炫彩文字
  __block TextColorStructure* vtcolorStru = nil;
  NSUserDefaults* dazzlecolourDefaults = [NSUserDefaults standardUserDefaults];
  NSDictionary* dazzdict = [dazzlecolourDefaults objectForKey:@"dazzlecolour"];
  if (dazzdict &&
      dazzdict.allKeys.count >
          0) {  // key:uid value:TextColorStructure(颜色rgb、时间(时效))
    NSString* userUidKey = [NSString stringWithFormat:@"%ld", (long)priase.uid];
    NSArray* carray = [dazzdict objectForKey:userUidKey];
    if (carray && carray.count > 4) {
      NSNumber* redumber = [carray objectAtIndex:0];
      NSNumber* greennumber = [carray objectAtIndex:1];
      NSNumber* bluenumber = [carray objectAtIndex:2];
      NSNumber* timenumber = [carray objectAtIndex:3];
      [[AppDelegate appDelegate].cmCommonMethod
          getdateSeverForFlg:0
                     forBack:^(unsigned int timestamp) {
                       if ([timenumber unsignedIntValue] < timestamp) {
                         NSMutableDictionary* dazzlecolourMtbDict =
                             [[NSMutableDictionary alloc]
                                 initWithDictionary:dazzdict];
                         [dazzlecolourMtbDict removeObjectForKey:userUidKey];
                         NSUserDefaults* dazzDefaults =
                             [NSUserDefaults standardUserDefaults];
                         [dazzDefaults setObject:dazzlecolourMtbDict
                                          forKey:@"dazzlecolour"];
                       } else {
                         //.
                         priase.red = [redumber intValue];
                         priase.green = [greennumber intValue];
                         priase.blue = [bluenumber intValue];
                         //.
                         vtcolorStru = [[TextColorStructure alloc] init];
                         vtcolorStru.red = [redumber intValue];
                         vtcolorStru.green = [greennumber intValue];
                         vtcolorStru.blue = [bluenumber intValue];
                       }
                     }];
    }
  }
  //.
  [self isShowOrAddAnreadArray:priase];
  //.
  if (unReadMessegeCount) {
    [self seeNewMessege:jsSharingClass.newmessegeNumberBtn];
  }
  //.
  [self sendBubbleMassage:resultStr hasImage:NO forTcolorStru:vtcolorStru];
  //.
  if (ScreenWidth > ScreenHeight) {
    [_landscapeBarrageView sendLandscapeBarrageForPraise:priase];
  }
}

- (void)startIFly:(UIButton*)btn {
  if (_speekPrompt.hidden == NO) {
    _speekPrompt.hidden = YES;
  }
  _iFlyBtnImage.image = [UIImage imageNamed:@"speekTouchDown"];

  btn.enabled = NO;
  _iFlyDate = [NSDate dateWithTimeIntervalSinceNow:0];
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        btn.enabled = YES;
      });

  NSLog(@"开始点击按钮");
  if (_isSelfForbiden) {
    NSString* contentString = @"您已被管理员禁言";
    PriaseSendStructure* priase = [[PriaseSendStructure alloc] init];
    priase.username = @"";
    priase.content = contentString;
    priase.isPublicMessege = YES;
    [self isShowOrAddAnreadArray:priase];
    if (unReadMessegeCount) {
      [self seeNewMessege:jsSharingClass.newmessegeNumberBtn];
    }
    return;
  }

  _player.shouldMute = YES;
  [_iFlySpeek understand];
}

- (void)endTouchAction:(UIButton*)btn forEvent:(UIEvent*)event {
  _iFlyBtnImage.image = [UIImage imageNamed:@"speekTouchUp"];
  if (_isSelfForbiden) {
    return;
  }
  unsigned long long time = [[NSDate dateWithTimeIntervalSinceNow:0]
                                timeIntervalSinceDate:_iFlyDate] *
                            1000;
  if ([self isInButtonBounds:btn event:event]) {
    if (time > 500) {
      [_iFlySpeek end];
    } else {
      [_iFlySpeek cancel];
      [[AppDelegate appDelegate]
          appDontCoverLoadingViewShowForContext:@"说话时间太短!"
                                    ForTypeShow:1
                         ForChangeFrameSizeType:0
                                    ForFrameFlg:YES
                                  ForCancelTime:1];
    }
  } else {
    [_iFlySpeek cancel];
  }
}
- (void)touchDragAction:(UIButton*)btn forEvent:(UIEvent*)event {
  if ([self isInButtonBounds:btn event:event]) {
    [_iFlySpeek cancelPromptIsShow:NO];
  } else {
    [_iFlySpeek cancelPromptIsShow:YES];
  }
}

- (void)iflyBtnTouchCancel:(UIButton*)btn {
  _iFlyBtnImage.image = [UIImage imageNamed:@"speekTouchUp"];
  [_iFlySpeek cancel];
}

- (BOOL)isInButtonBounds:(UIButton*)button event:(UIEvent*)event {
  UITouch* touch = [[event allTouches] anyObject];
  CGFloat boundsExtension = 5.0f;  //扩展范围阀值
  CGRect outerBounds =
      CGRectInset(button.bounds, -1 * boundsExtension, -1 * boundsExtension);

  BOOL touchOutside =
      !CGRectContainsPoint(outerBounds, [touch locationInView:button]);
  if (touchOutside) {
    BOOL previewTouchInside =
        CGRectContainsPoint(outerBounds, [touch previousLocationInView:button]);
    if (previewTouchInside) {
      // UIControlEventTouchDragExit
    } else {
      // UIControlEventTouchDragOutside
    }
    return NO;
  } else {
    BOOL previewTouchOutside = !CGRectContainsPoint(
        outerBounds, [touch previousLocationInView:button]);
    if (previewTouchOutside) {
      // UIControlEventTouchDragEnter
    } else {
      // UIControlEventTouchDragInside
    }
    return YES;
  }
}

- (void)limitSendGiftType:(SendGiftType)type {
  //是否有绑消费
  [[AppDelegate appDelegate].appViewService getBindingMobilePhoneNumber:^(
                                                long long mobileNumber) {
    if (mobileNumber > 0) {
      NSMutableArray* cmMtbArray =
          [[ViewsTalkServer shareViewsTalkServer].talkGiftMtbDictionary
              objectForKey:kCKey];
      PresentGroupStructure* presentGroupStructure =
          [cmMtbArray objectAtIndex:0];
      //③
      if (presentGroupStructure.presentGroupMtbArray.count) {
        GiftInfoStructure* giftInfoStructure;
        if (type == sendGiftTypeSendLastGift) {
          giftInfoStructure = [GiftsendbarManager getlastGiftSendStruct];
        } else if (_giftViewPreIndex <
                   presentGroupStructure.presentGroupMtbArray.count) {
          giftInfoStructure = [presentGroupStructure.presentGroupMtbArray
              objectAtIndex:_giftViewPreIndex];
        } else
          return;

        //对比kHeatname
        NSString* moneyString = [_livingShowgiftView.moneyLabel.text
            substringFromIndex:([kHeatname length] + 1)];
        NSArray* tmpArr = [moneyString componentsSeparatedByString:@","];
        moneyString = [tmpArr componentsJoinedByString:@""];
        long long moneyInt = [moneyString longLongValue];
        if (moneyInt <
            (_livingShowgiftView.giftNum * giftInfoStructure.pricesLong)) {
          if ([ViewsTalkServer shareViewsTalkServer].userStructure.selfMoney <
              ([LivingGiftManager getLivingGiftNum] *
               giftInfoStructure.pricesLong)) {
            BOOL isrefresh = NO;
            NSString* newTimeString = [[AppDelegate appDelegate].cmCommonMethod
                dateFormatterForFormatterString:kDatetimeOneStyleFormatterKey];
            if (_moneyIntervaltime == nil) {
              self.moneyIntervaltime = newTimeString;
              isrefresh = YES;

            } else {
              NSArray* newDateArray = [[AppDelegate appDelegate].cmCommonMethod
                  getLastDateymd:newTimeString];
              NSArray* oldDateArray = [[AppDelegate appDelegate].cmCommonMethod
                  getLastDateymd:self.moneyIntervaltime];
              NSArray* newTimeArray = [[AppDelegate appDelegate].cmCommonMethod
                  getLastDatehms:newTimeString];
              NSArray* oldTimeArray = [[AppDelegate appDelegate].cmCommonMethod
                  getLastDatehms:self.moneyIntervaltime];
              //{
              int newLastDateyy = [[newDateArray objectAtIndex:0] intValue];
              int newLastDateMM = [[newDateArray objectAtIndex:1] intValue];
              int newLastDatedd = [[newDateArray objectAtIndex:2] intValue];
              //
              int oldLastDateyy = [[oldDateArray objectAtIndex:0] intValue];
              int oldLastDateMM = [[oldDateArray objectAtIndex:1] intValue];
              int oldLastDatedd = [[oldDateArray objectAtIndex:2] intValue];
              //}
              if (newTimeArray && oldTimeArray && newDateArray &&
                  oldDateArray) {
                int newLastTimehh = [[newTimeArray objectAtIndex:0] intValue];
                int newLastTimemm = [[newTimeArray objectAtIndex:1] intValue];
                //
                int oldLastTimehh = [[oldTimeArray objectAtIndex:0] intValue];
                int odlLastTimemm = [[oldTimeArray objectAtIndex:1] intValue];
                //
                //判断年月日
                if ((newLastDateyy > oldLastDateyy) ||
                    (newLastDateMM > oldLastDateMM) ||
                    (newLastDatedd > oldLastDatedd)) {
                  self.moneyIntervaltime = newTimeString;
                  isrefresh = YES;

                } else {
                  //判断时分
                  int timedifferenceValues =
                      (newLastTimehh * 60 + newLastTimemm) -
                      (oldLastTimehh * 60 + odlLastTimemm);
                  if (timedifferenceValues > 9) {  //大于9分钟
                    self.moneyIntervaltime = newTimeString;
                    isrefresh = YES;
                  }
                }
              }
            }
            if (isrefresh) {
              [[AppDelegate appDelegate] getSalesInfowithCount:0];
            }
            if (type == sendGiftTypeSpeek) {
              [self livePushShowNotify];
            }
            [self addmoneyAlertView];
            return;

          } else if (type == sendGiftTypeSpeek ||
                     type == sendGiftTypeSendLastGift) {
            if (([LivingGiftManager getLivingGiftNum] *
                 giftInfoStructure.pricesLong) >= 50000) {
              NSString* messege = [NSString
                  stringWithFormat:
                      @"%@%ld%@共%ld钻,是否确认赠送",
                      giftInfoStructure.presentNameString,
                      (long)[LivingGiftManager getLivingGiftNum],
                      giftInfoStructure.exnameString,
                      [LivingGiftManager getLivingGiftNum] *
                          giftInfoStructure
                              .pricesLong];  //@"亲,您本次消费超过50元,确定发送吗？"
              UIAlertController* alertController = [UIAlertController
                  alertControllerWithTitle:@"温馨提示"
                                   message:messege
                            preferredStyle:UIAlertControllerStyleAlert];
              UIAlertAction* cancelAction =
                  [UIAlertAction actionWithTitle:@"取消"
                                           style:UIAlertActionStyleCancel
                                         handler:nil];
              __weak typeof(self) weakself = self;
              UIAlertAction* okAction = [UIAlertAction
                  actionWithTitle:@"确定"
                            style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction* _Nonnull action) {
                            [weakself limitSendGiftForGiftInfoStructure:
                                          giftInfoStructure];
                          }];
              [alertController addAction:cancelAction];
              [alertController addAction:okAction];
              [self presentViewController:alertController
                                 animated:YES
                               completion:nil];
              return;
            }
          }

          [self limitSendGiftForGiftInfoStructure:giftInfoStructure];
        }
      } else {
        NSString* urlstring =
            [[AppDelegate appDelegate].appViewService getBindMobleUrl];
        if (urlstring) {
          [self pressedActivityToWebForUrlString:urlstring forPushType:4];
        }
      }
    }
  forFlag:
    0

  }];
}

- (void)limitSendGiftForGiftInfoStructure:
    (GiftInfoStructure*)giftInfoStructure {
  if (giftInfoStructure.endShowTime > 0) {
    //是否是从服务器获得时间
    unsigned int timeUnInt = 0;
    if ([[AppDelegate appDelegate] thirdNetworkNotReportStateDetection] &&
        [AppDelegate appDelegate].appGeneralProperty.platformLoginStateFlg ==
            LOGIN_STATE_SUCCEED) {
      timeUnInt = [[[[AppDelegate appDelegate] sharedProtoEngine]
          sharedPlatformEngine] Get_service_time];
    } else {
      timeUnInt = [CmCommonMethod dateFormatter1970ForTimeInterval];
    }
    if (timeUnInt > giftInfoStructure.endShowTime) {
      //礼物需要更新
      [self hiddenlivinggiftView:YES];
      PriaseSendStructure* priase = [[PriaseSendStructure alloc] init];
      [priase createPraiseSendStructturewithUid:0
                                   withUserNAme:@""
                                     withSHowId:0
                                  withIconIndex:0
                                    withCOntent:@"此礼物暂未开放!"
                                 withTimeString:@""
                                       withType:3
                                        withSex:0
                                        WithSeq:0
                                       withRank:0];
      [self isShowOrAddAnreadArray:priase];
      if (unReadMessegeCount) {
        [self seeNewMessege:jsSharingClass.newmessegeNumberBtn];
      }
      [LivingGiftManager talkGiftUpadteNotify];
      return;
    }
  }

  //②
  struct tag_user_id userId;
  userId.user_id = self.uid;
  userId.client_type = self.clientType;

  struct tag_send_gift_info gift_info;
  gift_info.gift_id = giftInfoStructure.presentId;
  gift_info.gift_count_per_group =
      (unsigned int)[LivingGiftManager getLivingGiftNum];  //送出礼物数量
  gift_info.gift_group_num = 1;
  gift_info.gift_version = giftInfoStructure.giftIVersion;
  gift_info.partner_id = kLDPARTNER_ID;
  [[[ViewsTalkServer shareViewsTalkServer] sharedTalkEngine]
      SendGift:&userId
          Gift:&gift_info];
  _contentTextView.hidden = YES;
  CGFloat xPos = ScreenWidth - 10 - 35 + 10;
  [self preparePraiseArrayWithNam:5 withxPos:xPos];
  [self praiseEffectwithxPos:xPos];
}

@end
