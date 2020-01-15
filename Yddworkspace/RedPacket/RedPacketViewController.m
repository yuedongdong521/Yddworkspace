//
//  RedPacketViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/1/13.
//  Copyright © 2020 QH. All rights reserved.
//

#import "RedPacketViewController.h"
#import "RedPacketView.h"
@interface RedPacketViewController ()

@end

@implementation RedPacketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"红包雨";
    RedPacketView *redView = [[RedPacketView alloc] init];
    [self.view addSubview:redView];
    redView.frame = self.view.bounds;
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
