//
//  TestImageModel.m
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "TestImageModel.h"
#import "UIImage+ImageSizeWithURL.h"


@implementation TestImageModel

- (instancetype)initWithUrl:(NSString *)urlStr
{
  self = [super init];
  if (self) {
    _urlStr = urlStr;
    _size = CGSizeMake(ScreenWidth, ScreenWidth);
  }
  return self;
}



@end
