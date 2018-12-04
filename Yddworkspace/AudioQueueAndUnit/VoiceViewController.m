//
//  VoiceViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2018/3/15.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "VoiceViewController.h"
#import "VoiceConvertHandle.h"


@interface VoiceViewController ()<VoiceConvertHandleDelegate>

@property (nonatomic, strong) NSFileHandle *aacFile;

@end

@implementation VoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [VoiceConvertHandle shareInstance].delegate = self;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 120, 100, 50);
    [button setTitle:@"开始通话" forState:UIControlStateNormal];
    [button setTitle:@"结束通话" forState:UIControlStateSelected];
    [button addTarget:self action:@selector(voiceAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = [path stringByAppendingPathComponent:@"AacFile"];
    NSFileManager *filemanager = [[NSFileManager alloc] init];
    BOOL isDire;
    BOOL isExist = [filemanager fileExistsAtPath:path isDirectory:&isDire];
    if (isDire == NO || isExist == NO) {
        [filemanager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingPathComponent:@"currentFile.aac"];
    if ([filemanager isExecutableFileAtPath:path]) {
        [filemanager removeItemAtPath:path error:nil];
    }
    [filemanager createFileAtPath:path contents:nil attributes:nil];
    _aacFile = [NSFileHandle fileHandleForWritingAtPath:path];
    
}

- (void)voiceAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [[VoiceConvertHandle shareInstance] setStartRecord:btn.selected];
    if (!btn.selected) {
        [_aacFile closeFile];
    }
}

- (void)covertedData:(NSData *)data
{
    NSLog(@"aac data length = %d", data.length);
    if (data && [VoiceConvertHandle shareInstance].startRecord) {
        [_aacFile writeData:data];
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
