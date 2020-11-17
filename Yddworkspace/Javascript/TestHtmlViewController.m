//
//  TestHtmlViewController.m
//  yddZS
//
//  Created by ydd on 2018/11/16.
//  Copyright © 2018 ydd. All rights reserved.
//

#import "TestHtmlViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface TestHtmlViewController ()<UIWebViewDelegate>
@property(nonatomic, strong) UIWebView *webView;

@end

@implementation TestHtmlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [self.view addSubview:self.webView];
  NSString *path = [[NSBundle mainBundle] pathForResource:@"testHtml" ofType:@"html"];
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
  [self.webView loadRequest:request];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(kNavBarHeight, 0, 0, 0));
    }];

}

- (UIWebView *)webView
{
  if (!_webView) {
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
  }
  return _webView;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
  
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  // 获取当前网页的标题
  NSString *titleStr = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  NSLog(@"%@",titleStr);
  
  // 还可以直接调用js定义的方法
  // 比如getShareUrl()为js端定义好的方法，返回值为分享的url
  // 我们就可以通过调用这个方法在returnStr中拿到js返回的分享地址
  NSString *returnStr = [webView stringByEvaluatingJavaScriptFromString:@"oc_javascriptAction()"];
  NSLog(@"%@",returnStr);
  
  // 还可以为js端提供完整的原生方法供其调用（记得导入#import <JavaScriptCore/JavaScriptCore.h>）
  JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
  // 可以定义供js调用的方法, testMethod为js调用的方法名
  __weak typeof(self) weakself = self;
  context[@"quiteAction"] = ^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"quiteAction");
      [weakself quiteAction:nil];
    });
  };
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  
}

// 当点击页面进行加载数据的时候调用
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  NSURL *curUrl = request.URL;
  NSLog(@"shouldStartLoadWithRequest : %@", curUrl);
  return YES;
}

- (void)quiteAction:(UIButton *)btn
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
  NSLog(@"%@ dealloc", NSStringFromClass(self.class));
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
