//
//  ISEditingPhotoController.h
//  iShow
//
//  Created by run on 2017/10/27.
//

#import <UIKit/UIKit.h>

@interface ISEditingPhotoController : UIViewController

@property(nonatomic, strong) UIImage* photoImage;
@property(nonatomic, assign) BOOL isPrivateAlbum;

@property(nonatomic, assign) NSInteger pageFromFlg;  // 来源页面
@property(nonatomic, assign) BOOL isFromTakePhoto;
// 活动id
@property(nonatomic, assign) NSInteger activeId;
// 活动名称
@property(nonatomic, copy) NSString* actTitle;

@end
