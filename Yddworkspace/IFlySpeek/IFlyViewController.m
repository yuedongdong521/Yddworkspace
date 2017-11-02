//
//  IFlyViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/2/10.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "IFlyViewController.h"
#import "ISRDataHelper.h"
#import "IFlySpeek.h"

@interface IFlyViewController ()<IFlySpeekDelegate>


@property (nonatomic, strong) NSString *resultStr;

@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) IFlySpeek *iFlySpeek;

@end

@implementation IFlyViewController

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s",__func__);
    [_iFlySpeek releseIFly];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self initIFly];
    
    _resultTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 64, ScreenWidth, ScreenHeight - 200)];
    [self.view addSubview:_resultTextView];
    
    _iFlySpeek = [[IFlySpeek alloc] initWithView:self.view];
    _iFlySpeek.delegate = self;

    UIButton *iFlyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    iFlyButton.frame = CGRectMake((ScreenWidth - 100) / 2.0, ScreenHeight - 100, 100, 50);
    [iFlyButton setBackgroundImage:[UIImage imageNamed:@"speekTouchDown"] forState:UIControlStateNormal];
    [iFlyButton addTarget:self action:@selector(startSpeek:) forControlEvents:UIControlEventTouchDown];
    [iFlyButton addTarget:self action:@selector(endSpeek:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:iFlyButton];
    
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


- (void)returnResultStr:(NSString *)resultStr
{
    NSString *numStr = [self getNumberStr:resultStr];
    
    _resultTextView.text = [NSString stringWithFormat:@"%@(%@)", resultStr, numStr];
}

- (void)startSpeek:(UIButton *)btn
{
    NSLog(@"start");
    
    [_iFlySpeek understand];
    return;
}

- (void)endSpeek:(UIButton *)btn
{
    [_iFlySpeek end];
    return;
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
