//
//  MoveView.h
//  Yddworkspace
//
//  Created by ydd on 2019/6/27.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MoveView : UIView

@property (nonatomic, copy) void(^addImage)(void);

- (void)addImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
