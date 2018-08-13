//
//  YddOperation.h
//  Yddworkspace
//
//  Created by ispeak on 2018/3/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YddOperationDelegate <NSObject>

- (void)operationBlack;

@end

@interface YddOperation : NSOperation

@property (nonatomic, weak) id <YddOperationDelegate> delegate;

@end
