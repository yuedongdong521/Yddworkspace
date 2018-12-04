//
//  ISResizePicViewController.h
//  iShow
//
//  Created by ispeak on 2018/4/12.
//

#import <UIKit/UIKit.h>
#import "ISImageresizerFrameView.h"

@interface ISResizePicViewController : UIViewController
@property(nonatomic, strong) JPImageresizerConfigure* configure;
@property(nonatomic, strong) UIImage* selectedImage;

@end
