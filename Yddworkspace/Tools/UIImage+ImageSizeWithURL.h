//
//  UIImage+ImageSizeWithURL.h
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageSizeWithURL)

+ (CGSize)getImageSizeWithURL:(id)URL;

+ (void)deleteCacheImageSize;

@end
