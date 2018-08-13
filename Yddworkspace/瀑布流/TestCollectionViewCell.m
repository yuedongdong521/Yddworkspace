//
//  TestCollectionViewCell.m
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "TestCollectionViewCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@implementation TestCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self addSubview:self.imageview];
  }
  return self;
}


- (UIImageView *)imageview
{
  if (!_imageview) {
    _imageview = [[UIImageView alloc] init];
    _imageview.contentMode = UIViewContentModeScaleAspectFill;
    _imageview.clipsToBounds = YES;
    [self addSubview:_imageview];
    [_imageview mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
  }
  return _imageview;
  
}

- (void)setImageURL:(NSString *)urlStr
{
  [self.imageview sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"1yasuo.jpg"]];
}




@end
