//
//  ISPhotoAlbumViewCell.h
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol ISPhotoAlbumViewCellDelegate <NSObject>

- (void)chooseNo:(UIButton*)chooseBt;

@end

@interface ISPhotoAlbumViewCell : UICollectionViewCell

@property(nonatomic, readwrite, weak) id<ISPhotoAlbumViewCellDelegate> delegate;

@property(nonatomic, strong) UIImageView* photoImageView;
@property(nonatomic, strong) UIButton* chooseBut;
@property(nonatomic, strong) NSData* imageData;
@property(nonatomic, strong) NSString* imageType;

@end
