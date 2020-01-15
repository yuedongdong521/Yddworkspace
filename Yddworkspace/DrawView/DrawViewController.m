//
//  DrawViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/1/15.
//  Copyright © 2020 QH. All rights reserved.
//

#import "DrawViewController.h"


@interface DrawViewController ()


@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    DrawView *drawView = [[DrawView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, ScreenWidth, ScreenHeight - kNavBarHeight - IS_BOTTOM_HEIGHT)];
    drawView.type = self.type;
    [self.view addSubview:drawView];
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
