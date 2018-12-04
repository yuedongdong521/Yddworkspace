//
//  ISCutOutPictures.h
//  iShow
//
//  Created by admin on 2017/5/31.
//
//

#import <Foundation/Foundation.h>

@interface ISCutOutPictures : NSObject

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
                             withSourceImage:(UIImage*)sourceImage;
+ (UIImage*)imageByScalingAndCroppingForDataSize:(CGSize)targetSize
                                 withSourceImage:(UIImage*)sourceImage;
+ (CGSize)getImageSizeByScalingAndCroppingForSize:(CGSize)targetSize
                                  withSourceImage:(UIImage*)sourceImage;
+ (UIImage*)imageByScalingAndCroppingSourceImage:(UIImage*)sourceImage;
+ (CGSize)getImageSizeByScalingAndCroppingForSize:(CGSize)imageSize;

@end
