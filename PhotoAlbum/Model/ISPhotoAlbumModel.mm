//
//  ISPhotoAlbumModel.m
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import "ISPhotoAlbumModel.h"

@implementation ISPhotoAlbumModel
@synthesize asset;
@synthesize assetImg, assetBigImg, originalImage;
@synthesize assetBool;
@synthesize imageSize;

- (instancetype)init {
  self = [super init];
  if (self) {
    asset = [PHAsset new];
    assetBool = NO;
    imageSize = 0.0;
    assetImg = [UIImage new];
    assetBigImg = [UIImage new];
    originalImage = [UIImage new];
  }
  return self;
}

@end
