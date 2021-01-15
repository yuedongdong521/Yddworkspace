//
//  UIImage+Extra.h
//  Yddworkspace
//
//  Created by ydd on 2019/6/20.
//  Copyright © 2019年 Qihe. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, GradientType) {
    GradientTypeTopToBottom = 0,//从上到下
    GradientTypeLeftToRight = 1,//从左到右
    GradientTypeUpleftToLowright = 2,//左上到右下
    GradientTypeUprightToLowleft = 3,//右上到左下
    GradientTypeLowRightToUpLeft = 4,//右下到左上
};


@interface UIImage (Extra)

/**
 缩放图片

 @param width 缩放后的宽度
 @param image <#image description#>
 @return <#return value description#>
 */
+(UIImage *)reduceScaleToWidth:(CGFloat)width andImage:(UIImage *)image;

/**
 按图像比例缩小，按屏幕比例缩小到宽度

 @param width <#width description#>
 @param image <#image description#>
 @return <#return value description#>
 */
+(UIImage *)reduceWithImageScaleWithScreenScaleToWidth:(CGFloat)width andImage:(UIImage *)image;

/// 按图像比例缩小，按屏幕比例缩小到高度
/// @param height <#height description#>
/// @param image <#image description#>
+(UIImage *)reduceWithImageScaleWithScreenScaleToHeight:(CGFloat)height andImage:(UIImage *)image;

/**
 缩放图片宽高4:3
 */
+(UIImage *)reducePhotoScaleToWidth:(CGFloat)width andImage:(UIImage *)image;

/**
 根据传入color返回相应颜色的图片

 @param color <#color description#>
 @return <#return value description#>
 */
+ (UIImage *)extraImageWithColor:(UIColor *)color;

/**生成纯色图片*/
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**根据颜色数组生成渐变色*/
+ (UIImage *)gradientColorImageFromColors:(NSArray<UIColor *> * )colors gradientType:(GradientType)gradientType imgSize:(CGSize)imgSize;
+ (UIImage *)gradientColorImageFromColors:(NSArray*)colors
                             gradientType:(GradientType)gradientType
                                  imgSize:(CGSize)imgSize
                               startPoint:(CGPoint)startPoint
                                 endPoint:(CGPoint)endPoint;

/**
 改变图片方向
 */
+(UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

/**
 @return 返回圆角图片
 */
- (UIImage *)jj_imageWithCornerRadius:(CGFloat)radius;

/**
 *  改变image透明度
 *
 *  @param alpha 透明度
 */
- (UIImage *)imageWithAlpha:(CGFloat)alpha;

/** 渐变颜色生成图片 */
+ (UIImage *)kx_gradiant:(CGSize)size withColors:(NSArray<UIColor *>*)colors;
+ (UIImage *)kx_gradiant:(CGSize)size withColors:(NSArray<UIColor *>*)colors alpha:(CGFloat)alpha;
/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *  @param image UIImage image 原始的图片
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
+ (UIImage *)cutImageFromImage:(UIImage *)image inRect:(CGRect)rect;
+ (UIImage *)cutImageFromImage:(UIImage *)image inRect:(CGRect)rect withScale:(CGFloat)scale;

/**
 按比例缩放

 @param ratio <#ratio description#>
 @param image <#image description#>
 @return <#return value description#>
 */
+ (UIImage *)scaleWithRatio:(float)ratio ForImage:(UIImage *)image;

/**
 按中心点拉伸

 @param image 原图片
 @return 拉伸后的图片
 */
+ (UIImage *)resizableImageWithImage:(UIImage *)image;

+ (UIImage *)resizableImageWithImage:(UIImage *)image withEdgeInsets:(UIEdgeInsets)edgeInsets;

+ (UIImage*)circleImage:(UIImage*)image;


///  高斯模糊 在一些机器上有崩溃，不能使用
/// @param originImage <#originImage description#>
/// @param inputRadius <#inputRadius description#>
//+ (UIImage*)blureImage:(UIImage*)originImage
//       withInputRadius:(CGFloat)inputRadius;

- (CGFloat)scaleWidthWithHeight:(CGFloat)height;



/// 此方法还原真实图片 zego新加
- (CVPixelBufferRef)getCVPixelBufferRefFromImage;



/// 将图片置灰
/// @param oldImage <#oldImage description#>
+ (UIImage *)changeGrayImage:(UIImage *)oldImage;

@end
