//
//  ISCustomCollectionViewLayout.h
//  iShow
//
//  Created by admin on 2017/6/23.
//
//

#import <UIKit/UIKit.h>
#import "ISTemplate.h"
@class ISCollectionViewLayout;

@protocol ISCollectionViewLayoutDelegate <NSObject>

@optional
/**
 最小内容高度
 */
- (CGFloat)minContentHeightOfCollectionViewLayout:
    (ISCollectionViewLayout*)layout;

@end

@interface ISCollectionViewLayout : UICollectionViewLayout

@property(nonatomic, weak) id<ISCollectionViewLayoutDelegate> delegate;

@property(nonatomic, strong) NSMutableArray* templateList;

@end
