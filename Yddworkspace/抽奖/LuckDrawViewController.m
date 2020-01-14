//
//  LuckDrawViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/12/17.
//  Copyright © 2019 QH. All rights reserved.
//

#import "LuckDrawViewController.h"
#import "KXLuckDrawView.h"

@interface LuckDrawViewController ()

@end

@implementation LuckDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    KXLuckDrawView *luckView = [[KXLuckDrawView alloc] init];
    [self.view addSubview:luckView];
    [luckView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-34);
        make.height.mas_equalTo(120);
    }];
    
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
