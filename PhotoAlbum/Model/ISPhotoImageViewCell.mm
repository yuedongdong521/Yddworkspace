//
//  ISPhotoImageViewCell.m
//  iShow
//
//  Created by admin on 2017/5/22.
//
//

#import "ISPhotoImageViewCell.h"

@implementation ISPhotoImageViewCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (UIImageView*)photoImageView {
  if (!_photoImageView) {
    _photoImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _photoImageView.image = [UIImage imageNamed:@"ImgDownSucceedIconHD@2x"];
    _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_photoImageView];
  }
  return _photoImageView;
}

@end
