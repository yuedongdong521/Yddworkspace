//
//  TestCurentViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/12/16.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TestCurentViewController.h"

@interface TestCurentViewController ()

@end

@implementation TestCurentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.]
    
    NSArray *array = @[@"push", @"present"];
    NSMutableArray *mutArr = [NSMutableArray array];
    for (NSInteger i = 0; i < array.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:array[i] forState:UIControlStateNormal];
        if (i == 0) {
            [btn addTarget:self action:@selector(pushNewViewController) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [btn addTarget:self action:@selector(presentNewVC) forControlEvents:UIControlEventTouchUpInside];
        }
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        [mutArr addObject:btn];
    }
    
    [mutArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:30 leadSpacing:50 tailSpacing:50];
    [mutArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    
    
}

- (void)pushNewViewController
{
    TestCurentViewController *vc = [[TestCurentViewController alloc] init];
    vc.index = self.index + 1;
    UIViewController *cur = [self getCurVC];
    if (cur.navigationController) {
        [cur.navigationController pushViewController:vc animated:YES];
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cur];
        [nav pushViewController:vc animated:YES];
    }
    
}

- (void)presentNewVC
{
    TestCurentViewController *vc = [[TestCurentViewController alloc] init];
    vc.index = self.index + 1;
    [[self getCurVC] presentViewController:vc animated:YES completion:nil];
}

- (UIViewController *)getCurVC
{
    UIViewController *vc = [UIApplication curentViewController];
    NSLog(@"curvc : %@", NSStringFromClass(vc.class));
    if ([vc isKindOfClass:[TestCurentViewController class]]) {
        NSLog(@"index = %ld", (long)((TestCurentViewController *)vc).index);
    }
    return vc;
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
