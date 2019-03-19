//
//  MutableThreadViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/7/28.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "MutableThreadViewController.h"

@interface MutableThreadViewController ()

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) NSString *imageUrl1;
@property (nonatomic, strong) NSString *imageUrl2;

@end

@implementation MutableThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    _imageUrl1 = @"http://img06.tooopen.com/images/20170723/tooopen_sl_217707083674.jpg";
    
    _imageUrl2 = @"http://img06.tooopen.com/images/20170511/tooopen_sl_209123759718.jpg";
    
    _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 64, 100, 100)];
    _imageView1.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_imageView1];
    
    _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(200, 64, 100, 100)];
    _imageView2.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_imageView2];
    
    
    [self careteBtn:@selector(buttonActionGCD) Title:@"GCD" Frame:CGRectMake(20, 200, 100, 50)];
  
 

}
                        
- (void)careteBtn:(SEL)action Title:(NSString *)title Frame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor blueColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonActionGCD
{
    [self GCDThreadSynchronization];
}

//让 2 个子线程并行执行，然后等 2 个线程都结束后，再汇总执行结果。这个可以用 dispatch_group, dispatch_group_async 和 dispatch_group_notify 来实现，
- (void)GCDThreadSynchronization
{
    _imageView1.image = nil;
    _imageView2.image = nil;
    __block UIImage *image1 = nil;
    __block UIImage *image2 = nil;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageUrl1]];
        image1 = [UIImage imageWithData:data];
        NSLog(@"图片1加载完成🙂");
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageUrl2]];
        image2 = [UIImage imageWithData:data];
        NSLog(@"图片2加载完成🍎");
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView1.image = image1;
            _imageView2.image = image2;
            NSLog(@"开始同步😆");
        });
    });
    
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
