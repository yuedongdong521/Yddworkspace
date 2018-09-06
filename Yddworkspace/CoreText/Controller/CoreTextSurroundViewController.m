//
//  CoreTextSurroundViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/9/6.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "CoreTextSurroundViewController.h"
#import "CoreTextV.h"
@interface CoreTextSurroundViewController ()

@end

@implementation CoreTextSurroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  CoreTextV *view = [[CoreTextV alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:view];
  
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
