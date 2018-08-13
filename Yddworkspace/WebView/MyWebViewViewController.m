//
//  MyWebViewViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/7/25.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyWebViewViewController.h"
#import "Masonry.h"
#import "LoadWebViewController.h"

@interface MyWebViewViewController ()<UITextFieldDelegate>

@property(nonatomic, strong) UITextField *textField;

@end

@implementation MyWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.view.backgroundColor = [UIColor whiteColor];
  [self textField];
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  [button setTitle:@"finish" forState:UIControlStateNormal];
  [button addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  [button mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(100, 50));
    make.centerX.mas_equalTo(self.view.mas_centerX);
    make.bottom.mas_equalTo(self.textField.mas_top).offset(-20);
  }];
  
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  if (_textField.isFirstResponder) {
    [_textField resignFirstResponder];
  }
}

- (void)finishAction
{
  LoadWebViewController *vc = [[LoadWebViewController alloc] init];
  vc.urlStr = self.textField.text;
  [self.navigationController pushViewController:vc animated:YES];
}

- (UITextField *)textField
{
  if (!_textField) {
    _textField = [[UITextField alloc] init];
    _textField.layer.cornerRadius = 5;
    _textField.layer.masksToBounds = YES;
    _textField.layer.borderColor = [UIColor grayColor].CGColor;
    _textField.layer.borderWidth = 1.0;
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:_textField];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.mas_equalTo(10);
      make.centerY.mas_equalTo(self.view.mas_centerY);
      make.right.mas_equalTo(-10);
      make.height.mas_equalTo(50);
    }];
  }
  return _textField;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField.text.length > 0) {
    [self finishAction];
  }
  return YES;
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
