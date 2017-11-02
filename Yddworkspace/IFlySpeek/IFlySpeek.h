//
//  IFlySpeek.h
//  Yddworkspace
//
//  Created by ispeak on 2017/2/10.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol IFlySpeekDelegate <NSObject>

@required

- (void)returnResultStr:(NSString *)resultStr;
- (void)returnErrorCode:(int)code;

@end

@interface IFlySpeek : NSObject

@property (nonatomic, assign) id<IFlySpeekDelegate> delegate;

- (instancetype)initWithView:(UIView *)view;
- (void)understand;
- (void)end;
- (void)releseIFly;
- (void)cancel;
- (void)startAudioStream;
- (void)cancelPromptIsShow:(BOOL)isShow;


@end
