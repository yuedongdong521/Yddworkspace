//
//  DrawImageColorViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/7/12.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "DrawImageColorViewController.h"
#import <objc/runtime.h>
#import "UIImage+ChangeColor.h"

@interface DrawImageColorViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *orginImageView;

@property (weak, nonatomic) IBOutlet UIImageView *changeColorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;

@end

@implementation DrawImageColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(20, 100, 100, 50);
    [button setTitle:@"点击" forState:UIControlStateNormal];
    
    objc_setAssociatedObject(button, "firstAction", self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(button, "secondAction", @"secondAction", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _orginImageView.image = [UIImage imageNamed:@"0.jpg"];
    
    self.rightImage.image = [UIImage imageWithColor:[UIColor cyanColor] size:self.rightImage.frame.size];
    self.leftImage.image = [UIImage imageWithColor:[UIColor greenColor] size:self.leftImage.frame.size text:@"测试颜色" textAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:22]} circular:YES];

}

- (void)buttonAction:(UIButton *)button
{
    id first = objc_getAssociatedObject(button, "firstAction");
    id second = objc_getAssociatedObject(button, "secondAction");
    SEL sel = NSSelectorFromString(second);
    if ([first respondsToSelector:sel]) {
        [first performSelector:sel withObject:nil];
    }
    NSLog(@"first");
    UIImage *colorImage = [[UIImage imageNamed:@"0.jpg"] imageChangeColor:[UIColor colorWithWhite:0.3 alpha:0.3]];
    _changeColorImageView.image = colorImage;
}

- (void)secondAction
{
    NSLog(@"second");
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
