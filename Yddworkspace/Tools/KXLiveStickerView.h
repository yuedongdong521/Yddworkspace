//
//  KXLiveStickerView.h
//  KXLive
//
//  Created by ydd on 2019/11/22.
//  Copyright © 2019 ibobei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KXLivePusher;
NS_ASSUME_NONNULL_BEGIN

@interface KXLiveStickerView : UIView

@property (nonatomic, weak) KXLivePusher *livePusher;

@property (nonatomic, copy) void(^hiddenHeaderView)(BOOL hidden);

- (instancetype)initWithFrame:(CGRect)frame
                       midTop:(CGFloat)midTop
                    midBottom:(CGFloat)midBottom
                     anchorId:(NSInteger)anchorId;

- (UIImage *)getStickerImage;

- (void)addImage:(UIImage *)image;

- (void)hiddenSticker;

- (void)showSticker;

@end

NS_ASSUME_NONNULL_END
