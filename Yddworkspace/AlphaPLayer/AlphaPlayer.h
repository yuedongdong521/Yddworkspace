//
//  AlphaPlayer.h
//  Yddworkspace
//
//  Created by ydd on 2020/3/24.
//  Copyright © 2020 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlphaPlayer : UIView

@property (nonatomic, assign) BOOL backgroundPlay;

- (instancetype)initWithUrl:(NSString *)url;

- (void)stopPlayer;

- (void)startURL:(NSString *)videoPath completed:(void(^)(BOOL finished))completed;

@end

NS_ASSUME_NONNULL_END
