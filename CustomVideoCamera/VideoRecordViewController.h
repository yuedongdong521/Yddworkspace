//
//  VideoRecordViewController.h
//  iShow
//
//  Created by 胡阳阳 on 17/3/8.
//
//

#import <UIKit/UIKit.h>

@interface VideoRecordViewController : UIViewController

@property(nonatomic, assign) NSInteger pageFromFlg;  // 来源页面
@property(nonatomic, assign) BOOL isPrivateAlbum;  // 私密标志
// 活动id
@property(nonatomic, assign) NSInteger activeId;
// 活动名称
@property(nonatomic, copy) NSString* actTitle;

@end
