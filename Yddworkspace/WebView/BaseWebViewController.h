//
//  BaseWebViewController.h
//  iShow
//
//  Created by ydd on 2018/8/29.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseWebViewController : UIViewController <WKScriptMessageHandler,
                                                         WKNavigationDelegate,
                                                         WKUIDelegate>
#pragma mark - base属性 -
@property(nonatomic, strong, readonly) WKWebView* webView;
// 初始化传入的url
@property(nonatomic, copy, readonly) NSString* urlStr;
// 当前的url
@property(nonatomic, copy, readonly) NSString* currentUrlStr;
#pragma mark - 外部传值 -
// 使用自定义title,默认NO,不使用自定义会自动获取网页的title
@property(nonatomic) BOOL isCustomTitle;
// 网页title，使用自定义需修改isCustomTitle属性
@property(nonatomic, copy) NSString* titleString;

#pragma mark - 以下属性 需重写 -
// 需要监听的脚本命令数组。如果传了，webview会检测相应的js命令，
@property(nonatomic, strong, readonly) NSArray<NSString*>* scriptArray;
// UIImage or NSString
@property(nonatomic, strong, nullable, readonly) id rightNavigationItem;
// 展示失败的placeholder，默认是NO
@property(nonatomic, readonly) BOOL showErrorPlaceholder;

- (instancetype)initWithUrl:(NSString*)urlString;
- (void)back;
- (void)rightNavigationBarButtonItemPressed;

// 监听脚本命令
- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message;

@end

NS_ASSUME_NONNULL_END
