//
//  UINavigationController+yddSubByte.m
//  Yddworkspace
//
//  Created by ydd on 2019/4/25.
//  Copyright © 2019 QH. All rights reserved.
//

#import "NSString+yddSubByte.h"

@implementation NSString (yddSubByte)

- (NSString *)subStringToByteIndex:(NSInteger)index
{
    NSInteger sum = 0;
    NSString *subStr = [[NSString alloc] init];
    for(int i = 0; i<[self length]; i++){
        unichar strChar = [self characterAtIndex:i];
        if(strChar < 256){
            sum += 1;
        }
        else {
            sum += 2;
        }
        if (sum > index) {
            subStr = [self substringToIndex:i];
            return subStr;
        }
    }
    return self;
}

- (NSString *)subStringFormByteIndex:(NSInteger)index
{
    NSInteger sum = 0;
    NSString *subStr = [[NSString alloc] init];
    for(int i = 0; i<[self length]; i++){
        unichar strChar = [self characterAtIndex:i];
        if(strChar < 256){
            sum += 1;
        }
        else {
            sum += 2;
        }
        if (sum > index) {
            subStr = [self substringFromIndex:i];
            return subStr;
        }
    }
    return self;
}

/*NSStringDrawingUsesLineFragmentOrigin
 整个文本将以每行组成的矩形为单位计算整个文本的尺寸。
 NSStringDrawingTruncatesLastVisibleLine/NSStringDrawingUsesDeviceMetric
 计算文本尺寸时将以每个字或字形为单位来计算。
 NSStringDrawingUsesFontLeading
 以字体间的行距（leading，行距：从一行文字的底部到另一行文字底部的间距。）来计算。
 一般使用:
 NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
*/
- (CGSize)getTextSizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font
{
    if (!font) {
        font = [UIFont systemFontOfSize:17];
    }
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:font}];
    return [att boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
}



/**
 *  判断身份证是否合法
 */
- (BOOL)checkIdentityNumber
{
    //必须满足以下规则
    //1. 长度必须是18位或者15位，前17位必须是数字，第十八位可以是数字或X
    //2. 前两位必须是以下情形中的一种：11,12,13,14,15,21,22,23,31,32,33,34,35,36,37,41,42,43,44,45,46,50,51,52,53,54,61,62,63,64,65,71,81,82,91
    //3. 第7到第14位出生年月日。第7到第10位为出生年份；11到12位表示月份，范围为01-12；13到14位为合法的日期
    //4. 第17位表示性别，双数表示女，单数表示男
    //5. 第18位为前17位的校验位
    //算法如下：
    //（1）校验和 = (n1 + n11) * 7 + (n2 + n12) * 9 + (n3 + n13) * 10 + (n4 + n14) * 5 + (n5 + n15) * 8 + (n6 + n16) * 4 + (n7 + n17) * 2 + n8 + n9 * 6 + n10 * 3，其中n数值，表示第几位的数字
    //（2）余数 ＝ 校验和 % 11
    //（3）如果余数为0，校验位应为1，余数为1到10校验位应为字符串“0X98765432”(不包括分号)的第余数位的值（比如余数等于3，校验位应为9）
    //6. 出生年份的前两位必须是19或20
    NSString *number = [self copy];
    number = [number stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    number = [number filterSpecialString];
    //1⃣️判断位数
    if (number.length != 15 && number.length != 18) {
        return NO;
    }
    //2⃣️将15位身份证转为18位
    NSMutableString *mString = [NSMutableString stringWithString:number];
    if (number.length == 15) {
        //出生日期加上年的开头
        [mString insertString:@"19" atIndex:6];
        //最后一位加上校验码
        [mString insertString:[mString getLastIdentifyNumber] atIndex:[mString length]];
        number = mString;
    }
    //3⃣️开始判断
    NSString *mmdd = @"(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))";
    NSString *leapMmdd = @"0229";
    NSString *year = @"(19|20)[0-9]{2}";
    NSString *leapYear = @"(19|20)(0[48]|[2468][048]|[13579][26])";
    NSString *yearMmdd = [NSString stringWithFormat:@"%@%@", year, mmdd];
    NSString *leapyearMmdd = [NSString stringWithFormat:@"%@%@", leapYear, leapMmdd];
    NSString *yyyyMmdd = [NSString stringWithFormat:@"((%@)|(%@)|(%@))", yearMmdd, leapyearMmdd, @"20000229"];
    //区域
    NSString *area = @"(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|82|[7-9]1)[0-9]{4}";
    NSString *regex = [NSString stringWithFormat:@"%@%@%@", area, yyyyMmdd  , @"[0-9]{3}[0-9Xx]"];
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (![regexTest evaluateWithObject:number]) {
        return NO;
    }
    //4⃣️验证校验码
    return [[number getLastIdentifyNumber] isEqualToString:[number substringWithRange:NSMakeRange(17, 1)]];
}

/** 过滤特殊字符串 */
- (NSString *)filterSpecialString
{
    NSCharacterSet *dontWant = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+,.;':|/@!? "];
    //stringByTrimmingCharactersInSet只能去掉首尾的特殊字符串
    return [[[self componentsSeparatedByCharactersInSet:dontWant] componentsJoinedByString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (NSString *)getLastIdentifyNumber {
    //位数不小于17
    if (self.length < 17) {
        return nil;
    }
    //加权因子
    int R[] = {7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2};
    //校验码
    unsigned char sChecker[11] = {'1','0','X','9','8','7','6','5','4','3','2'};
    long p =0;
    for (int i =0; i<=16; i++){
        NSString * s = [self substringWithRange:NSMakeRange(i, 1)];
        p += [s intValue]*R[i];
    }
    //校验位
    int o = p%11;
    NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
    return string_content;
}

/** 过滤非中文字符 */
- (NSString *)filter_zhHans
{
    return [self filterCharactorWithRegex:@"[^\u4e00-\u9fa5]"];
}

/** 按照过滤不匹配正则规则regex的字符 */
- (NSString *)filterCharactorWithRegex:(NSString *)regexStr {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length) withTemplate:@""];
    return result;
}


@end
