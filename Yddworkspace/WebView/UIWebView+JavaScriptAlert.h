//
//  UIWebView+JavaScriptAlert.h
//  Yddworkspace
//
//  Created by ydd on 2018/7/25.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (JavaScriptAlert)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;

@end
