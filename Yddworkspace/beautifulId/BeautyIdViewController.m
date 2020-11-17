//
//  BeautyIdViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/9/7.
//  Copyright © 2020 QH. All rights reserved.
//

#import "BeautyIdViewController.h"
#import "KXBeautifulIdLabel.h"


@interface BeautyIdViewController ()

@property (nonatomic, strong) KXBeautifulIdLabel *beautIdLabel;


@end

@implementation BeautyIdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.beautIdLabel = [[KXBeautifulIdLabel alloc] init];
    
    [self.view addSubview:self.beautIdLabel];
    [self.beautIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.height.width.mas_equalTo(30);
    }];
    
    
    [self.beautIdLabel updateImageStr:@"beaut_img" beautId:8888888];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSArray *arr = @[@(123), @(666666), @(88888888), @(10086)];
    
    NSInteger beautId = [arr[arc4random() % arr.count] integerValue];
    
    [self.beautIdLabel updateImageStr:@"beaut_img" beautId:beautId];
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
