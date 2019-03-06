//
//  TestResponderViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/10.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TestResponderViewController.h"
#import "MyResponderBtn.h"
#import "ResponderView.h"

@interface TestResponderViewController ()

@property (nonatomic, strong) UIButton *btn3;

@end

@implementation TestResponderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor whiteColor];
  
  UIButton *btn1 = [self createBtn:@"btn1" color:[UIColor redColor] tag:100 frame:CGRectMake(20, 80, 300, 300)];
  [self.view addSubview:btn1];
  UIButton *btn2 = [self createBtn:@"btn2" color:[UIColor greenColor] tag:200 frame:CGRectMake(20, 20, 100, 100)];
  [btn1 addSubview:btn2];
  CGRect btn3Frame = CGRectInset(btn2.frame, 20, 20);
  UIButton *btn3 = [self createBtn:@"btn3" color:[UIColor blueColor] tag:300 frame:btn3Frame];
  [btn1 addSubview:btn3];
  _btn3 = btn3;
  
  ResponderView *responderView = [[ResponderView alloc] initWithFrame:CGRectMake(40, 400, 100, 100)];
  responderView.backgroundColor = [UIColor greenColor];
  [self.view addSubview:responderView];
  
  MyResponderBtn *responderBtn = [MyResponderBtn createBtn:@"responderBtn" color:[UIColor cyanColor] tag:1 frame:CGRectMake(40, 40, 10, 10) target:self action:@selector(buttonAction:)];
  [responderView addSubview:responderBtn];
  
}



- (void)buttonAction:(UIButton *)btn
{
  NSLog(@"responder btn tag = %ld", (long)btn.tag);
  if (btn.tag == 200) {
    [self checkCurrentViewController];
  }
}

- (void)checkCurrentViewController
{
  UIResponder *responder = _btn3.nextResponder;
  NSInteger responderCount = 1;
  while (responder) {
    if ([responder isKindOfClass:[UIViewController class]]) {
      NSLog(@"curViewController = %@, responderCount = %ld", responder, (long)responderCount);
      break;
    }
    responder = responder.nextResponder;
    responderCount++;
  }
}

- (UIButton *)createBtn:(NSString *)title color:(UIColor*)color tag:(NSInteger)tag frame:(CGRect)frame
{
  UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
  btn1.frame = frame;
  btn1.tag = tag;
  [btn1 setTitle:title forState:UIControlStateNormal];
  btn1.backgroundColor = color;
  [btn1 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

  return btn1;
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
