//
//  StrToEmojiViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2018/3/9.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "StrToEmojiViewController.h"

@interface StrToEmojiViewController ()
@property (nonatomic, strong)UILabel *myLabel;
@end

@implementation StrToEmojiViewController

void unicode_print( unsigned char *unicode, int size )
{
    if ( size == -1 )
    {
        printf("Error : unknow scope\n");
        return;
    }
    
    int index = 0;
    for ( ; index < size; index += 1 )
    {
        printf( "%02X", *( unicode + index ) );
    }
    
    printf("\n");
}

int utf_to_unicode( unsigned long utf, unsigned char *unicode )
{
    int size = 0;
    if ( utf <= 0x7F )
    {
        *( unicode + size++ ) = utf & 0x7F;
    }
    else if ( utf >= 0xC080 && utf <= 0xCFBF )
    {
        *( unicode + size++ ) = ( ( utf >> 10 ) & 0x07 );
        *( unicode + size++ ) = ( utf & 0x3F ) | ( ( ( utf >> 8 ) & 0x03 ) << 6);
    }
    else if ( utf >= 0xE08080 && utf <= 0xEFBFBF )
    {
        *( unicode + size++ ) = ( ( utf >> 10 ) & 0x0F ) | (( utf >> 16 ) & 0x0F ) << 4;
        *( unicode + size++ ) = ( utf & 0x3F ) | ((( utf >> 8 ) & 0x03 ) << 6 );
    }
    else if ( utf >= 0xF0808080 && utf <= 0xF7BFBFBF )
    {
        *( unicode + size++ ) = ( (utf >> 20 ) & 0x03 ) | ((( utf >> 24 ) & 0x07 ) << 2 );
        *( unicode + size++ ) = (( utf >> 10 ) & 0x0F ) | ( ( ( utf >> 16 ) & 0x0F ) << 4 );
        *( unicode + size++ ) = ( utf & 0x3F ) | ( ( utf >> 8 ) & 0x03 ) << 6;
    }
    else if ( utf >= 0xF880808080 && utf <= 0xFBBFBFBFBF )
    {
        *( unicode + size++ ) = ( utf >> 32 ) & 0x03;
        *( unicode + size++ ) = ( ( utf >> 20 ) & 0x03 ) | ( ( ( utf >> 24 ) & 0x3F ) << 2 );
        *( unicode + size++ ) = ( ( utf >> 10 ) & 0x0F ) | ( ( ( utf >> 16 ) & 0x0F ) << 4 );
        *( unicode + size++ ) = ( utf & 0x3F ) | ( ( (utf >> 8) & 0x03 ) << 6 );
    }
    else if ( utf >= 0xFC8080808080 && utf <= 0xFDBFBFBFBFBF )
    {
        *( unicode + size++ ) = ( ( utf >> 32 ) & 0x3F ) | ( ( ( utf >> 40 ) & 0x01 ) << 6 );
        *( unicode + size++ ) = ( ( utf >> 20 ) & 0x03 ) | ( ( ( utf >> 24 ) & 0x3F ) << 2 );
        *( unicode + size++ ) = ( ( utf >> 10 ) & 0x0F ) | ( ( ( utf >> 16 ) & 0x0F ) << 4 );
        *( unicode + size++ ) = ( utf & 0x3F ) | ( ( ( utf >> 8 ) & 0x03 ) << 6 );
    }
    else
    {
        printf( "Error : unknow scope\n" );
        return -1;
    }
    
    *( unicode + size ) = '\0';
    return size;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    //eda0bded b88a
    NSString *emojiStr = @"eda0bdedb88a";
    NSString *emojiPer = [emojiStr substringWithRange:NSMakeRange(0, 6)];
    NSString *emojiSuf = [emojiStr substringWithRange:NSMakeRange(6, 6)];
    
    unsigned char utf_per[9];
    unsigned char utf_suf[9];
    
    memcpy(utf_per, [emojiPer UTF8String], emojiPer.length);
    memcpy(utf_suf, [emojiSuf UTF8String], emojiSuf.length);
    
    unsigned char unicode_per[9];
    unsigned char unicode_suf[9];
    unsigned char new_unicode[20];
    
    int size_per = 0;
    memset( unicode_per, 0x00, sizeof( unicode_per ) );
    //    unsigned char utf_per[9] = "0xeda0bd";
    unsigned long utfl_per = strtoul((const char *)utf_per, 0, 16);
    size_per = utf_to_unicode( utfl_per, unicode_per );
    unicode_print( unicode_per, size_per );
    
    int size_suf = 0;
    memset( unicode_suf, 0x00, sizeof( unicode_suf ) );
    //    unsigned char utf_suf[9] = "0xedb88a";
    unsigned long utfl_suf = strtoul((const char *)utf_suf, 0, 16);
    size_suf = utf_to_unicode( utfl_suf, unicode_suf );
    unicode_print( unicode_suf, size_suf );
    
    
    unsigned long len_fir = strlen((const char *)unicode_per);
    for (unsigned long i = 0; i < len_fir; i++) {
        new_unicode[i] = unicode_per[i];
    }
    unsigned long len_sec = strlen((const char *)unicode_suf);
    for (unsigned long i = 0; i < len_sec; i++) {
        new_unicode[len_fir + i] = unicode_suf[i];
    }
    
    unsigned long len_new = (int)strlen((const char *)new_unicode);
    
    NSString *str = [[NSString alloc] initWithBytes:new_unicode length:len_new encoding:NSUTF16StringEncoding];
    
    self.myLabel.text = str;
    NSLog(@"Emoji: %@", self.myLabel.text);
    
}

- (UILabel *)myLabel
{
    if (!_myLabel) {
        _myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 320, 400)];
        _myLabel.numberOfLines = 0;
        [self.view addSubview:_myLabel];
        _myLabel.textColor = [UIColor blackColor];
    }
    return _myLabel;
}

//将NSData转换成十六进制的字符串
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

//将十六进制字符串转换成NSData
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
