//
//  ISMyCollectionPlayerView.h
//  iShow
//
//  Created by ispeak on 2017/12/19.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ISMyCollectionPlayerViewDelegate<NSObject>

- (void)reloadItemSizeRate:(CGFloat)sizeRate;

@end

@interface ISMyCollectionPlayerView : UIView

@property(nonatomic, strong) AVPlayer* player;

@property(nonatomic, weak) id<ISMyCollectionPlayerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame WithURL:(NSURL*)url;

- (void)removeObserver;

- (void)resetOriginFrame;

- (void)resetFrame:(CGRect)frame;

- (void)animateIsStart:(BOOL)isStart;

- (void)setBGImageViewImageURL:(NSURL *)imageURL;

@end

