//
//  KXAudioAnimationView.h
//  KXLive
//
//  Created by ydd on 2020/6/19.
//  Copyright © 2020 ibobei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KXAudioAnimationView : UIView

@property (nonatomic, strong) UIImageView *audioImageView;

@property (nonatomic, strong)UIBezierPath *path;

@property (nonatomic, strong)UIImageView *singleNoteIV;
@property (nonatomic, strong)UIImageView *doubleNoteIV1;
@property (nonatomic, strong)UIImageView *doubleNoteIV2;

@property (nonatomic, assign)BOOL isAnimating;

- (void)stopAnimation;

- (void)startAnimation;


@end

NS_ASSUME_NONNULL_END
