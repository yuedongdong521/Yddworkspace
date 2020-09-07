//
//  AlphaPlayerViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/3/24.
//  Copyright © 2020 QH. All rights reserved.
//

#import "AlphaPlayerViewController.h"
#import "AlphaPlayer.h"
#import <CoreImage/CoreImage.h>
#import "VideoOperation.h"

@interface AlphaPlayerViewController ()

@property (nonatomic, strong) AlphaPlayer *player;

@property (nonatomic, strong) NSOperationQueue *videoQueue;

@end

@implementation AlphaPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    CIFilter *filter1 = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    NSLog(@"CILanczosScaleTransform keys : %@", filter1.inputKeys);
    
    
    CIFilter *filter2 = [CIFilter filterWithName:@"CISourceOverCompositing"];
    NSLog(@"CISourceOverCompositing keys : %@", filter2.inputKeys);
    
    CIFilter *filter3 = [CIFilter filterWithName:@"CIAffineTransform"];
    NSLog(@"CIAffineTransform keys : %@", filter3.inputKeys);
    
    
    
    [self.view addSubview:self.player];
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    self.videoQueue = [[NSOperationQueue alloc] init];
    
    self.videoQueue.maxConcurrentOperationCount = 1;
    
    NSArray <NSString *>*videArr = @[@"giftvideo", @"520"];
    [videArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.videoQueue addOperation:[self getVideoOperation:obj]];
    }];
    
    
    
    
}

- (VideoOperation *)getVideoOperation:(NSString *)videoPath
{
    VideoOperation *operation = [[VideoOperation alloc] init];
    operation.videoPath = [[NSBundle mainBundle] pathForResource:videoPath ofType:@"mp4"];
    __weak typeof(self) weakself = self;
    operation.taskStart = ^(NSString * _Nonnull videoPath, void (^ _Nonnull completed)(BOOL)) {
        __strong typeof(weakself) strongself = weakself;
        NSLog(@"getVideoOperation : %@", videoPath);
        [strongself.player startURL:videoPath completed:^(BOOL finished) {
            if (completed) {
                completed(YES);
            }
        }];
        
    };
    return operation;
}

- (AlphaPlayer *)player
{
    if (!_player) {
        _player = [[AlphaPlayer alloc] init];
    }
    return _player;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_player stopPlayer];
    [self.videoQueue cancelAllOperations];
    _videoQueue = nil;
    
}

- (UIModalPresentationStyle)modalPresentationStyle
{
    return UIModalPresentationOverFullScreen;
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
