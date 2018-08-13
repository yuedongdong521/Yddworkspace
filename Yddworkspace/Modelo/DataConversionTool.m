//
//  DataConversionTool.m
//  Yddworkspace
//
//  Created by lwj on 2018/5/16.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "DataConversionTool.h"

@implementation DataConversionTool

+ (NSString *)hexFromInt:(int)val
{
  return [NSString stringWithFormat:@"%x", val];
}


+ (NSData *)dataFromHexString:(NSString *)hexString
{
  NSAssert((hexString.length > 0) && (hexString.length % 2) == 0,  @"hexString.length mod 2 != 0");
  NSMutableData *data = [[NSMutableData alloc] init];
  for (NSInteger i = 0; i < hexString.length; i += 2) {
    NSRange tmpRange = NSMakeRange(i, 2);
    NSString *tmpStr = [hexString substringWithRange:tmpRange];
    NSScanner *scanner = [NSScanner scannerWithString:tmpStr];
    unsigned int tmpIntValue;
    BOOL suc = [scanner scanHexInt:&tmpIntValue];
    if (suc) {
      [data appendBytes:&tmpIntValue length:1];
    }
  }
  return data;
}

+ (NSString *)hexStringFromData:(NSData *)data
{
  NSAssert(data.length > 0, @"data.length <= 0");
  NSMutableString *hexString = [[NSMutableString alloc] init];
  const Byte *bytes = data.bytes;
  for (NSInteger i = 0; i < data.length; i++) {
    Byte value = bytes[i];
    Byte high = (value & 0xf0) >> 4;
    Byte low = value & 0xf;
    [hexString appendFormat:@"%x%x", high, low];
  }
  return hexString;
}

// uint8_t : unsigned char
// uint8_t 转 NSData (占两位)
+ (NSData *)byteFromUInt8:(uint8_t)val
{
  NSMutableData *valData = [[NSMutableData alloc] init];
  unsigned char valChar[1];
  valChar[0] = 0xff & val;
  [valData appendBytes:valChar length:1];
  return [self dataWithReverse:valData];
}

// uint16(unsigned short) 转NSData（占四位）
+ (NSData *)bytesFromUInt16:(uint16_t)val
{
  NSMutableData *valData = [[NSMutableData alloc] init];
  unsigned char valChar[2];
  valChar[0] = 0xff & val;
  valChar[1] = (0xff00 & val) >> 8;
  [valData appendBytes:valChar length:2];
  return [self dataWithReverse:valData];
  
}

// Uint32 转 NSData (占八位)
+ (NSData *)bytesFromUInt32:(uint32_t)val
{
  NSMutableData *valData = [[NSMutableData alloc] init];
  unsigned char valChar[4];
  valChar[0] = 0xff & val;
  valChar[1] = (0xff00 & val) >> 8;
  valChar[2] = (0xff0000 & val) >> 16;
  valChar[3] = (0xff000000 & val) >> 24;
  [valData appendBytes:valChar length:4];
  return [self dataWithReverse:valData];
}

+ (uint8_t)uint8FromBytes:(NSData *)fData
{
  NSAssert(fData.length == 1, @"uint8FromBytes: (data length != 1)");
  NSData *data = fData;
  uint8_t val = 0;
  [data getBytes:&val length:1];
  return val;
}

+ (uint16_t)uint16FromBytes:(NSData *)fdata
{
  NSAssert(fdata.length == 2, @"uint16FromBytes:(data length != 2)");
  NSData *data = [self dataWithReverse:fdata];
  uint16_t val0 = 0;
  uint16_t val1 = 0;
  [data getBytes:&val0 range:NSMakeRange(0, 1)];
  [data getBytes:&val1 range:NSMakeRange(1, 1)];
  uint16_t dstVal = (val0 & 0xff) + ((val1 << 8) & 0xff00);
  return dstVal;
}

+ (uint32_t)uint32FromBytes:(NSData *)fData
{
  NSAssert(fData.length == 4, @"uint32FromBytes: (data length != 4)");
  NSData *data = [self dataWithReverse:fData];
  uint32_t val0 = 0;
  uint32_t val1 = 0;
  uint32_t val2 = 0;
  uint32_t val3 = 0;
  [data getBytes:&val0 range:NSMakeRange(0, 1)];
  [data getBytes:&val1 range:NSMakeRange(1, 1)];
  [data getBytes:&val2 range:NSMakeRange(2, 1)];
  [data getBytes:&val3 range:NSMakeRange(3, 1)];
  uint32_t dstVal = (val0 & 0xff) + (val1 << 8) & 0xff00 + (val2 << 16) & 0xff0000 + (val3 << 24) & 0xff000000;
  return dstVal;
}

+ (void)dataConversionByte:(NSData *)data
{
  uint8_t byteArray[data.length];
  [data getBytes:&byteArray length:[data length]];
  for (int i = 0; i < data.length; i++) {
    Byte byte = byteArray[i];
    NSLog(@"--byte%x", byte);
  }
}

// NSData转int (用CFSwapInt32BigToHost)
+ (int)dataConversionInt:(NSData *)data
{
  NSData *data4 = [data subdataWithRange:NSMakeRange(0, 4)];
  int value = CFSwapInt32BigToHost(*(int *)([data4 bytes]));
  return value;
}

// 翻转字节序列代码
+ (NSData *)dataWithReverse:(NSData *)srcData
{
  NSUInteger byteCount = srcData.length;
  NSMutableData *dstData = [[NSMutableData alloc] initWithData:srcData];
  NSInteger halflenght = byteCount / 2;
  for (NSUInteger i = 0; i < halflenght; i++) {
    NSRange begin = NSMakeRange(i, 1);
    NSRange end = NSMakeRange(byteCount - i - 1, 1);
    NSData *beginData = [srcData subdataWithRange:begin];
    NSData *endData = [srcData subdataWithRange:end];
    [dstData replaceBytesInRange:begin withBytes:endData.bytes];
    [dstData replaceBytesInRange:end withBytes:beginData.bytes];
  }
  return dstData;
}

@end
