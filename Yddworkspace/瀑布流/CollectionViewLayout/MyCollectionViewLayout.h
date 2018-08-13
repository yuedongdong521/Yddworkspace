//
//  MyCollectionViewLayout.h
//  Yddworkspace
//
//  Created by ydd on 2018/5/18.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionDataModel.h"
@class MyCollectionViewLayout;

@protocol ISIMCollectionViewLayoutDelegate <NSObject>

@optional
/**
 最小内容高度
 */
- (CGFloat)minContentHeightOfCollectionViewLayout:(MyCollectionViewLayout*)layout;

@end
@interface MyCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, strong) NSMutableArray<CollectionDataModel*> *itemListArray;

@property (nonatomic, assign) CGFloat contentViewHeight;
@property(nonatomic, weak) id<ISIMCollectionViewLayoutDelegate> delegate;

@end
