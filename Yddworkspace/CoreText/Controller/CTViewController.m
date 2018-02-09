//
//  CTViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/27.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "CTViewController.h"
#import "MyAttributedString.h"
#import "CTScrollView.h"

@interface CTViewController ()

@end

@implementation CTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"zombies" ofType:@"txt"];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    CTScrollView * ctView = [[CTScrollView alloc] initWithFrame:CGRectMake(0, ViewY(self.navigationController.navigationBar) + ViewH(self.navigationController.navigationBar), ScreenWidth, ScreenHeight - ViewY(self.navigationController.navigationBar) - ViewH(self.navigationController.navigationBar))];
    
    MyAttributedString *myAttStr = [[MyAttributedString alloc] initWithSize:ctView.frame.size];
    NSAttributedString *attStr = [myAttStr attrStringFromMark:str];
    

    [ctView buildFramesAttrString:attStr AndImages:myAttStr.images];
    [self.view addSubview:ctView];
    
    NSLog(@"ctView contentSize = %@, \n contentOffset  = %@",NSStringFromCGSize(ctView.contentSize),NSStringFromCGPoint(ctView.contentOffset));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"MyAttributedString dealloc");
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
