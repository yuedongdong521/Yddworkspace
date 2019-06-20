//
//  UINavigationController+yddSubByte.m
//  Yddworkspace
//
//  Created by ydd on 2019/4/25.
//  Copyright © 2019 QH. All rights reserved.
//

#import "UINavigationController+yddSubByte.h"

@implementation UINavigationController (yddSubByte)

- (NSString *)subStringToByteIndex:(NSInteger)index
{
    NSInteger sum = 0;
    NSString *subStr = [[NSString alloc] init];
    for(int i = 0; i<[self length]; i++){
        unichar strChar = [self characterAtIndex:i];
        if(strChar < 256){
            sum += 1;
        }
        else {
            sum += 2;
        }
        if (sum > index) {
            subStr = [self substringToIndex:i];
            return subStr;
        }
    }
    return self;
}

- (NSString *)subStringFormByteIndex:(NSInteger)index
{
    NSInteger sum = 0;
    NSString *subStr = [[NSString alloc] init];
    for(int i = 0; i<[self length]; i++){
        unichar strChar = [self characterAtIndex:i];
        if(strChar < 256){
            sum += 1;
        }
        else {
            sum += 2;
        }
        if (sum > index) {
            subStr = [self substringFromIndex:i];
            return subStr;
        }
    }
    return self;
}



@end
