//
//  EditVideoViewController.h
//  iShow
//
//  Created by ydd on 17/3/8.
//
//

#import <UIKit/UIKit.h>

@interface EditVideoViewController : UIViewController

@property(nonatomic, retain) NSURL* videoURL;
@property(nonatomic, assign) NSInteger pageFromFlg;  // 来源页面
@property(nonatomic, assign) BOOL isPrivateAlbum;  // 私密动态标志
// 活动id
@property(nonatomic, assign) NSInteger activeId;
// 活动名称
@property(nonatomic, copy) NSString* actTitle;

@end
