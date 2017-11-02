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
@property (nonatomic, assign) BOOL isPlaying;

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath previewImage:(UIImage *)previewImage;
- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath;

- (void)stop;
- (void)play;

@end

NS_ASSUME_NONNULL_END
