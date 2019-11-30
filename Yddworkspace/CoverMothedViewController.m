//
//  CoverMothedViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/11/30.
//  Copyright © 2019 QH. All rights reserved.
//

#import "CoverMothedViewController.h"
#import <objc/runtime.h>

@interface CustomBtn : UIButton

@end

@implementation CustomBtn


- (void)newAction:(UIButton *)btn
{
     NSLog(@"newAction: %@", btn.currentTitle);
}


@end

@interface CoverMothedViewController ()

@property (nonatomic, strong) UIButton *firstBtn;

@property (nonatomic, strong) UIButton *secondBtn;

@end

@implementation CoverMothedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *btnArr = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:[NSString stringWithFormat:@"btn:%d", i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor greenColor];
        [self.view addSubview:btn];
        [btnArr addObject:btn];
        btn.tag = i;
        if (i == 0) {
            self.firstBtn = btn;
        } else if (i == 1) {
            self.secondBtn = btn;
        }
    }
    
    [btnArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:30 leadSpacing:30 tailSpacing:30];

    [btnArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
    
    
    
}

- (void)btnAction:(UIButton *)btn
{
    NSLog(@"%@", btn.currentTitle);
    if (btn.tag == 2) {
        Method m1 = class_getInstanceMethod([self class], @selector(btnAction:));
        Method m2 = class_getInstanceMethod([CustomBtn class], @selector(newAction:));
        method_exchangeImplementations(m1, m2);
    }
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
