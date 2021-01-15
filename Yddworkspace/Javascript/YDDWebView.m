//
//  YDDWebView.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/21.
//  Copyright © 2019 QH. All rights reserved.
//

#import "YDDWebView.h"

@interface YDDUserContentController : WKUserContentController

@property (nonatomic, weak, readwrite) id<WKScriptMessageHandler> handler;

@end

@implementation YDDUserContentController

+ (instancetype)userContentControllerWithHandler:(id<WKScriptMessageHandler>)handler
{
    YDDUserContentController *userContentController = [[YDDUserContentController alloc] init];
    NSMutableString *javascript = [NSMutableString string];
    [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
    [javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
    WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [userContentController addUserScript:noneSelectScript];
    userContentController.handler = handler;
    return userContentController;
}

- (void)addJavaScriptAction:(NSString *)action
{
    [self addScriptMessageHandler:self.handler name:action];
}

- (void)removeJavaScriptAction:(NSString *)action
{
    [self removeScriptMessageHandlerForName:action];
}

- (void)dealloc
{
    NSLog(@"deeloc - %@", NSStringFromClass(self.class));
}

@end

@interface YDDWebView ()<WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, weak) YDDUserContentController *userController;
@property (nonatomic, strong) NSDate *startLoadDate;

@property (nonatomic, copy) NSString *lastUrl;
@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) NSMutableDictionary <NSString*, JavasprictBlock>*jsActionMutDic;

@end

@implementation YDDWebView

