//
//  EditingPublishingDynamicViewController.h
//  iShow
//
//  Created by 胡阳阳 on 17/3/18.
//
//

#import <UIKit/UIKit.h>

@interface EditingPublishingDynamicViewController : UIViewController

@property(nonatomic, retain) NSURL* videoURL;
@property(nonatomic, assign) NSInteger pageFromFlg;

@property(nonatomic) BOOL isPriveteDynamicType;  // 私密动态标志
// 活动id
@property(nonatomic, assign) NSInteger activeId;
// 活动名称
@property(nonatomic, copy) NSString* actTitle;

@end
