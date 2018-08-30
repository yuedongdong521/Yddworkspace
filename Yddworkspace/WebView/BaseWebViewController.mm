//
//  BaseWebViewController.m
//  iShow
//
//  Created by ydd on 2018/8/29.
//

#import "BaseWebViewController.h"
#import "MyWeakScriptMessageHandler.h"
#import "KVOController.h"

#define kRequstUrlTimeoutInt 30
// webView网页加载进度
NSString* const kWebViewEstimatedProgress = @"estimatedProgress";
NSString* const kWebViewTitle = @"title";
NSString* const kWebViewURL = @"URL";

@interface BaseWebViewController ()

@property(nonatomic, strong, readwrite) WKWebView* webView;
@property(nonatomic, copy, readwrite) NSString* urlStr;
@property(nonatomic, copy, readwrite) NSString* currentUrlStr;
// 加载进度条
@property(nonatomic, strong) UIProgressView* progressView;
// 加载失败，点击重试
@property(nonatomic, strong) UIScrollView* errorPlaceHolderView;
@property(nonatomic, readwrite) BOOL showErrorPlaceholder;
@end

@implementation BaseWebViewController

- (void)dealloc {
  if (self.scriptArray && self.scriptArray.count > 0) {
    for (NSString* scriptName in self.scriptArray) {
      [_webView.configuration.userContentController
          removeScriptMessageHandlerForName:scriptName];
    }
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self initUI];
  if (!_isCustomTitle) {
    [self.KVOController observe:_webView
                        keyPath:kWebViewTitle
                        options:NSKeyValueObservingOptionNew
                         action:@selector(wkWebViewTitleDidChange:)];
  } else {
    self.title = self.titleString;
  }

  [self.KVOController observe:_webView
                      keyPath:kWebViewEstimatedProgress
                      options:NSKeyValueObservingOptionNew
                       action:@selector(wkWebViewEstimatedProgressDidChange:)];
  [self.KVOController observe:_webView
                      keyPath:kWebViewURL
                      options:NSKeyValueObservingOptionNew
                       action:@selector(wkWebViewURLDidChange:)];
  [self loadWebViewWithUrlString:self.urlStr];
}

#pragma mark - kvo -
- (void)wkWebViewURLDidChange:(NSDictionary<NSString*, id>*)change {
  NSString* urlStr = self.webView.URL.absoluteString;
  if (urlStr.length > 0) {
    self.currentUrlStr = urlStr;
  }
}
- (void)wkWebViewTitleDidChange:(NSDictionary<NSString*, id>*)change {
  NSString* title = self.webView.title;
  _titleString = [NSString stringWithFormat:@"%@", title];
  self.title = title;
}

- (void)wkWebViewEstimatedProgressDidChange:
    (NSDictionary<NSString*, id>*)change {
  [self.progressView setAlpha:1.0f];
  BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
  [self.progressView setProgress:self.webView.estimatedProgress
                        animated:animated];

  if (self.webView.estimatedProgress >= 1.0f) {
    [UIView animateWithDuration:0.3f
        delay:0.3f
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
          [self.progressView setAlpha:0.0f];
        }
        completion:^(BOOL finished) {
          [self.progressView setProgress:0.0f animated:NO];
        }];
  }
}

#pragma mark - lazy load -
- (UIProgressView*)progressView {
  if (!_progressView) {
    _progressView = [[UIProgressView alloc]
        initWithProgressViewStyle:UIProgressViewStyleDefault];
    [_progressView setTrackTintColor:[UIColor colorWithRed:240.0 / 255 green:240.0 / 255 blue:240.0 / 255 alpha:240.0 / 255]];
    _progressView.progressTintColor = [UIColor colorWithRed:254.0 / 255 green:219.0 / 255 blue:50.0 / 255 alpha:1];
    _progressView.frame =
        CGRectMake(0, kStatusAndNavBarHeight, ScreenWidth, 2.5);
  }
  return _progressView;
}

- (WKWebView*)webView {
  if (_webView == nil) {
    WKWebViewConfiguration* configuration =
        [[WKWebViewConfiguration alloc] init];

    WKUserContentController* userContent =
        [[WKUserContentController alloc] init];
    MyWeakScriptMessageHandler* weakHandler =
        [[MyWeakScriptMessageHandler alloc] initWithDelegate:self];
    // 调用JS方法
    if (self.scriptArray && self.scriptArray.count > 0) {
      for (NSString* scriptName in self.scriptArray) {
        [userContent addScriptMessageHandler:weakHandler name:scriptName];
      }
    }

    configuration.userContentController = userContent;

    WKPreferences* preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;

    _webView = [[WKWebView alloc]
        initWithFrame:CGRectMake(0, kStatusAndNavBarHeight, ScreenWidth,
                                 ScreenHeight - kStatusAndNavBarHeight)
        configuration:configuration];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
  }
  return _webView;
}


