//
//  CoreTextTowViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/30.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "CoreTextTowViewController.h"
#import "CoreTextTowView.h"
#import "MyCoreTextScrollView.h"

@interface CoreTextTowViewController ()

@end

@implementation CoreTextTowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    CoreTextTowView *coretextView = [[CoreTextTowView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    MyCoreTextScrollView *coretextView = [[MyCoreTextScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    NSString *str = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"coretextTest" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    [coretextView creatCTFrameRefWithContentStr:str];
    [self.view addSubview:coretextView];
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
