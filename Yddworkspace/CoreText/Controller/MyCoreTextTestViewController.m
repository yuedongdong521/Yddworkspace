//
//  MyCoreTextTestViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/9/5.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "MyCoreTextTestViewController.h"
#import "CoreTextModel.h"
#import "CoreTextTestView.h"

@interface MyCoreTextTestViewController ()

@end

@implementation MyCoreTextTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor whiteColor];
  NSString *contentStr = @"9月5日消息，据央广“下文”客户端了解，多部门今< image src=\"0.jpg\" >起到本< image src=\"0.jpg\" >月20日对全国网约车、顺风车平台公司开展进驻式全面检查。今天上午，由交< image src=\"0.jpg\" >通部、中央网信办、公安部等十部门和北京天津两地组成的< image src=\"0.jpg\" >联合调查组已经入驻滴滴，正式启动对网约车、顺风车平台公司的进驻式全面检查。央广“下文”客户端了解到，除滴滴外，检查组还将在北< image src=\"0.jpg\" >京对网约车平台首汽约车、神州专车、易道、美团及嘀嗒、高德等< image src=\"0.jpg\" >顺风车平台进行进驻检查，并赴杭州检查曹操专车，其他地方网约车、顺风车由公司注册地所在省级交通主管部门指导相关城市交通主管部门会同城市其他管理部门进行检查。";
  
  CoreTextModel *model = [[CoreTextModel alloc] initWithContentStr:contentStr contentMaxWidth:ScreenWidth - 40];

  CoreTextTestView *testView = [[CoreTextTestView alloc] initWithFrame:CGRectMake(20, 80, ScreenWidth - 40, model.contentHeight)];
  testView.backgroundColor = [UIColor grayColor];
  [testView setFrameRef:[model getFrameRef]];
  testView.imageArr = [model.imageArr copy];
  [self.view addSubview:testView];
  [testView setNeedsLayout];
  [testView layoutIfNeeded];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
  NSLog(@"dealloc %@", NSStringFromClass(self.class));
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
