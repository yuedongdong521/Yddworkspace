//
//  PriaseSendStructure.h
//  Yddworkspace
//
//  Created by ispeak on 2017/2/25.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PriaseSendStructure : NSObject

@property (nonatomic ,assign)  NSInteger uid;
@property (nonatomic ,assign)  NSInteger showid;
@property (nonatomic ,assign)  int iconIndex;
@property (nonatomic ,retain)  NSString*username;
@property (nonatomic ,retain)  NSString*content;
@property (nonatomic ,retain)  NSString*timeString;
@property (nonatomic ,assign)  int type;
@property (nonatomic ,assign) int sex;
@property (nonatomic ,assign)int seq;
@property (nonatomic ,assign) int rank;
@property (nonatomic, assign) NSInteger sealnewUser;
@property (nonatomic ,assign) int send_user_seal_id;
@property (nonatomic,assign) int receive_ser_seal_id;
@property (nonatomic, assign) int clientType;
@property (nonatomic ,assign) BOOL isForbidden;
@property (nonatomic, assign) int rankCustom;
@property (nonatomic, strong) NSString*imagePathStr;
@property (nonatomic, strong) UIColor *wordColor;
@property (nonatomic ,strong) UIColor*nameColor;
@property (nonatomic, assign) CGFloat cellHight;
@property (nonatomic, assign) BOOL isActivity;
@property (nonatomic, assign) NSInteger customnum;
@property (nonatomic, assign) BOOL isPublicMessege;
@property (nonatomic, assign) int mount;


@end
