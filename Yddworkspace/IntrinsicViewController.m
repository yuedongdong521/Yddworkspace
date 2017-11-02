//
//  IntrinsicViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/3/13.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "IntrinsicViewController.h"
#import "IntrinsicView.h"

@interface IntrinsicViewController ()

@end

@implementation IntrinsicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testInrinsicView];
}

- (void)testInrinsicView
{
    IntrinsicView *intrinsicView1 = [[IntrinsicView alloc] init];
//    intrinsicView1.extendSize = CGSizeMake(100, 100);
    [intrinsicView1 invalidateIntrinsicContentSize];
    intrinsicView1.backgroundColor = [UIColor greenColor];
    [self.view addSubview:intrinsicView1];
    [self.view addConstraints:@[
                                //距离superview上方100点
                                [NSLayoutConstraint constraintWithItem:intrinsicView1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100],
                                //距离superview左边100点
                                [NSLayoutConstraint constraintWithItem:intrinsicView1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:10]
                                ]];
    
    IntrinsicView *intrinsicView2 = [[IntrinsicView alloc] init];
    intrinsicView2.extendSize = CGSizeMake(100, 30);
    intrinsicView2.backgroundColor = [UIColor redColor];
    [self.view addSubview:intrinsicView2];
    [self.view addConstraints:@[
                                //距离superview上方220点
                                [NSLayoutConstraint constraintWithItem:intrinsicView2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:220],
                                //距离superview左面10点
                                [NSLayoutConstraint constraintWithItem:intrinsicView2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:10]
                                ]];
    [self performSelector:@selector(testInvalidateIntrinsic:) withObject:intrinsicView2 afterDelay:2];
    
    IntrinsicView *myView = [[IntrinsicView alloc] init];
//    myView.translatesAutoresizingMaskIntoConstraints = NO;
    myView.backgroundColor = [UIColor cyanColor];
//    [myView invalidateIntrinsicContentSize];
    myView.extendSize = CGSizeMake(100, 200);

    [self.view addSubview:myView];
    [myView addConstraints:@[
                             [NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:200],
                             [NSLayoutConstraint constraintWithItem:myView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:10]
                             ]];
    
    
    
}

- (void)testInvalidateIntrinsic:(IntrinsicView *)view
{
    view.extendSize = CGSizeMake(100, 80);
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
