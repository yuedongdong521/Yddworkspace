//
//  CoreTextViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/1/6.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "CoreTextViewController.h"
#import "MyTextView.h"

@interface CoreTextViewController ()

@end

@implementation CoreTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    MyTextView *myTextView = [[MyTextView alloc] initWithFrame:CGRectMake(20, 80, 200, 30)];
    myTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:myTextView];
//    [myTextView setNeedsDisplay];
    
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
