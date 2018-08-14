//
//  RuntimeLibrary.h
//  Yddworkspace
//
//  Created by ydd on 2018/8/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RuntimeLibrary : NSObject

@property(nonatomic, strong) NSString *project;
@property(nonatomic, strong) NSString *author;

- (NSString *)libraryMethod;

@end
