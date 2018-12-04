//
//  HardwareViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/2.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "HardwareViewController.h"
#import "ISH246TVDecode.h"
#import "ISH264PlayerView.h"

@interface HardwareViewController ()<ISH264TVDecodeDelegate>
{
    ISH246TVDecode *_h264Decoder;
    ISH264PlayerView *_playLayer;
}

@property (nonatomic, strong) NSData *h264Data;
@property (nonatomic, strong) NSFileHandle *h264FileHandle;

@end

@implementation HardwareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"startDecode" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(startDecode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.frame = CGRectMake(20, 64, 100, 50);
  
  _h264FileHandle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle]pathForResource:@"ispeak" ofType:@"h264"]];
  _playLayer = [[ISH264PlayerView alloc] initWithFrame:CGRectMake(0, 200, ScreenWidth, ScreenWidth * 4 / 3.0)];
  _h264Decoder = [[ISH246TVDecode alloc] init];
  [_h264Decoder open:self width:ViewW(_playLayer) height:ViewH(_playLayer)];
  [self.view addSubview:_playLayer];
  
 
//    _h264Data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ispeak" ofType:@"h264"]];
  
//    _playLayer = [[AAPLEAGLLayer alloc] initWithFrame:CGRectMake(160, 120, 160, 300)];
//    _playLayer.backgroundColor = [UIColor blackColor].CGColor;
  
//  _h264Decoder = [H264HwDecoderImpl init];
//    [_h264Decoder open:self width:(uint16_t)ViewW(_playLayer) height:(uint16_t)ViewH(_playLayer)];
}

//解码回调
- (void)displayDecodedFrameImageBuffer:(CVPixelBufferRef)buffer
{
    if(buffer)
    {
        [_playLayer playForPixelBuffer:buffer];
        CVPixelBufferRelease(buffer);
    }
}

- (void)displayDecodedFrame:(CVImageBufferRef)imageBuffer
{
    
}

- (void)run {
    size_t out_size = 0;
  NSData *data = [_h264FileHandle readDataToEndOfFile];
  uint8_t uintData = [self uint8FromBytes:data];


  [_h264Decoder decodeNalu:&uintData withSize:data.length];
  
//    while (![[NSThread currentThread] isCancelled]) {
        /*这里从网路端循环获取视频数据*/
//                if (api_video_get(_uid, _vdata, &out_size) == 0 && out_size > 0) {
//                    if ([self decodeNalu:_vdata withSize:out_size]) {
//                    }
//                }
//        _h264Decoder decodeNalu:(uint8_t *) withSize:<#(uint32_t)#>
      
//        [NSThread sleepForTimeInterval:0.005];
//    }
}

- (uint8_t)uint8FromBytes:(NSData *)fData
{
  NSAssert(fData.length == 1, @"uint8FromBytes: (data length != 1)");
  NSData *data = fData;
  uint8_t val = 0;
  [data getBytes:&val length:1];
  return val;
}

- (void)startDecode:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self run];
    } else {
        
    }
    
    return;
    
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1;
    NSData *byteData = [NSData dataWithBytes:bytes length:length];
    
    NSString *bytesStr = @"00000001";
    
    NSString *str = [self convertDataToHexStr:_h264Data];
    NSArray *array = [str componentsSeparatedByString:bytesStr];
    int count = 0;
    while (str.length > bytesStr.length) {
        count++;
        NSRange range = [str rangeOfString:bytesStr];
        if (range.location == NSNotFound) {
            NSLog(@"完成");
            break;
        }
       NSString *tmpStr = [str substringToIndex:range.location];
        if (tmpStr.length > 0) {
            NSLog(@"tmp%d = %@", count, tmpStr);
        }
        str = [str substringFromIndex:range.location + range.length];
     
    }
    
    
//    [_h264Data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
//        NSLog(@"bytes = %@, byteRange = %@, stop = %d", bytes, NSStringFromRange(byteRange), *stop);
//    }];
    
}

- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}


- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    NSLog(@"hexdata: %@", hexData);
    return hexData;
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
