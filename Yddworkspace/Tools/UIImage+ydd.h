//
//  UIImage+ydd.h
//  Yddworkspace
//
//  Created by ydd on 2018/12/7.
//  Copyright © 2018 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ydd)
/**
 截取视频、动画等view 时用 layer渲染会导致画面布局异常，建议不用 layer 渲染。
 截取静态图片建议使用 layer 渲染。
 */
+ (UIImage*)screenShotView:(UIView*)view shotLayer:(BOOL)isShotLayer;
+ (UIImage*)mergeImageWithImages:(NSArray<UIImage*>*)images;
/**
 生成二维码
 
 
 */
+ (UIImage*)createQrCodeImageWithQrContent:(NSString*)qrContent
                                    qrSize:(CGFloat)qrSize
                                   qrLevel:(NSString*)qrLevel
                                 logoImage:(UIImage*)logoImage
                             logoSizeScale:(CGFloat)logoSizeScale;
+ (NSString*)scanCodeImage:(UIImage*)image;
@end

NS_ASSUME_NONNULL_END
