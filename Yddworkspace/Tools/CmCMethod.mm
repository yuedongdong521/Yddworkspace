//
//  CmCommonMethod.m
//  IShow
//
//  Created by Administrator on 13-3-5.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "CmCMethod.h"
#import <CommonCrypto/CommonDigest.h>

@interface CmCMethod () {
}

@end

@implementation CmCMethod

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

#pragma mark 时间
- (unsigned int)dateFormatter1970ForTimeInterval {
  NSDate* cDateTime = [NSDate dateWithTimeIntervalSinceNow:0];
  NSTimeInterval time = [cDateTime timeIntervalSince1970];
  // NSTimeInterval time = [dat timeIntervalSince1970]*1000;  //  *1000
  // 是精确到毫秒，不乘就是精确到秒
  // NSString *timeString = [NSString stringWithFormat:@"%f", time];
  // // 转为字符型=
  // CMNSLog(@"%ld", time(NULL));  // 这句也可以获得时间戳，跟上面一样，精确到秒
  return (unsigned int)time;
}

#pragma mark MD5加密
+ (NSString*)cmmd5:(NSString*)inPutText {
  const char* cStr = [inPutText UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
  return [[NSString
      stringWithFormat:
          @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
          result[0], result[1], result[2], result[3], result[4], result[5],
          result[6], result[7], result[8], result[9], result[10], result[11],
          result[12], result[13], result[14], result[15]] lowercaseString];
}

#pragma mark URL Encode
+ (NSString*)urlEncodedString:(NSString*)string {
  NSString* encodedString =
      (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
          kCFAllocatorDefault, (__bridge CFStringRef)string, NULL,
          (__bridge CFStringRef) @"!*'();:@&=+$,/?%#[] ",
          kCFStringEncodingUTF8));
  return encodedString;
}

#pragma mark keyCompareToSignForDict
+ (void)keyCompareToSignForDict:(NSDictionary*)cmDict
                   forParameter:(NSString*)parameterstring
                         forKey:(NSString*)keystring
                  forHTTPMethod:(NSString*)methodstring
                blockcompletion:(KeyCompareToSign)string {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableString* mtbString = [NSMutableString stringWithCapacity:0];
        [mtbString
            appendString:[NSString stringWithFormat:@"%@ %@", methodstring,
                                                    parameterstring]];
        NSMutableString* bodyString = [NSMutableString stringWithCapacity:0];
        NSArray* keyArray =
            [[cmDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSString* sign_type_string = @"sign_type";
        NSString* time_string = @"time";
        for (int i = 0; i < [keyArray count]; i++) {
          NSString* dictkeystring = [keyArray objectAtIndex:i];
          NSString* valuestring = [cmDict objectForKey:dictkeystring];
          if (i == 0) {
            [mtbString
                appendString:[NSString stringWithFormat:@"%@=%@", dictkeystring,
                                                        valuestring]];
            if ([dictkeystring isEqualToString:sign_type_string]) {
            } else if ([dictkeystring isEqualToString:time_string]) {
            } else {
              [bodyString
                  appendString:[NSString
                                   stringWithFormat:
                                       @"%@=%@",
                                       [CmCMethod
                                           urlEncodedString:dictkeystring],
                                       [self urlEncodedString:valuestring]]];
            }
          } else {
            [mtbString appendString:[NSString stringWithFormat:@"&%@=%@",
                                                               dictkeystring,
                                                               valuestring]];
            if ([dictkeystring isEqualToString:sign_type_string]) {
            } else if ([dictkeystring isEqualToString:time_string]) {
            } else {
              [bodyString
                  appendString:[NSString
                                   stringWithFormat:
                                       @"&%@=%@",
                                       [CmCMethod
                                           urlEncodedString:dictkeystring],
                                       [self urlEncodedString:valuestring]]];
            }
          }
        }
        [bodyString
            appendString:[NSString stringWithFormat:
                                       @"&%@=%@&%@=%@", sign_type_string,
                                       [cmDict objectForKey:sign_type_string],
                                       time_string,
                                       [cmDict objectForKey:time_string]]];
        [mtbString appendString:keystring];
        NSString* md5string = [CmCMethod cmmd5:mtbString];
        [bodyString
            appendString:[NSString stringWithFormat:@"&sign=%@", md5string]];
        if (!self) {
          return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
          if (!self) {
            return;
          }
          string(bodyString);
        });
      });
}

