//
//  AppManager.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/22.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppManager : NSObject

+ (instancetype)shareManager;
- (void)addTabBar;

@end

NS_ASSUME_NONNULL_END
