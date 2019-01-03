//
//  LoadPickerImageTool.m
//  Yddworkspace
//
//  Created by ydd on 2018/12/6.
//  Copyright © 2018 QH. All rights reserved.
//

#import "LoadPickerImageTool.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation PickerImageModel

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

@end

@implementation LoadPickerImageTool

// 获取所有图片
+ (void)loadPickerAllImagesSuccess:(void(^)(NSArray *images))successBlock fail:(void(^)(NSError *error))failBlock
{
  ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
  NSMutableArray *array = [NSMutableArray array];
  __block NSInteger count = 0;
  [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
    NSString *groupName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
    NSLog(@"groupName : %@", groupName);
    if (groupName) {
      PickerImageModel *model = [[PickerImageModel alloc] init];
      model.imageList = [self getImagesFromGroup:group];
      [array addObject:model];
    }
    count ++;
    if (count != array.count) {
      if (successBlock) {
        successBlock([[array reverseObjectEnumerator] allObjects]);
      }
    }
  } failureBlock:^(NSError *error) {
    if (failBlock) {
      failBlock(error);
    }
  }];
}


+ (void)loadImagesFromCamerarollSucess:(void(^)(NSArray *images))sucessBlock failure:(void(^)(NSError *error))failureBlock{
  
  ALAssetsLibrary *library = [ALAssetsLibrary new];
  [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
    NSString *groupName =(NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
    NSLog(@"%@",groupName);
    if ([groupName isEqualToString:@"相机胶卷"] ||[groupName isEqualToString:@"Camera Roll"]) {
      
      NSArray *imagesArray = [self getImagesFromGroup:group];
      if (sucessBlock) {
        sucessBlock(imagesArray);
      }
      
    }
    
  } failureBlock:^(NSError *error) {
    if (failureBlock) {
      failureBlock(error);
    }
  }];
  
}


+ (NSArray *)getImagesFromGroup:(ALAssetsGroup *)group{
  NSMutableArray *imagesArray = [NSMutableArray array];
  
  [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
    
    UIImage *image = [UIImage imageWithCGImage:[result aspectRatioThumbnail]];
    
    if (image) {
      //            image = [image imageCompressForHeight:image targetHeight:150];
      [imagesArray addObject:image];
    }
    
  }];
  return [imagesArray copy];
}


+ (void)loadPhotosAssetSuccess:(void(^)(NSArray *images))successBlock
{
  PHFetchOptions *options = [[PHFetchOptions alloc] init];
  // NSSortDescriptor 按照属性排序， YES 升序，NO 降序
  options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
  options.predicate = [NSPredicate
   predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
  // 获取所有相册资源，并按资源的创建时间排序
  
//  PHFetchResult *results = [PHAsset fetchAssetsWithOptions:options];
  
  PHFetchResult *results = [PHAsset fetchAssetsWithOptions:nil];
  
//  [results enumerateObjectsUsingBlock:^(PHAsset  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
////    [_thumbnails addObject:obj];
////    [_fullPhotos addObject:obj];
//  }];
  
  /*
  synchronous：指定请求是否同步执行。
  resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
  deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
  这个属性只有在 synchronous 为 true 时有效。
  normalizedCropRect：用于对原始尺寸的图像进行裁剪，基于比例坐标。只在 resizeMode 为 Exact 时有效。
  */
  PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
  requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
  requestOptions.synchronous = YES;
  NSMutableArray *mutArr = [NSMutableArray array];
  __block NSInteger count = 0;
  for (NSInteger i = 0; i < results.count; i++) {
    PHAsset *asset = results[i];
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
      if (result) {
        [mutArr addObject:result];
      } else {
        NSLog(@"requestImageForAsset error : %@", info);
      }
      count++;
      if (results.count == count) {
        if (successBlock) {
          successBlock(mutArr);
        }
      }
    }];
  }
  
  
  
}

@end
