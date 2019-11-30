//
//  NSString+CharacterSet.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/25.
//  Copyright © 2019 QH. All rights reserved.
//

#import "NSString+CharacterSet.h"

@implementation NSString (CharacterSet)

/**
 删除字符串中的特定字符

 @param str 要删除的字符
 @return 删除后的新字符
 */
- (NSString *)deleteOfStr:(NSString *)str
{
  NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:str];
  NSArray *setArr = [self componentsSeparatedByCharactersInSet:characterSet];
  NSString *resultStr = [setArr componentsJoinedByString:@""];
  return resultStr;
}



/**
 获取字符传中的数字

 @return return value description
 */
- (NSString *)getAllNumber
{
  NSCharacterSet *characterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
  NSArray *setArr = [self componentsSeparatedByCharactersInSet:characterSet];
  return [setArr componentsJoinedByString:@""];
}


- (NSString *)getTargetStr:(CharacterSetType)type
{
  NSCharacterSet *chatacterSet = nil;
  switch (type) {
    case CharacterSetType_lowercase:
      chatacterSet = [NSCharacterSet lowercaseLetterCharacterSet];
      break;
    case CharacterSetType_uppercase:
      chatacterSet = [NSCharacterSet uppercaseLetterCharacterSet];
      break;
    case CharacterSetType_letter:
      chatacterSet = [NSCharacterSet letterCharacterSet];
      break;
    default:
      break;
  }
  // 取反
  chatacterSet = [chatacterSet invertedSet];
  NSArray *setArr = [self componentsSeparatedByCharactersInSet:chatacterSet];
  return [setArr componentsJoinedByString:@""];
}

- (NSString*)stringUTF8Encode {

  NSString* encodeStr = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";// @":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`";
  NSCharacterSet* characters = [[NSCharacterSet
                                 characterSetWithCharactersInString:encodeStr]invertedSet];
  NSString* encodedUrl = [self
                          stringByAddingPercentEncodingWithAllowedCharacters:characters];
  return encodedUrl;
}

- (NSString *)urlUTF8Encode {
  return [self
   stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end
