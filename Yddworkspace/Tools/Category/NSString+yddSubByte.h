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

- (CGSize)getTextSizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font;

/**
 *  判断身份证是否合法
 */
- (BOOL)checkIdentityNumber;

/** 过滤特殊字符串 */
- (NSString *)filterSpecialString;

/** 过滤非中文字符 */
- (NSString *)filter_zhHans;

/** 按照过滤不匹配正则规则regex的字符 */
- (NSString *)filterCharactorWithRegex:(NSString *)regexStr;

- (NSString *)filterSpecialCharactor;

/** 获取汉字，字母，数字 */
- (NSString *)filterStringSpecialStr;

/// 是否为纯数字
- (BOOL)isNumber;

@end

NS_ASSUME_NONNULL_END
