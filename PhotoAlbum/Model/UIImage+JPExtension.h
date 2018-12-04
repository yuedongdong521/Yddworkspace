//
//  UIImage+JPExtension.h
//  iShow
//
//  Created by ispeak on 2018/4/12.
//

#import <UIKit/UIKit.h>

@interface UIImage (JPExtension)

/** 修正图片的方向 */
- (UIImage*)jp_fixOrientation;

/** 按指定方向旋转图片 */
- (UIImage*)jp_rotate:(UIImageOrientation)orientation;

/** 沿Y轴翻转 */
- (UIImage*)jp_verticalityMirror;

/** 沿X轴翻转 */
- (UIImage*)jp_horizontalMirror;

@end