- (UIScrollView*)errorPlaceHolderView {
  if (_errorPlaceHolderView == nil) {
    _errorPlaceHolderView = [[UIScrollView alloc] init];
    _errorPlaceHolderView.backgroundColor = [UIColor whiteColor];
    _errorPlaceHolderView.frame =
        CGRectMake(0, kStatusAndNavBarHeight, ScreenWidth,
                   ScreenHeight - kStatusAndNavBarHeight);
    _errorPlaceHolderView.showsVerticalScrollIndicator = NO;
    _errorPlaceHolderView.showsHorizontalScrollIndicator = NO;
    _errorPlaceHolderView.alwaysBounceVertical = YES;

    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
                  action:@selector(reloadWebView:)
        forControlEvents:UIControlEventTouchUpInside];
    button.frame =
        CGRectMake(0, 0, ScreenWidth, ScreenHeight - kStatusAndNavBarHeight);
    [_errorPlaceHolderView addSubview:button];
  }
  return _errorPlaceHolderView;
}

#pragma mark - config -
- (instancetype)initWithUrl:(NSString*)urlString {
  self = [super init];
  if (self) {
    _isCustomTitle = NO;
    _titleString = @"";
    _showErrorPlaceholder = NO;
    _urlStr = [urlString copy];
    self.currentUrlStr = [urlString copy];
  }
  return self;
}

- (void)initUI {
  [self.view addSubview:self.webView];
  [self.view addSubview:self.progressView];
}

#pragma mark - action -
- (void)leftBtnPressed {
  if ([self.webView canGoBack]) {
    [self.webView goBack];
  } else {
    [self back];
  }
}

- (void)rightNavigationBarButtonItemPressed {
}

- (void)back {
}

- (void)reloadWebView:(UIButton*)sender {
  if (_errorPlaceHolderView && self.errorPlaceHolderView.superview) {
    [self.errorPlaceHolderView removeFromSuperview];
  }
  [self.webView stopLoading];
  [self.webView reload];
}

#pragma mark - WKScriptMessageHandler -
- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message {
}

#pragma mark - WKNavigationDelegate -
- (void)webView:(WKWebView*)webView
    decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction
                    decisionHandler:
                        (void (^)(WKNavigationActionPolicy))decisionHandler {
  if (webView != _webView) {
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
  }

  UIApplication* application = [UIApplication sharedApplication];
  NSURL* URL = navigationAction.request.URL;

  if (![self externalAppRequiredToOpenURL:URL]) {
    if (!navigationAction.targetFrame) {
      [self loadURL:URL];
      decisionHandler(WKNavigationActionPolicyCancel);
      return;
    }
  } else if ([application canOpenURL:URL]) {
    [application openURL:URL];
    decisionHandler(WKNavigationActionPolicyCancel);
    return;
  }

  decisionHandler(WKNavigationActionPolicyAllow);
}

// 开始加载
- (void)webView:(WKWebView*)webView
    didStartProvisionalNavigation:(WKNavigation*)navigation {
  NSLog(@"开始加载网页");
  // 开始加载的时候，让进度条显示
  self.progressView.hidden = NO;
  self.progressView.alpha = 1;
}

// 当内容开始返回时调用
- (void)webView:(WKWebView*)webView
    didCommitNavigation:(WKNavigation*)navigation {
}

- (void)webView:(WKWebView*)webView
    didFinishNavigation:(WKNavigation*)navigation {
}

- (void)webView:(WKWebView*)webView
    didFailNavigation:(WKNavigation*)navigation
            withError:(NSError*)error {
  NSLog(@"加载失败errorCode:%@", @(error.code));
  if (error.code == NSURLErrorCancelled) {
    return;
  }
  if (error.code == NSURLErrorNetworkConnectionLost) {
    return;
  }

  if (self.showErrorPlaceholder) {
    [self showErrorPlaceHolderView];
  }
}

- (void)webView:(WKWebView*)webView
    didFailProvisionalNavigation:(WKNavigation*)navigation
                       withError:(NSError*)error {
  NSLog(@"加载失败errorCode:%@", @(error.code));
  if (error.code == NSURLErrorCancelled) {
    return;
  }
  if (error.code == 102) {
    // bugly下载ipa时会调用此代理，此时错误码102并不算失败。
    return;
  }

  if (self.showErrorPlaceholder) {
    [self showErrorPlaceHolderView];
  }
}

