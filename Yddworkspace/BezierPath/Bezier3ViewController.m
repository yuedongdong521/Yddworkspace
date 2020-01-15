//
//  Bezier3ViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/1/14.
//  Copyright © 2020 QH. All rights reserved.
//

#import "Bezier3ViewController.h"
#import "BezierView.h"

@interface Bezier3ViewController ()

@end

@implementation Bezier3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BezierView *bezierView = [[BezierView alloc]initWithFrame:CGRectMake(0, (ScreenHeight - ScreenWidth) * 0.5, ScreenWidth, 200)];
    [self.view addSubview:bezierView];
    bezierView.backgroundColor = [UIColor whiteColor];
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
