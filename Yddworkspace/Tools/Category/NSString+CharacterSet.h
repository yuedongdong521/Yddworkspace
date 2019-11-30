//
//  NSString+CharacterSet.h
//  Yddworkspace
//
//  Created by ydd on 2019/1/25.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//+ whitespaceCharacterSet              //空格
//+ whitespaceAndNewlineCharacterSet    //空格和换行符
//+ decimalDigitCharacterSet            //0-9的数字
//+ letterCharacterSet                  //所有字母
//+ lowercaseLetterCharacterSet         //小写字母
//+ uppercaseLetterCharacterSet         //大写字母
//+ alphanumericCharacterSet            //所有数字和字母（大小写不分）
//+ punctuationCharacterSet             //标点符号
//+ newlineCharacterSet                 //换行

typedef NS_ENUM(NSUInteger, CharacterSetType) {
  CharacterSetType_lowercase = 0, // 小写字母
  CharacterSetType_uppercase,  // 大写字母
  CharacterSetType_letter  // 所有字母
};

@interface NSString (CharacterSet)

/**
 删除字符串中的特定字符
 
 @param str 要删除的字符
 @return 删除后的新字符
 */
- (NSString *)deleteOfStr:(NSString *)str;

/**
 获取字符传中的数字
 
 @return return value description
 */
- (NSString *)getAllNumber;

- (NSString *)getTargetStr:(CharacterSetType)type;

// URLHostAllowedCharacterSet      "#%/<>?@\^`{|}
//
// URLFragmentAllowedCharacterSet  "#%<>[\]^`{|}
//
// URLPasswordAllowedCharacterSet  "#%/:<>?@[\]^`{|}
//
// URLPathAllowedCharacterSet      "#%;<>?[\]^`{|}
//
// URLQueryAllowedCharacterSet     "#%<>[\]^`{|}
//
// URLUserAllowedCharacterSet      "#%/:<>?@[\]^`

- (NSString*)stringUTF8Encode;

- (NSString *)urlUTF8Encode;

@end

NS_ASSUME_NONNULL_END
