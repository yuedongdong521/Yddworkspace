//
//  ISPhotoAlbumViewCell.m
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import "ISPhotoAlbumViewCell.h"
#import "ISPhotoAlbumModel.h"
#import "ISAssetsManager.h"

@implementation ISPhotoAlbumViewCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (UIImageView*)photoImageView {
  if (!_photoImageView) {
    _photoImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _photoImageView.image = [UIImage imageNamed:kImgDownSucceedIconHD];
    [self addSubview:_photoImageView];
  }
  return _photoImageView;
}

- (UIButton*)chooseBut {
  if (!_chooseBut) {
    _chooseBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chooseBut setFrame:CGRectMake(self.frame.size.width - 34, 4, 30, 30)];
    [_chooseBut setImage:[UIImage imageNamed:KYselect_no]
                forState:UIControlStateNormal];
    [_chooseBut setImage:[UIImage imageNamed:KYselect_yes]
                forState:UIControlStateSelected];
    [_chooseBut addTarget:self
                   action:@selector(chooseButton:)
         forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_chooseBut];
  }
  return _chooseBut;
}

- (void)chooseButton:(UIButton*)chooseBt {
  if ([self.delegate respondsToSelector:@selector(chooseNo:)]) {
    [self.delegate chooseNo:chooseBt];
  }
}

@end
