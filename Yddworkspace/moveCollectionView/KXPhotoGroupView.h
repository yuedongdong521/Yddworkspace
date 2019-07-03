//
//  KXPhotoGroupView.h
//  Yddworkspace
//
//  Created by ydd on 2019/6/27.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KXPhotoGroupView;

NS_ASSUME_NONNULL_BEGIN


@protocol KXPhotoGroupViewDelegate <NSObject>

- (UIView *)photoGroupView:(KXPhotoGroupView*)photoGroupView getThumbViewWithPage:(NSInteger)page;
- (UIImage *)photoGroupView:(KXPhotoGroupView*)photoGroupView getImageWithPage:(NSInteger)page;

@end

/// Single picture's info.
@interface KXPhotoGroupItem : NSObject
@property (nonatomic, strong) NSURL *largeImageURL;
@property (nonatomic, assign) NSInteger index;
@end

/// Used to show a group of images.
/// One-shot.
@interface KXPhotoGroupView : UIView

@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, assign) BOOL blurEffectBackground; ///< Default is YES
@property (nonatomic, weak) id <KXPhotoGroupViewDelegate>delegate;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithGroupItems:(NSArray *)groupItems;


- (void)presentFromCurItem:(NSInteger)curItem
               toContainer:(UIView *)toContainer
                  animated:(BOOL)animated
                 ompletion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss;

- (void)hiddenPageControl:(BOOL)isHidden;
@end


NS_ASSUME_NONNULL_END
