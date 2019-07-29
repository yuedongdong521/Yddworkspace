//
//  UIImage+Compress.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/4.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Compress)


/** 压缩图片尺寸(压缩图片尺寸可以使图片小于指定大小，但会使图片明显模糊(比压缩图片质量模糊))  */
-(NSData *)compressBySizeWithMaxLength:(NSUInteger)maxLength;

/** 两种图片压缩方法结合 */
-(NSData *)compressWithMaxLength:(NSUInteger)maxLength;

/** 1.设置固定size 2.两种图片压缩方法结合 */
-(NSData *)compressWithMaxLength:(NSUInteger)maxLength maxSize:(CGSize)maxSize;

@end

NS_ASSUME_NONNULL_END
