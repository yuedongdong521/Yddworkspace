//
//  ISAlbumListTableViewCell.m
//  iShow
//
//  Created by admin on 2017/5/18.
//
//

#import "ISAlbumListTableViewCell.h"

@implementation ISAlbumListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString*)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    [self createUI];
  }
  return self;
}

- (void)createUI {
  self.albumImageView =
      [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 70, 70)];
  self.albumImageView.image =
      [UIImage imageNamed:@"ImgDownSucceedSessionIcono@2x"];
  [self.contentView addSubview:self.albumImageView];

  self.albumNameLable =
      [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 180, 30)];
  [self.contentView addSubview:self.albumNameLable];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
