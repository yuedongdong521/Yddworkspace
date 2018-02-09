//
//  BarrageController.h
//  Yddworkspace
//
//  Created by ispeak on 2017/1/16.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BarrageModel.h"

@interface BarrageController : NSObject

@property(nonatomic, assign) int maxLineCount;
/*********
 弹幕速度是否一致
 **********/
@property(nonatomic, assign) BOOL isUniform;

- (instancetype)initBarrageController;

- (void)sendBarrageForBarrageModel:(BarrageModel *)barrageModel bgView:(UIView *)bgView;
- (void)timerInval;


@end
