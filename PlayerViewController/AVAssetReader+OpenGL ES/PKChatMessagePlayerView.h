//
//  PKChatMessagePlayerView.h
//  DevelopPlayerDemo
//
//  Created by jiangxincai on 16/1/11.
//  Copyright © 2016年 pepsikirk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKChatMessagePlayerView : UIView

@property (readonly, nonatomic) CGSize sizeInPixels;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, assign) BOOL isPlaying;

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath previewImage:(UIImage *)previewImage;
- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath;

- (void)play;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
