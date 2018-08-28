//
//  ISTakePhotoController.h
//  iShow
//
//  Created by run on 2017/10/28.
//  仅拍照界面。

#import <UIKit/UIKit.h>

@interface ISTakePhotoController : UIViewController

// 私密专辑
@property(nonatomic, assign) NSInteger privateFlg;
// 页面来源
@property(nonatomic, assign) NSInteger pageFromFlg;
@property(nonatomic, assign) BOOL ispushToController;  // 是否是push出来的方式
// 活动id
@property(nonatomic, assign) NSInteger activeId;
// 活动名称
@property(nonatomic, copy) NSString* actTitle;

@end
