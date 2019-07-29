//
//  CropPhotoHelper.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/8.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOCropViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface CropPhotoHelper : NSObject

+ (void)cropPhotoTargetViewController:(UIViewController *)targetViewController
                           orignImage:(UIImage *)oringImage
                         cropComplete:(void(^)(UIImage *image))cropComplete;

+ (void)cropPhotoStyle:(TOCropViewCroppingStyle)style
     aspectRatioPreset:(TOCropViewControllerAspectRatioPreset)aspectRatioPreset
  targetViewController:(UIViewController *)targetViewController
            orignImage:(UIImage *)oringImage
          cropComplete:(void(^)(UIImage *image))cropComplete;


@end

NS_ASSUME_NONNULL_END
