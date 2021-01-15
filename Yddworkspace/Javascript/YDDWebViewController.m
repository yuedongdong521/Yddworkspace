//
//  YDDWebViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/21.
//  Copyright © 2019 QH. All rights reserved.
//

#import "YDDWebViewController.h"
#import "YDDWebView.h"
#import "NJKWebViewProgressView.h"

#define MySchemeURL @"ydd.app.com"
#define H5_URL @"testHtml"

@interface YDDWebViewController ()<YDDWebViewDelegate>

@property (nonatomic, strong) YDDWebView *webView;
@property (nonatomic, strong) NJKWebViewProgressView *webViewProgressView;

@property (nonatomic, assign) BOOL needGoBack;

@end

@implementation YDDWebViewController

- (void)backAction
{
    [_webView removeJavascrpitActionAll];
    if (_needGoBack) {
        if (![self.webView goBack]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
       [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightAction
{
    [_webView callJavaScriptAction:@"oc_javascriptAction()" completionHandler:^(id  _Nonnull result, NSError * _Nonnull error) {
        NSLog(@"%@ \n error:%@" , result, error);
    }];
    
    [_webView callJavaScriptAction:@"scanResult('ydd')" completionHandler:^(id  _Nonnull result, NSError * _Nonnull error) {
        NSLog(@"scanResult %@ \n error:%@" , result, error);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"h5Action" style:UIBarButtonItemStyleDone target:self action:@selector(rightAction)];
    
    [self.view addSubview:self.webView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(kNavBarHeight, 0, 0, 0));
    }];
    
    [self addProgressView];
}


- (void) addProgressView{
    
    ///progressView
//    CGRect navBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0,
                                 kStatusBarHeight,
                                 ScreenWidth,
                                 2);
    _webViewProgressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _webViewProgressView.progressBarView.backgroundColor = UIColorHexRGBA(0Xb954fe, 1);
    _webViewProgressView.fadeOutDelay = 0.5f;
    [_webViewProgressView setProgress:0 animated:YES];
    [self.view addSubview:_webViewProgressView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"testJavascript" ofType:@"html"]]];
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:H5_URL ofType:@"html"]];
//    [self.webView startLoadWithUrl:@"https://www.cnblogs.com/Biaoac/p/5317012.html"];
//    [self.webView startLoadRequest:request];
    [self.webView startLoadFileURL:fileURL accessURL:[NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath]];
}

- (void)webView:(YDDWebView *)webView loadProgress:(CGFloat)progress
{
    [_webViewProgressView setProgress:progress animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoad];
}

- (YDDWebView *)webView
{
    if (!_webView) {
        _webView = [[YDDWebView alloc] init];
        _webView.delegate = self;
        __weak typeof(self) weakself = self;
        [_webView addJavaScriptAction:@"jumpRechargeXieyi" actionBlock:^(id  _Nonnull body) {
            NSLog(@"javaScriptAction : jumpRechargeXieyi (%@)", body);
        }];
        [_webView addJavaScriptAction:@"jumpKefu" actionBlock:^(id  _Nonnull body) {
             NSLog(@"javaScriptAction : jumpKefu (%@)", body);
        }];
        [_webView addJavaScriptAction:@"ocQuiteAction" actionBlock:^(id  _Nonnull body) {
            NSLog(@"ocQuiteAction : (%@)", body);
            [weakself backAction];
        }];
        
    }
    return _webView;
}

