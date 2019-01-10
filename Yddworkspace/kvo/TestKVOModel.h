//
//  TestKVOModel.h
//  Yddworkspace
//
//  Created by ydd on 2019/1/10.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestKVOModel : NSObject<NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) NSString *contentStr;

- (void)changeName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
