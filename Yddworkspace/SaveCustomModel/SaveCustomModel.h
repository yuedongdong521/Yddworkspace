//
//  SaveCustomModel.h
//  Yddworkspace
//
//  Created by ydd on 2018/12/3.
//  Copyright © 2018 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SaveCustomModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int num;
@property (nonatomic, assign) int sex;

+(SaveCustomModel *)createCustomModel;
- (void)saveCustomModel;

@end

NS_ASSUME_NONNULL_END
