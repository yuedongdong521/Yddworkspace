//
//  CoreTextViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/1/6.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "CoreTextViewController.h"
#import "MyTextView.h"

@interface CoreTextViewController ()

@end

@implementation CoreTextViewController

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"CoreTextViewController.view.frame = %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"CoreTextViewController.view.bounds = %@",NSStringFromCGRect(self.view.bounds));
    NSLog(@"CoreTextViewController.edgesForExtendedLayout = %lu", (unsigned long)self.edgesForExtendedLayout);
    NSLog(@"CoreTextViewController.translucent = %d", self.navigationController.navigationBar.translucent);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *image = [self creatRoundImage:[UIImage imageNamed:@"0.jpg"] andSize:CGSizeMake(100, 100)];
    
    MyTextView *myTextView = [[MyTextView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.origin.y +  self.navigationController.navigationBar.frame.size.height, ScreenWidth, ScreenWidth)];
    myTextView.image = image;

    myTextView.currentText = @"2016年10月，我来到简书。和所有的新人一样，睁着新奇的双眼，尝试着给生活家专题投稿。因为文章质量不错，当时的主编林子慕邀请我进入了社群。我注意到，时常跟我的文章一起成功入选专题的一个姑娘，也跟着同时加入了。她的名字是鸢萝。\n我跟鸢萝是生活家社群的活跃份子。进入没多久，就迎来了一个契机：子慕要招聘副主编。我俩兴奋又顺利地投递了资料，然而，却都没有中。不过，群管理员的头衔“砸”了过来。她成了一群的群管，我在二群。从此，我们跟着子慕小可爱一起，开始了简书江湖的闯荡生涯。\n生活家社群管理的身份使得我和鸢萝姑娘进一步接近了。我们一起想活动、做活动，玩得不亦玩乎。常常在大群里聊得天翻地覆后，又接着私聊。一来二去，我就掌握了不少姑娘的资料：例如她是四川绵阳人，例如她正在读大四。她乐意说，我乐意听。聊得多了，就知道了对方的故事，知道了对方给予自己的意义。\n网络，让我俩成为了最熟悉的陌生人。\n天空是白的，风很蓝；树间叶隙，有细细密密的阳光在跳舞。这些鸢萝的心事，只有我读得懂。\n太阳升起，四下里都是暖。微信里这个大大咧咧，女汉纸似的姑娘送来的字字句句，总让我的一天一如既往却又充满期待。";
    myTextView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:myTextView];
//    [myTextView setNeedsDisplay];
    
}

- (UIImage *)creatRoundImage:(UIImage *)originImage andSize:(CGSize)size
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = originImage;
    //开始对imageView进行画图
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGRect rect = imageView.bounds;
    CGContextAddEllipseInRect(contextRef, rect); //添加椭圆区域
    CGContextClip(contextRef); //裁剪
    [imageView.image drawInRect:rect];
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
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
