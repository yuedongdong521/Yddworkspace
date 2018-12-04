//
//  ISImagePickerTypeCamera.h
//  iShow
//
//  Created by admin on 2017/5/31.
//
//

#import <Foundation/Foundation.h>

@interface ISImagePickerTypeCamera : NSObject

+ (MHImagePhotoMutilSelector*)
imagePickerTypeCameraStartWithJumpController:(UIViewController*)jumperVC
                     callBackImageDataObject:
                         (id<MHImagePhotoMutilSelectorDelegate>)delegate
                               allowsEditing:(BOOL)allowsEditing;

@end