#pragma mark 整数换算成钱币类型展示
+ (NSString*)ChangeNumberFormat:(unsigned long long)num {
  unsigned long long tmp = num;
  int count = 0;
  while (num != 0) {
    count++;
    num /= 10;
  }
  NSMutableString* string = [NSMutableString stringWithFormat:@"%llu", tmp];
  NSMutableString* newstring = [NSMutableString stringWithCapacity:0];
  while (count > 3) {
    count -= 3;
    NSRange rang = NSMakeRange(string.length - 3, 3);
    NSString* str = [string substringWithRange:rang];
    [newstring insertString:str atIndex:0];
    [newstring insertString:@"," atIndex:0];
    [string deleteCharactersInRange:rang];
  }
  [newstring insertString:string atIndex:0];
  return newstring;
}
/*****************************
 * UIView 按照任意一点为圆心旋转
 centerX view 中心点 x 坐标
 centerY view 中心点 y 坐标
 x 旋转点x坐标
 y 旋转点y坐标
 *****************************/
+ (CGAffineTransform)GetCGAffineTransformRotateAroundPointwith:(float)centerX
                                                          with:(float)centerY
                                                          with:(float)x
                                                          with:(float)y
                                                          with:(float)angle {
  x = x - centerX;  // 计算(x,y)从(0,0)为原点的坐标系变换到(CenterX
      // CenterY)为原点的坐标系下的坐标
  y = y -
      centerY;  // (0，0)坐标系的右横轴、下竖轴是正轴,(CenterX,CenterY)坐标系的正轴也一样

  CGAffineTransform trans = CGAffineTransformMakeTranslation(x, y);
  trans = CGAffineTransformRotate(trans, angle);
  trans = CGAffineTransformTranslate(trans, -x, -y);
  return trans;
}
+ (CGSize)contentString:(NSString*)textString
             cmFontSize:(UIFont*)cmFontSize
                 cmSize:(CGSize)cmSize {
  if (cmFontSize == nil) {
    cmFontSize = [UIFont systemFontOfSize:17];
  }
  NSMutableParagraphStyle* paragraphStyle =
      [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
  NSDictionary* attributes = @{
    NSFontAttributeName : cmFontSize,
    NSParagraphStyleAttributeName : paragraphStyle
  };
  CGRect rect =
      [textString boundingRectWithSize:cmSize
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:attributes
                               context:nil];
  CGSize labelSize = CGSizeMake(rect.size.width, rect.size.height);
  if (labelSize.height <= 0 || labelSize.width <= 0) {
    labelSize.height = 20;
    labelSize.width = 100;
  }
  return labelSize;
}

+ (UIColor*)colorWithHexString:(NSString*)color alpha:(CGFloat)alpha {
  // 删除字符串中的空格
  NSString* cString = [[color
      stringByTrimmingCharactersInSet:[NSCharacterSet
                                          whitespaceAndNewlineCharacterSet]]
      uppercaseString];
  // String should be 6 or 8 characters
  if ([cString length] < 6) {
    return [UIColor clearColor];
  }
  // strip 0X if it appears
  // 如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
  if ([cString hasPrefix:@"0X"]) {
    cString = [cString substringFromIndex:2];
  }
  // 如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
  if ([cString hasPrefix:@"#"]) {
    cString = [cString substringFromIndex:1];
  }
  if ([cString length] != 6) {
    return [UIColor clearColor];
  }

  // Separate into r, g, b substrings
  NSRange range;
  range.location = 0;
  range.length = 2;
  // r
  NSString* rString = [cString substringWithRange:range];
  // g
  range.location = 2;
  NSString* gString = [cString substringWithRange:range];
  // b
  range.location = 4;
  NSString* bString = [cString substringWithRange:range];

  // Scan values
  unsigned int r, g, b;
  [[NSScanner scannerWithString:rString] scanHexInt:&r];
  [[NSScanner scannerWithString:gString] scanHexInt:&g];
  [[NSScanner scannerWithString:bString] scanHexInt:&b];
  return [UIColor colorWithRed:((float)r / 255.0f)
                         green:((float)g / 255.0f)
                          blue:((float)b / 255.0f)
                         alpha:alpha];
}

// 默认alpha值为1
+ (UIColor*)colorWithHexString:(NSString*)color {
  return [self colorWithHexString:color alpha:1.0f];
}

+ (NSMutableAttributedString*)
getAttributeStringFromString:(NSString*)text
             highlightString:(NSString*)highlightString
                   textColor:(UIColor*)color
              HighlightColor:(UIColor*)highlightColor {
  NSDictionary* defaultDic = @{NSForegroundColorAttributeName : color};
  NSMutableAttributedString* hintString =
      [[NSMutableAttributedString alloc] initWithString:text
                                             attributes:defaultDic];

  if (highlightString == nil || highlightString.length == 0) {
    return hintString;
  }

  // 获取要调整颜色的文字位置,调整颜色
  if (![text containsString:highlightString]) {
    return hintString;
  }
  NSRange range1 = [[hintString string] rangeOfString:highlightString];
  [hintString addAttribute:NSForegroundColorAttributeName
                     value:highlightColor
                     range:range1];
  return hintString;
}

@end
