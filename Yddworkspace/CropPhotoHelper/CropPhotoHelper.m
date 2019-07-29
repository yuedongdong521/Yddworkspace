//
//  CropPhotoHelper.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/8.
//  Copyright © 2019 QH. All rights reserved.
//

#import "CropPhotoHelper.h"

@interface CropPhotoHelper ()<TOCropViewControllerDelegate>

@property (nonatomic, copy) void (^cropCompleteBlock)(UIImage *image);

@end

static CropPhotoHelper *_helper;
@implementation CropPhotoHelper


+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[CropPhotoHelper alloc] init];
    });
    return _helper;
}


+ (void)cropPhotoTargetViewController:(UIViewController *)targetViewController
            orignImage:(UIImage *)oringImage
          cropComplete:(void(^)(UIImage *image))cropComplete
{
    [self cropPhotoStyle:TOCropViewCroppingStyleDefault aspectRatioPreset:TOCropViewControllerAspectRatioPresetSquare targetViewController:targetViewController orignImage:oringImage cropComplete:cropComplete];
}


+ (void)cropPhotoStyle:(TOCropViewCroppingStyle)style
     aspectRatioPreset:(TOCropViewControllerAspectRatioPreset)aspectRatioPreset
  targetViewController:(UIViewController *)targetViewController
            orignImage:(UIImage *)oringImage
          cropComplete:(void(^)(UIImage *image))cropComplete
{
    [[CropPhotoHelper shareHelper] cropPhotoStyle:style aspectRatioPreset:aspectRatioPreset targetViewController:targetViewController orignImage:oringImage cropComplete:cropComplete];
}


- (void)cropPhotoStyle:(TOCropViewCroppingStyle)style
     aspectRatioPreset:(TOCropViewControllerAspectRatioPreset)aspectRatioPreset
  targetViewController:(UIViewController *)targetViewController
            orignImage:(UIImage *)oringImage
          cropComplete:(void(^)(UIImage *image))cropComplete
{
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:style image:oringImage];
    cropController.delegate = (id <TOCropViewControllerDelegate>)self;
    self.cropCompleteBlock = cropComplete;
    
    cropController.aspectRatioPreset = aspectRatioPreset; //Set the initial aspect ratio as a square
    cropController.aspectRatioLockEnabled = YES; // The crop box is locked to the aspect ratio and can't be resized away from it
    cropController.resetAspectRatioEnabled = NO; // When tapping 'reset', the aspect ratio will NOT be reset back to default
    
    cropController.aspectRatioPickerButtonHidden = YES;
    
    cropController.rotateButtonsHidden = YES; // 旋转按钮
    cropController.rotateClockwiseButtonHidden = YES; // 旋转按钮
    cropController.toolbar.resetButton.hidden = YES; // 恢复比例缩放按钮
    
    [cropController.toolbar.doneTextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cropController.toolbar.cancelTextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cropController.doneButtonTitle = @"使用";
    cropController.cancelButtonTitle = @"取消";
//    if (targetViewController.navigationController) {
//        [targetViewController.navigationController pushViewController:cropController animated:YES];
//
//    } else {
        [targetViewController presentViewController:cropController animated:YES completion:nil];
//    }
    
}

#pragma mark - Cropper Delegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.cropCompleteBlock) {
        self.cropCompleteBlock(image);
    }
   
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToCircularImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.cropCompleteBlock) {
        self.cropCompleteBlock(image);
    }
}







@end
