//
//  GifViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/8/23.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "GifViewController.h"
#import "UIImage+ScallGif.h"
#import "UIImageView+PlayGIF.h"
#import "UIImage+GIF.h"
#import "SCGIFImageView.h"
#import "UIImageView+YYWebImage.h"
#import "YYAnimatedImageView.h"
@interface GifViewController ()

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) SCGIFImageView *scallImageView;
@property(nonatomic, strong) YYAnimatedImageView *yyImageView;

@end

@implementation GifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.imageView];
  [self.view addSubview:self.scallImageView];
  [self.view addSubview:self.yyImageView];
  
  [self downloadGif];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

  
}

- (YYAnimatedImageView *)yyImageView
{
  if (!_yyImageView) {
    _yyImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(20, 64, 300, 300)];
    _yyImageView.contentMode = UIViewContentModeScaleAspectFit;
    _yyImageView.backgroundColor = [UIColor grayColor];
  }
  return _yyImageView;
}

- (UIImageView *)imageView
{
  if (!_imageView) {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 64, 300, 300)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.backgroundColor = [UIColor grayColor];
  }
  return _imageView;
}

- (SCGIFImageView *)scallImageView
{
  if (!_scallImageView) {
    _scallImageView = [[SCGIFImageView alloc] initWithFrame:CGRectMake(20, 400, 200, 200)];
    _scallImageView.backgroundColor = [UIColor cyanColor];
  }
  return _scallImageView;
}

- (void)downloadGif
{
  
  [_yyImageView setImageWithURL:[NSURL URLWithString:@"http://imgs22.ispeak.cn/file/2018-08-22/10/20180822_104155115723_f928e2_0_173146354_31873.gif"] placeholder:[UIImage new] options:YYWebImageOptionProgressive completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
//    [self scallGifWidthData:[]];
  }];
  
//
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://imgs22.ispeak.cn/file/2018-08-22/10/20180822_104155115723_f928e2_0_173146354_31873.gif"]];
//    dispatch_async(dispatch_get_main_queue(), ^{
//      if (data) {
////        _imageView.image = [UIImage imageWithData:data];
////        _imageView.gifData = data;
////        [_imageView startGIF];
//
//        NSLog(@"data lenght = %@", @(data.length));
//        [self scallGifWidthData:data];
//      }
//    });
//  });
}

- (void)scallGifWidthData:(NSData *)data
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSData *scallData = [UIImage scallGIFWithData:data scallSize:CGSizeMake(200, 200)];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (scallData) {
//        UIImage *scallImage = [UIImage imageWithData:scallData];
//        self.scallImageView.image = scallImage;
//        self.scallImageView.gifData = scallData;
//        [self.scallImageView startGIF];
        NSLog(@"scallData lenght = %@", @(scallData.length));
        self.scallImageView.image = [UIImage sd_animatedGIFWithData:scallData];
//        [self.scallImageView setGifData:scallData];
      }
    });
  });
}

- (NSString *)saveScallImageViewWidthData:(NSData *)gifData
{
  NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
  NSString *directory = [path stringByAppendingPathComponent:@"gif"];
  NSFileManager *manager = [NSFileManager defaultManager];
  BOOL isDire;
  BOOL isExis = [manager fileExistsAtPath:directory isDirectory:&isDire];
  if (!isExis || !isDire) {
    [manager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
  }
  NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:0];
  NSTimeInterval curTime = [[NSDate date] timeIntervalSinceDate:curDate] * 1000;
  NSString *string = [NSString stringWithFormat:@"%@.gif", @(curTime)];
  NSString *filePath = [directory stringByAppendingPathComponent:string];
  
  if ([manager fileExistsAtPath:filePath]) {
    [manager removeItemAtPath:filePath error:nil];
  }
  [gifData writeToFile:filePath atomically:YES];
  
  return filePath;
}


- (NSString *)getScallGifPath:(NSString *)gifName
{
  NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
  NSString *directory = [path stringByAppendingPathComponent:@"gif"];
  NSFileManager *manager = [NSFileManager defaultManager];
  BOOL isDire;
  BOOL isExis = [manager fileExistsAtPath:directory isDirectory:&isDire];
  if (!isExis || !isDire) {
    [manager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
  }
  NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:0];
  NSTimeInterval curTime = [[NSDate date] timeIntervalSinceDate:curDate] * 1000;
  NSString *string = [NSString stringWithFormat:@"%@-%@.gif", @(curTime), gifName];
  NSString *filePath = [directory stringByAppendingPathComponent:string];
  
  if ([manager fileExistsAtPath:filePath]) {
    [manager removeItemAtPath:filePath error:nil];
  }
  return filePath;
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
