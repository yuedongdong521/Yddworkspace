//
//  MyWeakScriptMessageHandler.h
//  Yddworkspace
//
//  Created by ydd on 2018/8/29.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@interface MyWeakScriptMessageHandler : NSObject<WKScriptMessageHandler>
@property(nonatomic, weak) id<WKScriptMessageHandler> delegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate;
@end
