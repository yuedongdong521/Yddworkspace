//
//  CmCommonMethod.h
//  IShow
//
//  Created by Administrator on 13-3-5.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
typedef NS_ENUM(NSInteger, BubbleColorType) {
  BubbleColorRed = 0,
  BubbleColorBlue,
  BubbleColorYellow
};
typedef NS_ENUM(NSInteger, BulletType) {
  BulletType_First = 0,
  BulletType_Second,
  BulletType_Third
};
typedef void (^KeyCompareToSign)(NSString* bodyString);
typedef void (^CmRequestAsynchronousCallsBlock)(NSURLResponse* response,
                                                NSData* data,
                                                NSError* connectionError);

@interface CmCMethod : NSObject {
}

/**
 <#Description#>

 @param cmDict <#cmDict description#>
 @param parameterstring <#parameterstring description#>
 @param keystring <#keystring description#>
 @param methodstring <#methodstring description#>
 @param string <#string description#>
 */
+ (void)keyCompareToSignForDict:(NSDictionary*)cmDict
                   forParameter:(NSString*)parameterstring
                         forKey:(NSString*)keystring
                  forHTTPMethod:(NSString*)methodstring
                blockcompletion:(KeyCompareToSign)string;

/*****************************
* 钱加逗号
*****************************/

+ (NSString*)ChangeNumberFormat:(unsigned long long)num;
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
                                                          with:(float)angle;
/*****************************
 * 计算文字长度
 *****************************/
+ (CGSize)contentString:(NSString*)textString
             cmFontSize:(UIFont*)cmFontSize
                 cmSize:(CGSize)cmSize;

/**
 十六进制字符串获取颜色

 @param color color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 @return (UIColor *)
 */
+ (UIColor*)colorWithHexString:(NSString*)color;
+ (UIColor*)colorWithHexString:(NSString*)color alpha:(CGFloat)alpha;

/**
 根据全部字符串 需要高亮的字符串 生成 NSMutableAttributedString

 @param text 总的字符串
 @param highlightString 总字符串中 需要 高亮的字符串
 @param color 普通颜色
 @param highlightColor 高亮的颜色
 @return NSMutableAttributedString
 */
+ (NSMutableAttributedString*)
getAttributeStringFromString:(NSString*)text
             highlightString:(NSString*)highlightString
                   textColor:(UIColor*)color
              HighlightColor:(UIColor*)highlightColor;

@end
