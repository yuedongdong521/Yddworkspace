//
//  VideoCameraView.h
//  addproject
//
//  Created by 胡阳阳 on 17/3/3.
//  Copyright © 2017年 mac. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

typedef NS_ENUM(NSInteger, VideoCameraViewType) {
  VideoCameraViewTypeVideo,  // 拍摄视频 和 照片
  VideoCameraViewTypePic,  // 仅拍照
  VideoCameraViewTypeVideoSession,  // 聊天小视频
};

@protocol VideoCameraViewDelegate <NSObject>

@required

- (void)didClickBackToHomeBtn;
- (void)didFinishTakePhoto:(UIImage*)image
              goToNextPage:(void (^)(void))goToNextPage;

@optional

- (void)didClickInputLocalPhotoOrVideoBtn:(void (^)(void))goToNextPage;
- (void)didFinishVideoRecord:(NSArray<NSURL*>*)urlArr
                goToNextPage:(void (^)(void))goToNextPage;

@end

@interface VideoCameraView : UIView

// @property (nonatomic, assign) BOOL  showTip;  // 展示长按拍摄
// 点击拍照的提示
@property(nonatomic, assign) VideoCameraViewType videoCameraType;

@property(nonatomic, weak) id<VideoCameraViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                  WithMaxTime:(CGFloat)maxTime
                  WithMinTime:(CGFloat)minTime;
- (instancetype)initWithCoder:(NSCoder*)coder NS_UNAVAILABLE;
@end
