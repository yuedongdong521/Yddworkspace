//
//  KXPasswordView.h
//  KXLive
//
//  Created by ydd on 2019/12/9.
//  Copyright © 2019 ibobei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KXPasswordView : UIView

@property (nonatomic, strong, readonly) NSString *password;

@property (nonatomic, copy) void(^passwordChanged)(NSString *password);


- (instancetype)initWithLenght:(NSInteger)lenght;

- (void)clearPassword;

- (CGSize)viewSize;

@end

NS_ASSUME_NONNULL_END
