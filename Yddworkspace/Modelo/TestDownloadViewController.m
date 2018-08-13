//
//  TestDownloadViewController.m
//  Yddworkspace
//
//  Created by lwj on 2018/5/17.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "TestDownloadViewController.h"
#import "NetWorkURLSession.h"

@interface TestDownloadViewController ()
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NetWorkURLSession *session;
@end

@implementation TestDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor whiteColor];
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.frame = CGRectMake(100, 100, 100, 100);
  [button setTitle:@"下载" forState:UIControlStateNormal];
  [button addTarget:self action:@selector(buttonAcrion) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  
  _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
  _progressView.frame = CGRectMake(20, 300, ScreenWidth - 40, 50);
  _progressView.progressTintColor = [UIColor redColor];
  _progressView.trackTintColor = [UIColor greenColor];
  [self.view addSubview:_progressView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  
}

- (void)viewWillDisappear:(BOOL)animated
{
//  [_session cancelDownload];
}

- (NSString *)getSavePath:(NSString *)name type:(NSString *)type
{
  NSString *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
  NSString *directoryPath = [path stringByAppendingPathComponent:@"downloadTest"];
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  BOOL isDire;
  BOOL isEx = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDire];
  if (!isEx || !isDire ) {
    [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
  }
  NSString *filePath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", name, type]];
  if ([fileManager fileExistsAtPath:filePath]) {
    [fileManager removeItemAtPath:filePath error:nil];
  }
  return filePath;
}

- (void)buttonAcrion
{

  static int i = 0;
  _session = [[NetWorkURLSession alloc] init];

  NSString *savePath = [self getSavePath:[NSString stringWithFormat:@"%d", i++] type:@"mp4"];
  [_session downLoad:[NSURL URLWithString:@"http://img.ipark.cn/ishowapp/2018/0502/1525252789089900lpSwWspoSgRHD8Woof6ZYXjB4Q5b-v128x264.mp4"] savePath:savePath completeProgress:^(double progress) {
    _progressView.progress = progress;
  } finish:^(NSError *error) {
    NSLog(@"error:%@", error);
  }];
}

- (void)dealloc
{

  NSLog(@"%@: dealloc", NSStringFromClass([self class]));
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
