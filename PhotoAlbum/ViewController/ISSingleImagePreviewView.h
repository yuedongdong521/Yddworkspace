//
//  ISSingleImagePreviewView.h
//  iShow
//
//  Created by admin on 2017/5/25.
//
//

#import <UIKit/UIKit.h>
#import "ISPhotoAlbumModel.h"

@interface ISSingleImagePreviewView : UIViewController

@property(nonatomic, strong) ISPhotoAlbumModel* albumModel;
@property(nonatomic, assign) NSInteger albumType;

@end
