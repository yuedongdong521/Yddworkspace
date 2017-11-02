//
//  MyTools.h
//  Yddworkspace
//
//  Created by ispeak on 2016/12/5.
//  Copyright © 2016年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTools : NSObject


+ (instancetype)shareMyTools;

/*********************
     获取当前控制器
 *********************/
-(UIViewController*)getCurrentViewController;

/*********************
 计算label可以显示多少个字数
 *********************/
+ (NSInteger)numberOfStringInUpper:(UILabel *)label stringToSeperate:(NSString *)str;

/*********************
 计算文本宽高
 *********************/
- (CGSize)getContentStr:(NSString *)text widthSize:(CGFloat)width heightSize:(CGFloat)height FontOfSize:(UIFont *)fontSize;

/*********************
 当前视图大小变化
 *********************/
+ (CAAnimation *)starTimer:(CGFloat)duration original:(CGFloat)original midNumerical:(CGFloat)midNumerical endNumerical:(CGFloat)endNumerical;

/*********************
 当前视图透明度变化
 *********************/
- (CAAnimation *)fadeInOutAnimation:(CGFloat)duration fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue;

/*********************
 截取全屏
 *********************/
- (UIImage *)imageFromView:(UIView*)theView;

/*********************
 数组排序
 *********************/
- (NSArray *)getSortingArray:(NSArray *)array;

/*********************
 点赞效果 大小变化
 *********************/
- (void)imageViewAnimationLayer:(UIView *)view;

/*********************
 获取当前时间
 *********************/
- (NSString *)getCurrentTime;

/*********************
 图片压缩
 *********************/
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage*)selectedImage;

/*********************
 随机颜色
 *********************/
-(UIColor *)randomColor:(CGFloat)alpha;

/*********************
 正则判断电话号码地址格式,固话
 *********************/
-(BOOL)isTelePhone:(NSString *)telePhoneNum;

/*********************
 判断是否中文
 *********************/
-(BOOL)isChinese:(NSString *)string;

/*********************
 身份证号
 *********************/
- (BOOL)validateIdentityCard: (NSString *)identityCard;

/*********************
 判断邮箱是否正确
 *********************/
- (BOOL)isValidateEmail:(NSString *)Email;

/*********************
 判断字母数字
 *********************/
-(BOOL)IsNumber:(NSString *)number;

/*********************
 改变图片方向
 *********************/
-(UIImage *)scaleAndRotateImage:(UIImage *)image resolution:(int)kMaxResolution;

/***
 通过rgb字符串取颜色值
 **/
- (UIColor *)getColorValueForRGBStr:(NSString *)rgbStr;
@end
