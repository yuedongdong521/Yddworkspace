//
//  FloatCollectView.h
//  Yddworkspace
//
//  Created by ydd on 2018/6/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FloatCollectView : UIWindow

@property (nonatomic, strong) CAShapeLayer *bgLayer;
@property (nonatomic, assign) CGSize viewSize;

- (void)updateBgLayerPath:(BOOL)isSmall;
@end

NS_ASSUME_NONNULL_END
