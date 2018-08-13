//
//  ISTemplate.h
//  TestCollectionViewLayout
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 com.zhanglei.testshange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ISTemplate : NSObject

@property(nonatomic, strong) NSMutableArray* itemFrameList;
@property(nonatomic) CGRect headerFrame;
@property(nonatomic) CGRect footerFrame;
@property(nonatomic) CGRect decorationFrame;
@property(nonatomic) CGFloat contentHeight;

@property(nonatomic) NSUInteger sectionIndex;

+ (ISTemplate*)defaultTemplateWithSectionIndex:(NSInteger)sectionIndex;

- (void)updateItemsFrameAndConetentHeightWithTopOffset:(CGFloat)topContentOffset
                                         numberOfItems:(NSInteger)numberOfItems;

@end
