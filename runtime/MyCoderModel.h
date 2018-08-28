//
//  MyCoderModel.h
//  Yddworkspace
//
//  Created by ydd on 2018/8/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RuntimeLibrary.h"
#import "NSObject+AddAttribute.h"
@interface MyCoderModel : NSObject<NSCoding>

@property (nonatomic, strong) RuntimeLibrary *library;
@property (nonatomic, copy) NSString *coderID;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *phoneNumber;


@end