- (void)webView:(YDDWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
    NSURL *requestUrl = request.URL;
    NSString *urlStr = [requestUrl.absoluteString stringByRemovingPercentEncoding];
    
    if ([urlStr isEqualToString:webView.currentURL] || [urlStr hasPrefix:H5_URL]) {
        self.needGoBack = NO;
    } else {
        self.needGoBack = YES;
    }
    
    
    NSString *scheme = [requestUrl scheme];
    static NSString *endPayRedirectURL = nil;
    
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"file"]) {
        
        if ([urlStr hasPrefix:@"https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb"] &&
            ![urlStr hasSuffix:[NSString stringWithFormat:@"redirect_url=%@",MySchemeURL]] &&
            [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            decisionHandler(WKNavigationActionPolicyCancel);
            NSString *redirectUrl = nil;
            if ([urlStr containsString:@"redirect_url="]) {
                NSRange redirectRange = [urlStr rangeOfString:@"redirect_url"];
                endPayRedirectURL =  [urlStr substringFromIndex:redirectRange.location+redirectRange.length+1];
                redirectUrl = [[urlStr substringToIndex:redirectRange.location] stringByAppendingString:[NSString stringWithFormat:@"redirect_url=%@",MySchemeURL]];
            }else {
                redirectUrl = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&redirect_url=%@",MySchemeURL]];
            }
            NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:redirectUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
            newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
            newRequest.URL = [NSURL URLWithString:redirectUrl];
            [webView startLoadRequest:newRequest];
            return;
        }
        
        if ([urlStr containsString:@"/pay/ali/"]) {
            static NSString *aliPayUrl = nil;
            if ([aliPayUrl isEqualToString:urlStr]) {
                decisionHandler(WKNavigationActionPolicyCancel);
                [webView startLoadWithUrl:webView.currentURL];
                aliPayUrl = nil;
                return;
            }
            aliPayUrl = urlStr;
        }
        
        if ([urlStr containsString:@"/pay/unionPay/"]) {
            static NSString *unionPayUrl = nil;
            if ([unionPayUrl isEqualToString:urlStr]) {
                decisionHandler(WKNavigationActionPolicyCancel);
                
                [webView startLoadWithUrl:webView.currentURL];
                
                unionPayUrl = nil;
                return;
            }
            unionPayUrl = urlStr;
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([[UIApplication sharedApplication] canOpenURL:requestUrl]) {
            
            // 支付宝
            if ([scheme isEqualToString:@"alipay"]) {
                NSURL *alipayUrl = [self getAlipaySchemeUrl:urlStr];
                if (alipayUrl && [[UIApplication sharedApplication] canOpenURL:alipayUrl]) {
                    [[UIApplication sharedApplication] openURL:alipayUrl];
                }
                return;
            }
            if ([scheme isEqualToString:@"weixin"]) {
                if (endPayRedirectURL) {
                    [webView startLoadWithUrl:webView.currentURL];
                    endPayRedirectURL = nil;
                }
            }
            [[UIApplication sharedApplication] openURL:requestUrl];
            
        } else {
            if ([scheme isEqualToString:@"weixin"]) {
                NSLog(@"请安装微信最新版");
            }
        }
    }
}
- (NSURL*)getAlipaySchemeUrl:(NSString *)urlStr
{
    NSRange range = [urlStr rangeOfString:@"{"];
    if (range.location != NSNotFound) {
        NSString *preStr = [urlStr substringToIndex:range.location];
        NSString *jsonStr = [urlStr substringFromIndex:range.location];
        NSDictionary *dic = [self jsonStringToDic:jsonStr];
        if (dic && dic.count > 0) {
            NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            mutDic[@"fromAppUrlScheme"] = @"kuxiulive";
            jsonStr = [self dicToJsonString:mutDic];
            if (jsonStr && jsonStr.length > 0) {
                NSString *jumpUrl = [preStr stringByAppendingString:jsonStr];
                jumpUrl = [jumpUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                return [NSURL URLWithString:jumpUrl];
            }
        }
    }
    return nil;
}

- (NSDictionary *)jsonStringToDic:(NSString *)str
{
    if (!str || str.length == 0) {
        return nil;
    }
    NSData *data = [NSData dataWithBytes:str.UTF8String length:str.length];
    if (!data) {
        return nil;
    }
    id jsonId = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if ([jsonId isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)jsonId;
    }
    return nil;
}

- (NSString *)dicToJsonString:(NSDictionary *)dic
{
    if (dic.count == 0) {
        return @"";
    }
    NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];
    NSInteger count = dic.allKeys.count;
    [dic.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [jsonStr appendFormat:@"%@:%@", obj,dic[obj]];
        if (idx < count - 1) {
            [jsonStr appendString:@","];
        }
    }];
    [jsonStr appendString:@"}"];
    return jsonStr;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
