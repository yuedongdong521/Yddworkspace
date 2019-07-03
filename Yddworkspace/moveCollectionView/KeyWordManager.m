//
//  KeyWordManager.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/28.
//  Copyright © 2019 QH. All rights reserved.
//

#import "KeyWordManager.h"

static KeyWordManager *_manager;

@interface KeyWordManager ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString*>* sensitiveWordDic;

@property (nonatomic, strong) NSString *sensitiveWords;

@property (nonatomic, strong) NSSet *keyWordSet;


@end

@implementation KeyWordManager

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KeyWordManager alloc] init];
    });
    return _manager;
}

- (int)checkSensitiveWord:(NSString *)txt beginIndex:(int)beginIndex
{
    BOOL  flag = NO;    //敏感词结束标识位：用于敏感词只有1位的情况
    int matchFlag = 0;     //匹配标识数默认为0
    int jumpFlag = 0; //可跨越字数
    NSString *word = @"";
    NSMutableDictionary *nowMap = self.sensitiveWordDic;//总词库
    NSMutableDictionary *minMap = [NSMutableDictionary dictionary];
    for(int i = beginIndex; i < txt.length ; i++){
        word = [txt substringWithRange:NSMakeRange(i, 1)];
        minMap = nowMap[word];     //获取指定key
        if(!minMap && matchFlag == 0){
            break;
        }
        if(!minMap){
            if(matchFlag != 0){
                if(jumpFlag > 2){
                    break;
                }
                jumpFlag++;
                matchFlag++;
            }
            continue;
        }else{
            nowMap = minMap;
            matchFlag++;
            jumpFlag = 0;
        }
        if([@"1" isEqualToString:nowMap[@"isEnd"]]){       //如果为最后一个匹配规则,结束循环，返回匹配标识数
            flag = true;       //结束标志位为true
            break;
        }
    }
    if(!flag){
        matchFlag = 0;
    }
    return matchFlag;
}


@end