/*
// Only override drawRect: if you perform YDD drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)callJavaScriptAction:(NSString *)action completionHandler:(void(^)(id result, NSError *error))completionHandler
{
    [self.webView evaluateJavaScript:action completionHandler:completionHandler];
}

- (void)addJavaScriptAction:(NSString *)actionName actionBlock:(JavasprictBlock)actionBlock
{
    if (![self.jsActionMutDic.allKeys containsObject:actionName]) {
        [self.userController addJavaScriptAction:actionName];
    }
    [self.jsActionMutDic setObject:actionBlock forKey:actionName];
}

- (void)removeJavaScriptAction:(NSString *)actionName
{
    [self.jsActionMutDic removeObjectForKey:actionName];
    [self.userController removeJavaScriptAction:actionName];
}

- (void)removeJavascrpitActionAll
{
    
    [self.jsActionMutDic.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.userController removeJavaScriptAction:obj];
    }];
    [self.jsActionMutDic removeAllObjects];
}

- (WKNavigation *)reload
{
   return [self.webView reload];
}

- (WKNavigation *)goBack
{
    if ([self.webView canGoBack]) {
       return [self.webView goBack];
    }
    return nil;
}

- (BOOL)canGoBack
{
    return [self.webView canGoBack];
}

- (void)startLoadWithUrl:(NSString *)url {
    _urlString = url;
    [self startLoadRequest:[self getCurrentURLReuqest]];
}


- (void)startLoadRequest:(NSURLRequest *)request
{
    [self checkClearWebViewWithURL:request.URL.absoluteString];
    [self.webView loadRequest:request];
}

- (void)startLoadFileURL:(NSURL *)fileURL accessURL:(NSURL *)accessURL
{
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:accessURL];
}

- (void)stopLoad {
    NSLog(@"网页===结束加载%@",self.urlString);
    [self.webView stopLoading];
    // 将webView的显示内容置为空白
    [self callJavaScriptAction:@"document.body.innerHTML='';" completionHandler:^(id result, NSError *error) {
        NSLog(@"清除web内容 %@", error);
    }];
    [self destoryWebView];
    
}

- (void)destoryWebView
{
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self removeJavascrpitActionAll];
}

- (NSString *)currentURL
{
    return _urlString;
}

- (void)checkClearWebViewWithURL:(NSString *)url
{
    if (![self.lastUrl isEqualToString:url]) {
        //清空内容
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        //清除缓存
        [self clearCache];
    }
     self.lastUrl = url;
}

- (void)clearCache
{
    NSArray *types =@[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeDiskCache]; // 9.0之后才有的
    NSSet *websiteDataTypes = [NSSet setWithArray:types];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
    }];
    
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}


- (NSURLRequest *)getCurrentURLReuqest
{
    return [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.urlString]
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:10.0f];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    [self addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
   
}

- (NSMutableDictionary<NSString *,JavasprictBlock> *)jsActionMutDic
{
    if (!_jsActionMutDic) {
        _jsActionMutDic = [NSMutableDictionary dictionary];
    }
    return _jsActionMutDic;
}

- (WKWebView *)webView
{
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        // js交互控制器
        YDDUserContentController *userController = [YDDUserContentController userContentControllerWithHandler:self];
        configuration.userContentController = userController;
        _userController = userController;
        // js交互偏好设置
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuration.preferences = preferences;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.opaque = NO; // 不透明度
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.multipleTouchEnabled = YES;
        _webView.autoresizesSubviews = YES;
        _webView.scrollView.alwaysBounceVertical = YES;
        _webView.scrollView.bounces = NO;
        _webView.allowsBackForwardNavigationGestures = NO;
        
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.webView addObserver:self forKeyPath:@"estimatedProgress"
                          options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return _webView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat progress = [change[NSKeyValueChangeNewKey] floatValue];
        if ([_delegate respondsToSelector:@selector(webView:loadProgress:)]) {
            [_delegate webView:self loadProgress:progress];
        }
 
    }
}

#pragma mark - WKUserContentController
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (userContentController == self.userController) {
        JavasprictBlock jsBlock = self.jsActionMutDic[message.name];
        if (jsBlock) {
            jsBlock(message.body);
        }
    }
}

#pragma mark - WKNavigationDelegate
/* 页面开始加载 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    _startLoadDate = [NSDate date];

    NSLog(@"WKNavigationDelegate - %s", __func__);
    if ([_delegate respondsToSelector:@selector(webView:startLoadNavigation:)]) {
        [_delegate webView:self startLoadNavigation:navigation];
    }
}

/* 页面加载完成 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSTimeInterval requestTime = [[NSDate date] timeIntervalSinceDate:_startLoadDate];
    NSLog(@"网页===加载%@总共耗时%f",navigation,requestTime);
  
    NSLog(@"WKNavigationDelegate - %s", __func__);
    if ([_delegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [_delegate webView:self didFinishNavigation:navigation];
    }
}

/* 主页面加载新的url失败 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{

    NSLog(@"WKNavigationDelegate - %s", __func__);
    if ([_delegate respondsToSelector:@selector(webView:didFailNewNavigation:error:)]) {
        [_delegate webView:self didFailNewNavigation:navigation error:error];
    }
}
// 主界面加载失败
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{

    NSLog(@"WKNavigationDelegate - %s", __func__);
    if ([_delegate respondsToSelector:@selector(webView:didFailMainNavigation:error:)]) {
        [_delegate webView:self didFailMainNavigation:navigation error:error];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{

    if ([navigationAction.request.URL.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    if ([_delegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_delegate webView:self decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        return;
    }
    
    NSString *urlStr = [[[navigationAction.request URL] absoluteString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if (!urlStr || urlStr.length == 0){///<可以做非本host下url的限制
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    NSLog(@"urlString:%@",urlStr);
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        if (response.statusCode == 200) {
            if (decisionHandler) {
                decisionHandler(WKNavigationResponsePolicyAllow);
            }
        } else {
            if (decisionHandler) {
                decisionHandler(WKNavigationResponsePolicyCancel);
            }
            NSString *msg = [NSString stringWithFormat:@"url(%@), statusCode(%ld)", response.URL.absoluteString, (long)response.statusCode];
            NSLog(@"yddWebView request fail : %@", msg);
        }
    } else {
        if (decisionHandler) {
            decisionHandler(WKNavigationResponsePolicyAllow);
        }
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"网页===WKWebView总体内存占用过大");
    if (self.superview) {
        [self.webView reload];
    }
}

#pragma mark - WKUIDelegate

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSLog(@"WKUIDelegate - %s", __func__);
    return self.webView;
}


- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0));
{
    NSLog(@"WKUIDelegate - %s", __func__);
}


#pragma mark  js调用alert触发该方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"WKUIDelegate - %s", __func__);
    completionHandler();
}

#pragma mark js调用confirm触发
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    NSLog(@"WKUIDelegate - %s", __func__);
}

#pragma mark js调用prompt触发
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    NSLog(@"WKUIDelegate - %s", __func__);
}


- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0))
{
    NSLog(@"WKUIDelegate - %s", __func__);
    return YES;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_AVAILABLE(ios(10.0))
{
    NSLog(@"WKUIDelegate - %s", __func__);
    return nil;
}


- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_AVAILABLE(ios(10.0))
{
    
    NSLog(@"WKUIDelegate - %s", __func__);
}


- (void)dealloc
{
//    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    NSLog(@"deeloc - %@", NSStringFromClass(self.class));
}


@end
