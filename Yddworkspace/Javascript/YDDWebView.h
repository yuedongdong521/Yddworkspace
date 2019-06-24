//
//  YDDWebView.h
//  Yddworkspace
//
//  Created by ydd on 2019/6/21.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@class YDDWebView;

NS_ASSUME_NONNULL_BEGIN

typedef void(^JavasprictBlock)(id body);

@protocol YDDWebViewDelegate <NSObject>

@optional
- (void)webView:(YDDWebView*)webView startLoadNavigation:(WKNavigation *)navigation;

- (void)webView:(YDDWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
/** 加载主web失败 */
- (void)webView:(YDDWebView *)webView didFailMainNavigation:(WKNavigation *)navigation error:(NSError *)error;

/** 加载新的web失败 */
- (void)webView:(YDDWebView *)webView didFailNewNavigation:(WKNavigation *)navigation error:(NSError *)error;

- (void)webView:(YDDWebView *)webView loadProgress:(CGFloat)progress;

/** 用于拦截web加载的url */
- (void)webView:(YDDWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

@end


@interface YDDWebView : UIView

@property (nonatomic, copy, readonly) NSString *currentURL;
@property (nonatomic, assign, readonly) BOOL canGoBack;

@property (nonatomic, weak) id <YDDWebViewDelegate> delegate;

- (void)startLoadWithUrl:(NSString *)url;
- (void)startLoadRequest:(NSURLRequest *)request;
- (void)startLoadFileURL:(NSURL *)fileURL accessURL:(NSURL *)accessURL;
- (void)stopLoad;
- (nullable WKNavigation *)reload;
- (nullable WKNavigation *)goBack;
- (void)clearCache;

/** 调用js方法 */
- (void)callJavaScriptAction:(NSString *)action completionHandler:(void(^)(id result, NSError *error))completionHandler;

- (void)addJavaScriptAction:(NSString *)actionName actionBlock:(JavasprictBlock)actionBlock;


- (void)removeJavaScriptAction:(NSString *)actionName;

- (void)removeJavascrpitActionAll;

@end

NS_ASSUME_NONNULL_END
