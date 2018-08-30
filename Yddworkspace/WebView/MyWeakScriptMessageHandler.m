//
//  MyWeakScriptMessageHandler.m
//  Yddworkspace
//
//  Created by ydd on 2018/8/29.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyWeakScriptMessageHandler.h"

@implementation MyWeakScriptMessageHandler

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
  if (self = [super init]) {
    if (delegate) {
      _delegate = delegate;
    }
  }
  return self;
}

- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message {
  if (_delegate &&
      [_delegate respondsToSelector:@selector
       (userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController
                     didReceiveScriptMessage:message];
      }
}


@end
