//
//  NSString+yddSubByte.h
//  Yddworkspace
//
//  Created by ydd on 2019/4/25.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (yddSubByte)

/** 按照字节长度截取子串 */
- (NSString *)subStringToByteIndex:(NSInteger)index;
- (NSString *)subStringFormByteIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
