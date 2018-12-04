//
//  ISPhotoPreviewViewController.h
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import <UIKit/UIKit.h>

#define AbleToSelectPicCount                            \
  ((self.albumType == CONTACT_PHOTOLIST_WITH_DYNAMIC || \
    self.albumType == CONTACT_PHOTOLIST_WITH_HOMEPAGE)  \
       ? DYNAMICPHOTOMAXCOUNT                           \
       : 9)

typedef void (^BackPhotoAlbumView)(BOOL isBtnSelect,
                                   NSMutableArray* chooseImageArray);

@interface ISPhotoPreviewViewController : UIViewController

@property(nonatomic, strong) NSArray* photoArray;
@property(nonatomic, strong) NSMutableArray* chooseImageArray;
@property(nonatomic, assign) NSUInteger cellCount;
@property(nonatomic, assign) float photoImageSize;
@property(nonatomic, assign) BOOL isBtnSelected;
@property(nonatomic, assign) NSInteger albumType;
@property(nonatomic, strong) UIButton* originalBtn;

@property(nonatomic, copy) BackPhotoAlbumView backPhotoAlbumView;
// 已拥有照片数量
@property(nonatomic, assign) NSInteger hasImageCount;

@end
