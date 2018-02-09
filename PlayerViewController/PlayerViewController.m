//
//  PlayerViewController.m
//  Yddworkspace
//
//  Created by ispeak on 16/9/8.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "PlayerViewController.h"
#import "PKChatMessagePlayerView.h"
#import "BlazeiceAudioRecordAndTransCoding.h"
#import "THCapture.h"
#import "BarrageController.h"

#define VEDIOPATH @"vedioPath"

@interface PlayerViewController ()<THCaptureDelegate, AVAudioRecorderDelegate, BlazeiceAudioRecordAndTransCodingDelegate>
{
    THCapture *capture;
    BlazeiceAudioRecordAndTransCoding *audioRecord;
    NSString *opPath;
    NSTimer *timer;
}

@property (nonatomic, strong)PKChatMessagePlayerView *playerView;
@property (nonatomic, strong)BarrageController *barrageCtrl;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(play) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:UIApplicationWillResignActiveNotification object:nil];
    
    _barrageCtrl = [[BarrageController alloc] initBarrageController];
    _barrageCtrl.maxLineCount = 4;
    _barrageCtrl.isUniform = NO;
    NSArray *nameArray = @[@"特朗普", @"四星上将", @"君莫笑",@"一叶知秋", @"景甜", @"包子入侵"];
    
    NSArray *contentArray = @[@"特朗普当选总统后关于酷刑的看法有所改观", @"包括３３名四星上将在内", @"赞",@"他们写道", @"合法、以和谐为基础的审讯手段是获取情报的最佳方式", @"一包烟和两瓶啤酒"];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        int count = arc4random() % contentArray.count;
        int nameCount = arc4random() % nameArray.count;
        BarrageModel *model = [[BarrageModel alloc] init];
        model.nameStr = [nameArray objectAtIndex:nameCount];
        model.contentStr = [contentArray objectAtIndex:count];
        model.imagestr = @"0.jpg";
        model.rankStr = @"rank_150";
        [_barrageCtrl sendBarrageForBarrageModel:model bgView:self.view];
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"开始录制" forState:UIControlStateNormal];
    button.frame = CGRectMake(ScreenWidth / 2.0 - 50, ScreenHeight - 100, 100, 50);
    [button addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Cat" ofType:@".mp4"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    CGSize viewSize = self.view.bounds.size;

    
    self.playerView = [[PKChatMessagePlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.width) videoPath:path];
    self.playerView.center = self.view.center;
    
    [self.view addSubview:self.playerView];
    
    [self.playerView play];
//
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    timer = nil;
    [_barrageCtrl timerInval];
    
}

- (void)startRecord:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"开始录制"]) {
        [button setTitle:@"停止录制" forState:UIControlStateNormal];
        [self recordMustSuccess];
    } else {
        [button setTitle:@"开始录制" forState:UIControlStateNormal];
        [self StopRecord];
    }
}

- (void)recordMustSuccess {
    if(capture == nil){
        capture=[[THCapture alloc] init];
    }
    capture.frameRate = 35;
    capture.delegate = self;
    capture.captureLayer = self.view.layer;
    if (!audioRecord) {
        audioRecord = [[BlazeiceAudioRecordAndTransCoding alloc]init];
        audioRecord.recorder.delegate=self;
        audioRecord.delegate=self;
    }
    
    
    [capture performSelector:@selector(startRecording1)];
    
    NSString* path=[self getPathByFileName:VEDIOPATH ofType:@"wav"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]){
        [fileManager removeItemAtPath:path error:nil];
    }
    [self performSelector:@selector(toStartAudioRecord) withObject:nil afterDelay:0.1];
    
}

#pragma mark -
#pragma mark audioRecordDelegate
/**
 *  开始录音
 */
-(void)toStartAudioRecord
{
    [audioRecord beginRecordByFileName:VEDIOPATH];
}
/**
 *  音频录制结束合成视频音频
 */
-(void)wavComplete
{
    //视频录制结束,为视频加上音乐
    if (audioRecord) {
        NSString* path=[self getPathByFileName:VEDIOPATH ofType:@"wav"];
        [THCaptureUtilities mergeVideo:opPath andAudio:path andTarget:self andAction:@selector(mergedidFinish:WithError:)];
    }
}


#pragma mark -
#pragma mark THCaptureDelegate
- (void)recordingFinished:(NSString*)outputPath
{
    opPath=outputPath;
    if (audioRecord) {
        [audioRecord endRecord];
    }
    //[self mergedidFinish:outputPath WithError:nil];
}

- (void)recordingFaild:(NSError *)error
{
}


#pragma mark -
#pragma mark CustomMethod

- (void)video: (NSString *)videoPath didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInfo{
    if (error) {
        NSLog(@"---%@",[error localizedDescription]);
    }
}

- (void)mergedidFinish:(NSString *)videoPath WithError:(NSError *)error
{
    NSDateFormatter* dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    NSString* currentDateStr=[dateFormatter stringFromDate:[NSDate date]];
    
    NSString* fileName=[NSString stringWithFormat:@"白板录制,%@.mov",currentDateStr];
    
    NSString* path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath])
    {
        NSError *err=nil;
        [[NSFileManager defaultManager] moveItemAtPath:videoPath toPath:path error:&err];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"allVideoInfo"]) {
        NSMutableArray* allFileArr=[[NSMutableArray alloc] init];
        [allFileArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"allVideoInfo"]];
        [allFileArr insertObject:fileName atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:allFileArr forKey:@"allVideoInfo"];
    }
    else{
        NSMutableArray* allFileArr=[[NSMutableArray alloc] init];
        [allFileArr addObject:fileName];
        [[NSUserDefaults standardUserDefaults] setObject:allFileArr forKey:@"allVideoInfo"];
    }
    
    //音频与视频合并结束，存入相册中
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}


- (void)StopRecord{
    
    [capture performSelector:@selector(stopRecording)];
}

- (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stop];
    [self.barrageCtrl timerInval];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    static BOOL isPlayer = YES;
//    if (isPlayer) {
//        [self stop];
//    } else {
//        [self play];
//    }
//    isPlayer = !isPlayer;
}


- (void)play
{
    [_playerView play];
}

- (void)stop
{
    [_playerView stop];
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
