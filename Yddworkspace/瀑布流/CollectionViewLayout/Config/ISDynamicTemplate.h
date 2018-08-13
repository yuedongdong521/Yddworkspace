//
//  ISTemplate.h
//  iShow
//
//  Created by apple on 2017/8/19.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ISTemplate.h"

@class ISDynamicTemplate;

@protocol ISDynamicTemplateDelegate <NSObject>

@optional
/**
 item的宽高比例：宽度/高度
 如果没有特殊比例，返回0；
 */
- (CGFloat)ratioForItemSizeSection:(NSInteger)section
                      templateItem:(ISDynamicTemplate*)templateItem;
- (CGSize)originalItemSizeSection:(NSInteger)section
                     templateItem:(ISDynamicTemplate*)templateItem;
- (CGFloat)heightForHeaderInSection:(NSInteger)section
                       templateItem:(ISDynamicTemplate*)templateItem;
- (CGFloat)heightForFooterInSection:(NSInteger)section
                       templateItem:(ISDynamicTemplate*)templateItem;

- (NSInteger)numberOfItemsInSection:(NSInteger)section
                       templateItem:(ISDynamicTemplate*)templateItem;

- (CGFloat)topInsetOfSection:(NSInteger)section
                templateItem:(ISDynamicTemplate*)templateItem;
- (CGFloat)bottomInsetOfSection:(NSInteger)section
                   templateItem:(ISDynamicTemplate*)templateItem;

- (BOOL)shouldShowDecorationViewInSection:(NSInteger)section
                             templateItem:(ISDynamicTemplate*)templateItem;

@end

@interface ISDynamicTemplate : ISTemplate

@property(nonatomic, weak) id<ISDynamicTemplateDelegate> delegate;

@end
