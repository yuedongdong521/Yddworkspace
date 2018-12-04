//
//  ISAssetsManager.m
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import "ISAssetsManager.h"
#import "ISPhotoAlbumModel.h"

@implementation ISAssetsManager

static ISAssetsManager* assetsManager = nil;

+ (instancetype)sharedInstancetype {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    assetsManager = [[super alloc] init];
  });
  return assetsManager;
}

+ (instancetype)allocWithZone:(struct _NSZone*)zone {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    assetsManager = [super allocWithZone:zone];
  });
  return assetsManager;
}

- (NSArray*)
fetchAllAlbumsWithAlbumContentTypeShowEmptyAlbum:(BOOL)showEmptyAlbum
                                  showSmartAlbum:(BOOL)showSmartAlbum {
  NSMutableArray* albumsArray = [[NSMutableArray alloc] init];

  PHFetchOptions* fetchOptions = [[PHFetchOptions alloc] init];
  fetchOptions.predicate = [NSPredicate
      predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
  PHFetchResult<PHAssetCollection*>* fetchResult;
  if (showSmartAlbum) {
    // 允许智能相册
    fetchResult = [PHAssetCollection
        fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                              subtype:PHAssetCollectionSubtypeAny
                              options:nil];
  } else {
    // 不允许智能相册，添加相机胶卷
    fetchResult = [PHAssetCollection
        fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                              subtype:PHAssetCollectionSubtypeAlbumRegular
                              options:nil];
  }

  for (PHCollection* collection in fetchResult) {
    if ([collection isKindOfClass:[PHAssetCollection class]]) {
      PHAssetCollection* assetCollection = (PHAssetCollection*)collection;
      PHFetchResult* phFetchResult =
          [PHAsset fetchAssetsInAssetCollection:assetCollection
                                        options:fetchOptions];
      // 若相册不为空，或者允许显示空相册，则保存相册到结果数组
      if (phFetchResult.count > 0 /* || showEmptyAlbum*/) {
        // 相机胶卷放第一位
        if (assetCollection.assetCollectionSubtype ==
            PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
          [albumsArray insertObject:assetCollection atIndex:0];
        } else {
          [albumsArray addObject:assetCollection];
        }
      }
    }
  }
  // 所有用户创建的相册
  PHFetchResult* userFetchResult =
      [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
  for (PHCollection* collection in userFetchResult) {
    if ([collection isKindOfClass:[PHAssetCollection class]]) {
      PHAssetCollection* userAssetCollection = (PHAssetCollection*)collection;
      PHFetchResult* userFetchResult =
          [PHAsset fetchAssetsInAssetCollection:userAssetCollection
                                        options:fetchOptions];
      if (showEmptyAlbum) {
        // 允许显示空相册
        [albumsArray addObject:userAssetCollection];
      } else {
        if (userFetchResult.count > 0) {
          [albumsArray addObject:userAssetCollection];
        }
      }
    }
  }
  NSArray* resultAlbumsArray = [albumsArray copy];
  return resultAlbumsArray;
}

- (PHAsset*)fetchNewAssetWithAssetCollection:
    (PHAssetCollection*)assetCollection {
  PHFetchOptions* fetchOptions = [[PHFetchOptions alloc] init];
  fetchOptions.predicate = [NSPredicate
      predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
  // 为NO按时间从前往后排， YES相反
  // fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
  PHFetchResult* fetchResult =
      [PHAsset fetchAssetsInAssetCollection:assetCollection
                                    options:fetchOptions];
  PHAsset* lastAsset = fetchResult.lastObject;
  return lastAsset;
}

- (NSArray*)enumerateAssetsWithAssetCollection:
    (PHAssetCollection*)assetCollection {
  NSMutableArray* assetMutArray = [[NSMutableArray alloc] init];
  PHFetchOptions* option = [[PHFetchOptions alloc] init];
  option.predicate = [NSPredicate
      predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
  // 获得某个相簿中的所有PHAsset对象
  PHFetchResult<PHAsset*>* assets =
      [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
  [assets enumerateObjectsUsingBlock:^(PHAsset* _Nonnull obj, NSUInteger idx,
                                       BOOL* _Nonnull stop) {
    ISPhotoAlbumModel* albumModel = [[ISPhotoAlbumModel alloc] init];
    albumModel.asset = obj;
    [assetMutArray addObject:albumModel];
  }];
  return [assetMutArray copy];
}

- (void)posterImageWithPHAsset:(PHAsset*)asset
                 imageWithSize:(CGSize)size
                   contentMode:(PHImageContentMode)contentMode
                    completion:(void (^)(UIImage* AssetImage))completion {
  PHImageRequestOptions* pHImageRequestOptions =
      [[PHImageRequestOptions alloc] init];
  // 同步获得图片, 只会返回1张图片
  pHImageRequestOptions.synchronous = YES;
  pHImageRequestOptions.networkAccessAllowed = NO;
  pHImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
  [[PHImageManager defaultManager]
      requestImageForAsset:asset
                targetSize:size
               contentMode:contentMode
                   options:pHImageRequestOptions
             resultHandler:^(UIImage* _Nullable result,
                             NSDictionary* _Nullable info) {
               completion(result);
             }];
}
// 区分图片类型
- (void)judgeImageWithPHAsset:(PHAsset*)asset
                   completion:(void (^)(NSData* imageData,
                                        NSString* dataUTI))completion {
  PHImageRequestOptions* pHImageRequestOptions =
      [[PHImageRequestOptions alloc] init];
  [[PHImageManager defaultManager]
      requestImageDataForAsset:asset
                       options:pHImageRequestOptions
                 resultHandler:^(NSData* _Nullable imageData,
                                 NSString* _Nullable dataUTI,
                                 UIImageOrientation orientation,
                                 NSDictionary* _Nullable info) {
                   if (completion) {
                     completion(imageData, dataUTI);
                   }
                 }];
}

- (void)posterOriginalImageWithPHAsset:(PHAsset*)asset
                            completion:(void (^)(NSData* assetData))completion {
  PHImageRequestOptions* pHImageRequestOptions =
      [[PHImageRequestOptions alloc] init];
  pHImageRequestOptions.synchronous = YES;
  pHImageRequestOptions.networkAccessAllowed = YES;
  pHImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
  [[PHImageManager defaultManager]
      requestImageDataForAsset:asset
                       options:pHImageRequestOptions
                 resultHandler:^(NSData* _Nullable imageData,
                                 NSString* _Nullable dataUTI,
                                 UIImageOrientation orientation,
                                 NSDictionary* _Nullable info) {
                   completion(imageData);
                   //    BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                   //    if (downloadFinined) {
                   //      completion(imageData);
                   //    }
                 }];
}

- (NSUInteger)fetchAlbumsCountWithAssetCollection:
    (PHAssetCollection*)assetCollection {
  PHFetchOptions* option = [[PHFetchOptions alloc] init];
  option.predicate = [NSPredicate
      predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
  PHFetchResult* phFetchResult =
      [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
  return phFetchResult.count;
}

@end
