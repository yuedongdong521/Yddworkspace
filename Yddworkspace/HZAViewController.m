//
//  HZAViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/3/4.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "HZAViewController.h"
#import "LinkMicReminderView.h"
#import <AVFoundation/AVFoundation.h>

@interface HZAViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) LinkMicReminderView *remindView;
@end

@implementation HZAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor redColor];
    
//    _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, ScreenWidth - 40, 100)];
//    _label.backgroundColor = [UIColor whiteColor];
//    _label.textColor = [UIColor blackColor];
//    _label.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:_label];
//    
//    _textField = [[UITextField alloc] initWithFrame:CGRectMake(50, 200, ScreenWidth - 100, 50)];
//    _textField.layer.cornerRadius = 5;
//    _textField.layer.borderWidth = 0.5;
//    _textField.keyboardType = UIKeyboardTypeDefault;
//    _textField.returnKeyType = UIReturnKeySend;
//    _textField.delegate = self;
//    [self.view addSubview:_textField];
    
    _remindView = [[LinkMicReminderView alloc] initWithTitle:@"提示" ContentStr:@"xxx向你发起连麦请求"];
//    [self.view addSubview:remindView];
    int sum = 0;
    for (int i = 1; i < 21; i++) {
        sum = i + sum;
    }
    NSLog(@"sum = %d", sum);
    
   
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_remindView.hidden) {
        [_remindView hiddenRemindView:NO];
    }
    NSArray *array = [NSArray arrayWithObjects:@"0X22aa55",@"ffaacc",@"225599",@"0XFF5588", nil];
    static int index = 0;
    self.view.backgroundColor = [[MyTools shareMyTools] getColorValueForRGBStr:array[index]];
    index++;
    CMTime time;
    if (index == 1) {
        time = kCMTimeZero;
    }
    
    float timeValue = 1;
    if (CMTimeGetSeconds(time)) {
        timeValue = CMTimeGetSeconds(time);
    }
    NSLog(@"时间CMTime= %f",timeValue);
    
    if (index == array.count) {
        index = 0;
    }
    
   
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _label.text = [self getNumberStr:textField.text];
    return YES;
}

- (NSString *)getNumberStr:(NSString *)str
{
    NSString *resultStr = @"";
  
    NSDictionary *dic = @{@"零":[NSNumber numberWithInteger:0],
                          @"一":[NSNumber numberWithInteger:1],
                          @"二":[NSNumber numberWithInteger:2],
                          @"三":[NSNumber numberWithInteger:3],
                          @"四":[NSNumber numberWithInteger:4],
                          @"五":[NSNumber numberWithInteger:5],
                          @"六":[NSNumber numberWithInteger:6],
                          @"七":[NSNumber numberWithInteger:7],
                          @"八":[NSNumber numberWithInteger:8],
                          @"九":[NSNumber numberWithInteger:9],
                          @"十":[NSNumber numberWithInteger:10],
                          @"百":[NSNumber numberWithInteger:100],
                          @"千":[NSNumber numberWithInteger:1000],
                          @"万":[NSNumber numberWithInteger:10000],
                          @"亿":[NSNumber numberWithInteger:100000000]};
    
    NSString *numStr = @"";
    for (int i = 0; i < str.length; i++) {
        NSString *subStr = [str substringWithRange:NSMakeRange(i, 1)];
        if ([dic objectForKey:subStr] && ![[dic objectForKey:subStr] isKindOfClass:[NSNull class]]) {
            numStr = [numStr stringByAppendingString:subStr];
        }
    }
    
    NSInteger a = 0; //数值
    NSInteger b = 1; //单位
    NSInteger c = 0; //大于一亿以上的树
    NSInteger s = 0; //结果
    for (NSInteger index = 0; index < numStr.length; index++) {
        NSString *tmpStr = [numStr substringWithRange:NSMakeRange(index, 1)];
        NSInteger tmpNum = 0;
        if ([dic objectForKey:tmpStr] && ![[dic objectForKey:tmpStr] isKindOfClass:[NSNull class]]) {
            tmpNum = [[dic objectForKey:tmpStr] integerValue];
            
            if (tmpNum < 10) {
                a = tmpNum;
                if (index == numStr.length - 1) {
                    s += a;
                    a = 0;
                }
            } else {
                if (index == 0) {
                    a = tmpNum;
                    s = s + a * b;
                    a = 0;
                } else {
                    if (tmpNum == 100000000) {
                        b = tmpNum;
                        c = (s + a) * b;
                        a = 0;
                        s = 0;
                        b = 1;
                    } else {
                        if (b > tmpNum) {
                            b = tmpNum;
                            s = s + a * b;
                            a = 0;
                        } else {
                            b = tmpNum;
                            s = (s + a) * b;
                            a = 0;
                        }
                    }
                }
            }
        }
    }
    s = s + c;
    resultStr = [NSString stringWithFormat:@"%ld", (long)s];
    return resultStr;
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
