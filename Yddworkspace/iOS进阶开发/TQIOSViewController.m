//
//  TQIOSViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/29.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "TQIOSViewController.h"

@interface TQIOSViewController ()

@end

@implementation TQIOSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
//    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"iOS开发进阶_唐巧著_2015.01_244页" ofType:@"pdf"]];
//    [webView loadData:data MIMEType:@"PDF" textEncodingName:@"" baseURL:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"iOS开发进阶_唐巧著_2015.01_244页" ofType:@"pdf"]]];
    [webView loadRequest:request];
    webView.scalesPageToFit = YES;
    webView.paginationMode = UIWebPaginationModeTopToBottom;
    webView.scrollView.pagingEnabled = NO;

    
    [self.view addSubview:webView];
    
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
