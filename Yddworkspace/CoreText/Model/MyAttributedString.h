//
//  MyAttributedString.h
//  Yddworkspace
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface MyAttributedString : NSObject

@property (nonatomic, strong) NSString *font; //字体
@property (nonatomic, strong) UIColor *color; //文本颜色
@property (nonatomic, strong) UIColor *strokeColor; //画笔颜色
@property (nonatomic, assign) float strokeWidth; //画笔宽度
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, assign) CGSize contentSize;

- (instancetype)initWithSize:(CGSize)size;

- (NSAttributedString *)attrStringFromMark:(NSString *)mark;

@end
