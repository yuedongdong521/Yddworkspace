//
//  MyURLClickViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/29.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyURLClickViewController.h"
#import "UITextView+MyURLClick.h"
#import "MyURLClickView.h"

@interface MyURLClickViewController ()<UITextViewDelegate>


@end

@implementation MyURLClickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    MyURLClickView *textView = [[MyURLClickView alloc] initWithFrame:CGRectMake(20, 100, ScreenWidth - 40, 100) WithClickURL:^(NSURL *url) {
        NSLog(@"url = %@", url.absoluteString);
    }];
    textView.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:textView];
    
    textView.text = @"baidu.com ispeak.cn http://tianmao.com https://taobao.com 自带3dtouch功能 6666";
}

- (NSAttributedString *)creatAttributedText:(NSString *)str
{
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:str];
    [att addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17], NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, str.length)];
    
    NSError *error = nil;
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
    if (!error) {
        return att;
    }
    NSArray *arr = [detector matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];
    
    for (NSTextCheckingResult * result in arr) {
        if (result.resultType == NSTextCheckingTypeLink) {
            [att addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor], NSLinkAttributeName:result.URL.absoluteString} range:result.range];
            
        }
    }
    return att;
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
