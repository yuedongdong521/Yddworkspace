//
//  KXDynamicVideoPlayer.h
//  KXLive
//
//  Created by ydd on 2020/1/4.
//  Copyright © 2020 ibobei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KXDynamicVideoPlayer : UIView

+ (void)showPlayerWithVideoURl:(NSString *)videoURl
                     startTime:(CGFloat)startTime
                         image:(UIImage *)image
                  dismissBlock:(void(^)(void))dismissBlock;
@end

NS_ASSUME_NONNULL_END
