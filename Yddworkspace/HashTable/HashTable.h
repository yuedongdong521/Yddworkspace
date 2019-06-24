//
//  HashTable.h
//  Yddworkspace
//
//  Created by ydd on 2019/5/13.
//  Copyright © 2019 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HashTable : NSObject

+ (instancetype)shareHashTable;

- (void)addObjc:(id)objc;

- (void)intersectHashTable:(NSHashTable *)hashTab;

- (void)removeObjc:(id)objc;

- (void)removeAllObjc;

- (NSArray *)getHashTableArray;

@end

NS_ASSUME_NONNULL_END
