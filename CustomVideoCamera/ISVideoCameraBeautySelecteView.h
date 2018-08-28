//
//  ISVideoCameraBeautySelecteView.h
//  iShow
//
//  Created by student on 2017/7/24.
//
//

#import <UIKit/UIKit.h>

@class ISVideoCameraBeautySelecteView;
@protocol ISVideoCameraBeautySelecteViewDelegate <NSObject>
@optional

/**
 选中的美颜等级
 
 @param selectView 选择视图
 @param count 选中的item的等级 0 - 5之间
 */
- (void)selecteView:(ISVideoCameraBeautySelecteView*)selectView
     didSelctedItem:(NSInteger)count;
- (void)selecteView:(ISVideoCameraBeautySelecteView*)selectView
    whiteSliderChanged:(UISlider*)sender;  // 美白
- (void)selecteView:(ISVideoCameraBeautySelecteView*)selectView
    buffingSliderChanged:(UISlider*)sender;  // 磨皮
// - (void)selecteView:(ISVideoCameraBeautySelecteView *)selectView bigEyesSliderChanged:(UISlider *)sender;   // 大眼
// - (void)selecteView:(ISVideoCameraBeautySelecteView *)selectView thinFaceSliderChanged:(UISlider *)sender;  // 瘦脸
- (void)selecteViewWillDismiss;

@end

@interface ISVideoCameraBeautySelecteView : UIView

@property(nonatomic, weak) id<ISVideoCameraBeautySelecteViewDelegate> delegate;

- (void)showInView:(UIView*)supView completion:(void (^)(void))completion;
- (void)dismissView:(void (^)(void))completion;
- (void)recoveryBeforeState;
@end
