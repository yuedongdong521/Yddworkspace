//
//  BarrageViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/1/14.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "BarrageViewController.h"
#import "BarrageView.h"
#import "BarrageModel.h"
#import <AVFoundation/AVFoundation.h>
#import "PriaseSendStructure.h"

@interface BarrageViewController ()

{
    NSMutableArray  *imageArr;
    UIWebView       *movieShow;
    NSTimer         * timer;
    BOOL            isVideo;
}

@property (nonatomic, strong) BarrageView *barrageView;
@end

@implementation BarrageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    _barrageView = [[BarrageView alloc] initWithFrame:self.view.bounds];
    _barrageView.maxLineCount = 5;
    _barrageView.isUniform = YES;
    [self.view addSubview:_barrageView];
    
    UIButton *send = [UIButton buttonWithType:UIButtonTypeSystem];
    send.frame = CGRectMake(ScreenWidth / 2.0 - 50, ScreenHeight - 100, 100, 50);
    [send setTitle:@"send" forState:UIControlStateNormal];
    [send addTarget:self action:@selector(sendBarage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:send];
    
    
    isVideo = YES;
    UIButton * button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button1 setFrame:CGRectMake(20, 100, 80, 50)];
    [button1 setTitle:@"start recording" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(testCompressionSession) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setFrame:CGRectMake(150, 100, 80, 50)];
    [button2 setTitle:@"show Video" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(movieShow:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button3 setFrame:CGRectMake(250, 100, 80, 50)];
    [button3 setTitle:@"stop recording" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button1];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
    
    
}

- (void)sendBarage
{
    NSArray *nameArray = @[@"特朗普", @"四星上将", @"君莫笑",@"一叶知秋", @"景甜", @"包子入侵"];
    
    NSArray *contentArray = @[@"特朗普当选总统后关于酷刑的看法有所改观", @"包括３３名四星上将在内", @"赞",@"他们写道", @"合法、以和谐为基础的审讯手段是获取情报的最佳方式", @"一包烟和两瓶啤酒"];
    int count = arc4random() % contentArray.count;
    int nameCount = arc4random() % nameArray.count;
    PriaseSendStructure *model = [[PriaseSendStructure alloc] init];
    model.username = [nameArray objectAtIndex:nameCount];
    model.content = [contentArray objectAtIndex:count];
    model.imagePathStr = @"0.jpg";
    
//    model.rankCustom = 150;
    [_barrageView sendBarrageForPraise:model];
}


-(void)stop
{
    if ([timer isValid])
        [timer invalidate];
        timer = nil;
        isVideo = NO;
}

-(void)addImageData
{
    timer = [[NSTimer alloc] initWithFireDate:[NSDate new] interval:0.09 target:self selector:@selector(getImageDataTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
}

-(void)getImageDataTimer:(NSTimer *)timer
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    [imageArr addObject:image];
    UIGraphicsEndImageContext();
}

-(IBAction)movieShow:(id)sender
{
    movieShow = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [movieShow setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:movieShow];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *moviePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"test"]];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[moviePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [movieShow loadRequest:request];
    
}

- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)testCompressionSession
{
    if ([imageArr count] == 0 && isVideo == YES) {
        imageArr = [[NSMutableArray alloc] initWithObjects:nil];
        
        NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self                                                                           selector:@selector(addImageData) object:nil];
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [queue addOperation:operation];
        [NSThread sleepForTimeInterval:0.1];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *moviePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"test"]];
        CGSize size = self.view.bounds.size;
        NSError *error = nil;
        
        unlink([moviePath UTF8String]);
        AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:moviePath]
                                                               fileType:AVFileTypeQuickTimeMovie
                                                                  error:&error];
        NSParameterAssert(videoWriter);
        if(error)
            NSLog(@"error = %@", [error localizedDescription]);
        
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                       [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                       [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
        AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
        
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                         assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        NSParameterAssert(writerInput);
        NSParameterAssert([videoWriter canAddInput:writerInput]);
        
        if ([videoWriter canAddInput:writerInput])
            NSLog(@"ok");
        else
            NSLog(@"……");
        
        [videoWriter addInput:writerInput];
        
        [videoWriter startWriting];
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
        
        dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
        int __block frame = 0;
        
        [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
            NSLog(@"wrierInput is->>>>>>>>>%i",[writerInput isReadyForMoreMediaData]);
            while ([writerInput isReadyForMoreMediaData])
            {
                NSLog(@"imageArr->%d,isVieo ---->%i",[imageArr count],isVideo);
                if([imageArr count] == 0&&isVideo == NO)
                {
                    isVideo = YES;
                    [writerInput markAsFinished];
                    [videoWriter finishWritingWithCompletionHandler:^{}];

                    break;
                }
                if ([imageArr count] == 0&&isVideo == YES) {
                }
                else
                {
                    CVPixelBufferRef buffer = NULL;
                    buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imageArr objectAtIndex:0] CGImage] size:size];
                    if (++frame == 0) {
                        [imageArr removeObjectAtIndex:0];
                    }
                    if (buffer)
                    {
                        if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, 120)])
                            NSLog(@"FAIL");
                        else{
                            NSLog(@"doing……");
                            CFRelease(buffer);
                        }
                    }
                }
                
                
            }
        }];
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
