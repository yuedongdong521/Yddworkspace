//
//  TestImageModel.h
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestImageModel : NSObject

@property(nonatomic, strong) NSString *urlStr;
@property(nonatomic, assign) CGSize size;

- (instancetype)initWithUrl:(NSString *)urlStr;

@end
