//
//  SaveCustomViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/12/3.
//  Copyright © 2018 QH. All rights reserved.
//

#import "SaveCustomViewController.h"

#import "SaveCustomModel.h"

@interface SaveCustomViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *numField;

@property (nonatomic, strong) SaveCustomModel *model;

@end

@implementation SaveCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftButton)];
  self.view.backgroundColor = [UIColor whiteColor];
  
  for (int i = 0; i < 2; i++) {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100 + i * 80, 200, 50)];
    textField.layer.borderColor = [UIColor grayColor].CGColor;
    textField.layer.borderWidth = 0.5;
    textField.layer.masksToBounds = YES;
    textField.layer.cornerRadius = 10;
    textField.delegate = self;
    [self.view addSubview:textField];
    
    if (i == 0) {
      _nameField = textField;
      _nameField.text = self.model.name;
    } else if (i == 1) {
      _numField = textField;
      _numField.keyboardType = UIKeyboardTypeNumberPad;
      _numField.text = [NSString stringWithFormat:@"%d", self.model.num];
    }
  }
  

  
}

- (SaveCustomModel *)model
{
  if (!_model) {
    _model = [SaveCustomModel createCustomModel];
  }
  return _model;
}

- (void)leftButton
{
  _model.name = _nameField.text;
  _model.num = [_numField.text intValue];
  [_model saveCustomModel];
  [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
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
