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






@end
