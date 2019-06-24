//
//  TestXibViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/12.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TestXibViewController.h"
#import "CustomXibView.h"

@interface TestXibViewController ()

@property (weak, nonatomic) IBOutlet UIButton *text;
@end

@implementation TestXibViewController
- (IBAction)ceshi:(id)sender {
    NSString *curTitle = _text.currentTitle;
    [_text setTitle:[NSString stringWithFormat:@"%@ 123 ", curTitle] forState:UIControlStateNormal];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CustomXibView *customView = [[CustomXibView alloc] init];
    customView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:customView];
    [customView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.height.mas_equalTo(100);
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
