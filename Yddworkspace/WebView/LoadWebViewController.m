//
//  LoadWebViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/7/25.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "LoadWebViewController.h"
#import "UIWebView+JavaScriptAlert.h"

@interface LoadWebViewController ()<UIWebViewDelegate>

@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) NSString *currentURL;


@end

@implementation LoadWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.navigationController.navigationBar.translucent = YES;
  [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
  [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
  
  [self.view addSubview:self.webView];
  
  
}

- (UIWebView *)webView
{
  if (!_webView) {
    _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.backgroundColor = [UIColor grayColor];
    _webView.scalesPageToFit = YES; //自动对页面进行缩放以适应屏幕
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
    [_webView loadRequest:request];
  }
  return _webView;
}



//当网页视图已经开始加载一个请求后，得到通知。
-(void)webViewDidStartLoad:(UIWebView*)webView
{
  
}

//当网页视图结束加载一个请求之后，得到通知。
-(void)webViewDidFinishLoad:(UIWebView*)webView
{
  
}

//当在请求加载中发生错误时，得到通知。会提供一个NSSError对象，以标识所发生错误类型。
-(void)webView:(UIWebView*)webView DidFailLoadWithError:(NSError*)error
{
  
}

static NSString *const VideoHandlerScheme = @"videohandler";
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  if ([request.mainDocumentURL.relativePath isEqualToString:@"/alert"]) {
//    [webView webView:webView runJavaScriptAlertPanelWithMessage:@"123" initiatedByFrame:nil];
    
    return NO;
  }
  if ([request.URL.scheme isEqualToString:VideoHandlerScheme]) {
    NSLog(@"%@", request.URL);//在这里可以获得事件
    _currentURL = request.URL.absoluteString;
    [self saveVideoURL];
  }
  return YES;
}

- (void)saveVideoURL
{
  UIPasteboard *past = [UIPasteboard generalPasteboard];
  past.string = _urlStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
