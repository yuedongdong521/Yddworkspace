//
//  MyTextViewViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/8/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyTextViewViewController.h"
#import "MyTestTextView.h"

@interface MyTextViewViewController ()

@end

@implementation MyTextViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor grayColor];
  UIFont *font = [UIFont systemFontOfSize:16];
  
  MyTestTextView *textView = [[MyTestTextView alloc]initWithFrame:CGRectMake(20, 100, ScreenWidth - 40, 80)];
  
  
  
  [self.view addSubview:textView];
  
  
  NSString *str = @"醉卧沙场君莫笑,古来征战几人回.🙂😢🍎http://baidu.com http://baidu.com http://baidu.com http://12306.cn weibo.com 17749757268 wei";
  str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
  str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName :font}];
  for (int i = 0; i < 1; i++) {
    NSTextAttachment *ment = [[NSTextAttachment alloc] init];
    ment.image = [UIImage imageNamed:@"0.jpg"];
    ment.bounds = CGRectMake(0, -font.lineHeight + font.pointSize, font.lineHeight, font.lineHeight);
    NSAttributedString *mentAtt = [NSAttributedString attributedStringWithAttachment:ment];
    [att appendAttributedString:mentAtt];
  }
  
  [textView setMyTextViewAttributedText:att];
  
  
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
