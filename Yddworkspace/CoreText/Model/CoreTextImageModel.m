//
//  CoreTextImageModel.m
//  Yddworkspace
//
//  Created by ydd on 2018/9/5.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "CoreTextImageModel.h"

@implementation CoreTextImageModel

- (instancetype)initWithImageName:(NSString *)name loaction:(NSInteger)location
{
  self = [super init];
  if (self) {
    UIImage *image = [UIImage imageNamed:name];
    _name = name;
    if (image) {
      CGFloat h = image.size.height;
      _height = h > KImageMinWidth ? h > KImageMaxHeight ? KImageMaxHeight : h : KImageMinWidth;
      _width = _height / image.size.height * image.size.width;
    }
    _imageFrame = CGRectZero;
    _location = location;
  }
  return self;
}


@end
