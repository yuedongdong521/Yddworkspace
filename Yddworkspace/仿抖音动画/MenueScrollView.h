//
//  MenueScrollView.h
//  Yddworkspace
//
//  Created by ydd on 2020/11/5.
//  Copyright © 2020 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenueScrollView;

typedef NS_ENUM(NSUInteger, MenueAnimationType) {
    MenueAnimationType_default = 0,
    MenueAnimationType_line,
};

NS_ASSUME_NONNULL_BEGIN

@protocol MenueScrollViewDelegate <NSObject>

- (void)menue:(MenueScrollView *)view selectedIndex:(NSInteger)index;

@end

@interface MenueScrollView : UIView

@property (nonatomic, strong) NSArray *menues;

@property (nonatomic, assign) NSInteger seletcedIndex;

@property (nonatomic, assign) CGFloat scrollIndex;

@property (nonatomic, assign) CGFloat space;

@property (nonatomic, assign) CGFloat leftSpace;

@property (nonatomic, assign) CGFloat rightSpace;

@property (nonatomic, weak) id<MenueScrollViewDelegate>delegate;

@property (nonatomic, assign) MenueAnimationType animationType;

@end

NS_ASSUME_NONNULL_END
