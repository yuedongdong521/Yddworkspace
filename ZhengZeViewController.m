//
//  ZhengZeViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/3/22.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "ZhengZeViewController.h"
#import "Masonry.h"

@interface ZhengZeViewController ()

@end

@implementation ZhengZeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITextField *textFiled = [[UITextField alloc] init];
    [self.view addSubview:textFiled];
    textFiled.layer.borderWidth = 1.0;
    textFiled.layer.borderColor = [UIColor grayColor].CGColor;
    textFiled.layer.masksToBounds = YES;
    textFiled.layer.cornerRadius = 5.0;
    [textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20);
        make.right.offset(-20);
        make.top.offset(100);
        make.height.equalTo(@(50));
    }];
    
}

- (BOOL)judgeEmail
{
    NSString *email = @"nijino_saki@163.com";
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:email];
    return isValid;
}

- (void)searchStr
{
    NSString *searchText = @"// Do any additional setup after loading the view, typically from a nib.";
    
    NSRange range = [searchText rangeOfString:@"(?:[^,])*\\." options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        NSLog(@"%@", [searchText substringWithRange:range]);
    }
}

- (void)regularExpression
{
    NSString *searchText = @"// Do any additional setup after loading the view, typically from a nib.";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?:[^,])*\\." options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
    if (result) {
        NSLog(@"%@\n", [searchText substringWithRange:result.range]);
    }
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
