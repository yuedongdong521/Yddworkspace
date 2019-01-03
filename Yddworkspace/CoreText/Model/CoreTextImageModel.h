//
//  CoreTextImageModel.h
//  Yddworkspace
//
//  Created by ydd on 2018/9/5.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KImageMaxHeight 60
#define KImageMinWidth 20

@interface CoreTextImageModel : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) NSInteger location;
@property(nonatomic, assign) CGRect imageFrame; // 绘制区域

- (instancetype)initWithImageName:(NSString *)name loaction:(NSInteger)location;

/**
 获取在 view 上的展示区域

 @param height view 的 height
 @return <#return value description#>
 */
- (CGRect)getViewRectWithHeight:(CGFloat)height;

@end
