//
//  HashTable.m
//  Yddworkspace
//
//  Created by ydd on 2019/5/13.
//  Copyright © 2019 QH. All rights reserved.
//

#import "HashTable.h"

static HashTable *_hashTable;

@interface HashTable ()
/** 存入弱引用对象,对象释放后自动删除表 */
@property (nonatomic, strong) NSHashTable *weakHashTable;

@end

@implementation HashTable

+ (instancetype)shareHashTable
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hashTable = [[HashTable alloc] init];
    });
    return _hashTable;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (NSHashTable *)weakHashTable
{
    if (!_weakHashTable) {
        _weakHashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _weakHashTable;
}


- (void)addObjc:(id)objc
{
    [self.weakHashTable addObject:objc];
}

- (void)intersectHashTable:(NSHashTable *)hashTab
{
    if (![self.weakHashTable isSubsetOfHashTable:hashTab]) {
        [self.weakHashTable intersectHashTable:hashTab];
    }
}

- (void)removeObjc:(id)objc
{
    if ([self.weakHashTable containsObject:objc]) {
        [self.weakHashTable removeObject:objc];
    }
}

- (void)removeAllObjc
{
    [self.weakHashTable removeAllObjects];
}

- (NSArray *)getHashTableArray
{
    return self.weakHashTable.allObjects;
}


@end
