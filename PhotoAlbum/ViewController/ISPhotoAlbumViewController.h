//
//  ISPhotoAlbumViewController.h
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface ISPhotoAlbumViewController : UIViewController

@property(nonatomic, strong) PHAssetCollection* assetCollection;
@property(nonatomic, assign) NSInteger albumType;
// 已拥有图片数量
@property(nonatomic, assign) NSInteger hasImageCount;

@end
