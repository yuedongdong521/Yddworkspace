//
//  ISAssetsManager.h
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface ISAssetsManager : NSObject

+ (instancetype)sharedInstancetype;
// 获取所有相册 第一个BOOL判断是否允许空的相册 第二个BOOL判断是否加入系统智能相册
- (NSArray*)
fetchAllAlbumsWithAlbumContentTypeShowEmptyAlbum:(BOOL)showEmptyAlbum
                                  showSmartAlbum:(BOOL)showSmartAlbum;
// 获取单个相册最新的图片
- (PHAsset*)fetchNewAssetWithAssetCollection:
    (PHAssetCollection*)assetCollection;

- (NSArray*)enumerateAssetsWithAssetCollection:
    (PHAssetCollection*)assetCollection;

- (NSUInteger)fetchAlbumsCountWithAssetCollection:
    (PHAssetCollection*)assetCollection;

- (void)posterImageWithPHAsset:(PHAsset*)asset
                 imageWithSize:(CGSize)size
                   contentMode:(PHImageContentMode)contentMode
                    completion:(void (^)(UIImage* AssetImage))completion;

// 区分图片类型
- (void)judgeImageWithPHAsset:(PHAsset*)asset
                   completion:(void (^)(NSData* imageData,
                                        NSString* dataUTI))completion;

- (void)posterOriginalImageWithPHAsset:(PHAsset*)asset
                            completion:(void (^)(NSData* assetData))completion;

@end
