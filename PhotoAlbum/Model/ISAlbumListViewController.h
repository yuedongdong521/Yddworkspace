//
//  ISAlbumListViewController.h
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import <UIKit/UIKit.h>
@class ISAlbumListViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol ISAlbumListViewControllerDelegate <NSObject>

@required

- (void)albumListViewController:
            (ISAlbumListViewController*)albumListViewController
             didSelectImageList:(NSArray*)imageList;

- (void)dismissAlbumListViewController:
    (ISAlbumListViewController*)albumListViewController;

@end

@interface ISAlbumListViewController : UIViewController

@property(nonatomic, weak, nullable) id<ISAlbumListViewControllerDelegate>
    delegate;

@property(nonatomic, assign) NSInteger albumType;
// 已拥有照片数量
@property(nonatomic, assign) NSInteger hasImageCount;

@end

NS_ASSUME_NONNULL_END
