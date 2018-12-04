//
//  AudioUnitViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2018/3/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "AudioUnitViewController.h"
#import "ISAudionUnitManageer.h"
#import "AudioUnitRecordController.h"

@interface AudioUnitViewController ()

@property (nonatomic, strong) ISAudionUnitManageer *manager;
@property (nonatomic, strong) AudioUnitRecordController *reconderController;

@end

@implementation AudioUnitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 100, 100, 50);
    [button setTitle:@"开始录制" forState: UIControlStateNormal];
    [button setTitle:@"结束录制" forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
//    _manager = [[ISAudionUnitManageer alloc] init];
  _reconderController = [[AudioUnitRecordController alloc] init];
}

- (void)buttonAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
//        [_manager startAudioUnit];
      [_reconderController recordAction];
    } else {
//        [_manager stopAudioUnit];
      [_reconderController stopRecord];
    }
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
