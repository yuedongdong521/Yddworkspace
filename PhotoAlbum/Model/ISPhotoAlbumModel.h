//
//  ISPhotoAlbumModel.h
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface ISPhotoAlbumModel : NSObject

@property(nonatomic, strong) PHAsset* asset;
@property(nonatomic, assign) BOOL assetBool;
@property(nonatomic, assign) float imageSize;
@property(nonatomic, strong) UIImage* assetImg;
@property(nonatomic, strong) UIImage* assetBigImg;
@property(nonatomic, strong) UIImage* originalImage;

@end
