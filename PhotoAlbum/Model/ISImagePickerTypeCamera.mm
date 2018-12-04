//
//  ISImagePickerTypeCamera.m
//  iShow
//
//  Created by admin on 2017/5/31.
//
//

#import "ISImagePickerTypeCamera.h"
#import "MHImagePhotoMutilSelector.h"
#import <AVFoundation/AVFoundation.h>

@interface ISImagePickerTypeCamera ()

@end

@implementation ISImagePickerTypeCamera

+ (MHImagePhotoMutilSelector*)
imagePickerTypeCameraStartWithJumpController:(UIViewController*)jumperVC
                     callBackImageDataObject:
                         (id<MHImagePhotoMutilSelectorDelegate>)delegate
                               allowsEditing:(BOOL)allowsEditing {
  MHImagePhotoMutilSelector* imagePhotoViewController = nil;
  if ([UIImagePickerController
          isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    [AppDelegate appDelegate].ssSpeedingPushTag = SPEEDINGPUSHTAG_SETPhotos;
    imagePhotoViewController = [[MHImagePhotoMutilSelector alloc]
        initWithNibName:@"MHImagePhotoMutilSelector"
                 bundle:nil];
    imagePhotoViewController.delegate = delegate;
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    // 将UIImagePicker的代理指向到imagePickerMutilSelector
    picker.delegate = imagePhotoViewController;
    [picker setAllowsEditing:allowsEditing];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    // 将UIImagePicker的导航代理指向到imagePickerMutilSelector
    picker.navigationController.delegate = imagePhotoViewController;
    // 使imagePickerMutilSelector得知其控制的UIImagePicker实例，为释放时需要。
    imagePhotoViewController.imagePicker = picker;
    __weak UIViewController* currentVC = jumperVC;
    if (currentVC == nil) {
      currentVC = [[AppDelegate appDelegate] getNewCurrentViewController];
    }
    [currentVC presentViewController:imagePhotoViewController.imagePicker
                            animated:YES
                          completion:^{
                            [ISTools requestUseVideoCamera:^(BOOL isCanUse) {
                              if (isCanUse == NO) {
                                ISLog(@"禁止了摄像头的使用");
                              }
                            }];
                          }];
  } else {
    [[AppDelegate appDelegate]
        appDontCoverLoadingViewShowForContext:kDontSupportCamera
                                  ForTypeShow:1
                       ForChangeFrameSizeType:0
                                  ForFrameFlg:YES
                                ForCancelTime:2.0];
  }
  return imagePhotoViewController;
}

@end