#pragma mark - WKUIDelegate -
- (void)webView:(WKWebView*)webView
    runJavaScriptAlertPanelWithMessage:(NSString*)message
                      initiatedByFrame:(WKFrameInfo*)frame
                     completionHandler:(void (^)(void))completionHandler {
  UIAlertController* alertController =
      [UIAlertController alertControllerWithTitle:@"提示"
                                          message:message ?: @""
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alertController
      addAction:([UIAlertAction
                    actionWithTitle:@"确认"
                              style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction* _Nonnull action) {
                              completionHandler();
                            }])];
  [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView*)webView
    runJavaScriptConfirmPanelWithMessage:(NSString*)message
                        initiatedByFrame:(WKFrameInfo*)frame
                       completionHandler:(void (^)(BOOL))completionHandler {
  UIAlertController* alertController =
      [UIAlertController alertControllerWithTitle:@"提示"
                                          message:message ?: @""
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alertController
      addAction:([UIAlertAction
                    actionWithTitle:@"取消"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction* _Nonnull action) {
                              completionHandler(NO);
                            }])];
  [alertController
      addAction:([UIAlertAction
                    actionWithTitle:@"确认"
                              style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction* _Nonnull action) {
                              completionHandler(YES);
                            }])];
  [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView*)webView
    runJavaScriptTextInputPanelWithPrompt:(NSString*)prompt
                              defaultText:(NSString*)defaultText
                         initiatedByFrame:(WKFrameInfo*)frame
                        completionHandler:
                            (void (^)(NSString* _Nullable))completionHandler {
  UIAlertController* alertController =
      [UIAlertController alertControllerWithTitle:prompt
                                          message:@""
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alertController
      addTextFieldWithConfigurationHandler:^(UITextField* _Nonnull textField) {
        textField.text = defaultText;
      }];
  [alertController
      addAction:([UIAlertAction
                    actionWithTitle:@"完成"
                              style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction* _Nonnull action) {
                              completionHandler(
                                  alertController.textFields[0].text ?: @"");
                            }])];

  [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - private -
- (void)loadWebViewWithUrlString:(NSString*)urlString {
  NSURL* URL = [NSURL URLWithString:urlString];
  if (URL == nil) {
    NSLog(@"url is nil -->%@", urlString);
  }

  [self loadURL:URL];
}

- (void)loadURL:(NSURL*)URL {
  NSURLRequest* urlRequest =
      [NSURLRequest requestWithURL:URL
                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                   timeoutInterval:kRequstUrlTimeoutInt];
  [self.webView loadRequest:urlRequest];
}

- (BOOL)externalAppRequiredToOpenURL:(NSURL*)URL {
  NSSet* validSchemes = [NSSet setWithArray:@[ @"http", @"https" ]];
  return ![validSchemes containsObject:URL.scheme];
}

- (void)showErrorPlaceHolderView {
  if (self.errorPlaceHolderView.superview) {
    [self.errorPlaceHolderView removeFromSuperview];
  }
  self.errorPlaceHolderView.frame = self.webView.frame;
  [self.view addSubview:self.errorPlaceHolderView];
}

- (void)getWebViewDescString {
  NSString* descJsString =
  @"var meta = document.getElementsByTagName('meta');"
  "var desc = '';"
  "for(i in meta){"
  "if(typeof meta[i].name != \"undefined\" && "
  "meta[i].name.toLowerCase() == \"description\") {"
  "desc = meta[i].content;"
  "}"
  "}";
  [self.webView
   evaluateJavaScript:descJsString
   completionHandler:^(id _Nullable innerText, NSError* _Nullable error) {
     if ([innerText isKindOfClass:[NSString class]]) {
       NSLog(@"desc :%@",[NSString stringWithFormat:@"%@", innerText]);
     }
   }];
}

- (void)getWebViewFirstImage {
  NSString* imageJsString =
  @"var meta = document.getElementsByTagName('meta');"
  "var img = '';"
  "for(i in meta){"
  "try {"
  "if(typeof meta[i].getAttribute(\"itemprop\") != \"undefined\" && "
  "meta[i].getAttribute(\"itemprop\") == \"image\") {"
  "img = meta[i].content;"
  "}"
  "}catch(e){}"
  "}";
  
  NSString* defaultImageJsString =
  @"document.getElementsByTagName('img')[0].src";
  
  [self checkWebImageWithJavaScriptLIst:@[ imageJsString, defaultImageJsString ]
                                jsIndex:0];
}

- (void)checkWebImageWithJavaScriptLIst:(NSArray*)javaScriptLIst
                                jsIndex:(NSInteger)jsIndex {
  if (javaScriptLIst.count > jsIndex) {
    NSString* jsString = javaScriptLIst[jsIndex];
    [self.webView
     evaluateJavaScript:jsString
     completionHandler:^(id _Nullable image, NSError* _Nullable error) {
       if ([image isKindOfClass:[NSString class]]) {
         NSURL* imageURL = [NSURL URLWithString:image];
       } else {
         [self checkWebImageWithJavaScriptLIst:javaScriptLIst
                                       jsIndex:jsIndex + 1];
       }
     }];
  }
}

@end
