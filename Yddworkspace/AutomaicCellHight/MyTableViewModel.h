//
//  MyTableViewModel.h
//  Yddworkspace
//
//  Created by ispeak on 16/10/18.
//  Copyright © 2016年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyTableViewModel : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *headImage;
@property (nonatomic, assign) int uid;
@property (nonatomic, retain) NSString *contentString;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) NSIndexPath *cellIndex;
@property (nonatomic, retain) NSMutableArray *comments;

- (instancetype)initWithDic:(NSDictionary *)dic;


@end
