//
//  MyResponderBtn.h
//  Yddworkspace
//
//  Created by ydd on 2019/1/10.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyResponderBtn : UIButton

+ (instancetype)createBtn:(NSString *)title color:(UIColor*)color tag:(NSInteger)tag frame:(CGRect)frame target:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
