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
@property(nonatomic, assign) CGRect imageFrame;

- (instancetype)initWithImageName:(NSString *)name loaction:(NSInteger)location;

@end
