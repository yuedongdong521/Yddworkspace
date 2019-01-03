//
//  ISPlayerLoadingView.m
//  ViewsTalk
//
//  Created by ydd on 2018/9/4.
//  Copyright © 2018年 ywx. All rights reserved.
//

#import "ISPlayerLoadingView.h"


@interface ISPlayerLoadingView ()

@property(nonatomic, strong) UIActivityIndicatorView* loadView;
@property(nonatomic, strong) UILabel* label;
@property(nonatomic, strong) UIView* bgView;
@property(nonatomic, strong) UIImageView* bgImageView;

@end

@implementation ISPlayerLoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self addSubview:self.bgImageView];
    [self addSubview:self.bgView];
    [self addSubview:self.label];
    [self addSubview:self.loadView];
    [self loyoutUI];
  }
  return self;
}

- (void)startLoading:(NSString*)tipStr {
  if (self.label.hidden) {
    self.label.hidden = NO;
  }
  self.label.text = tipStr;
  if (!self.loadView.isAnimating) {
    [self.loadView startAnimating];
  }
}

- (void)stopLoading {
  if (!self.label.hidden) {
    self.label.hidden = YES;
  }
  if (self.loadView.isAnimating) {
    [self.loadView stopAnimating];
  }
}

- (void)loyoutUI {
  [_bgImageView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];

  [_bgView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];

  [_loadView mas_makeConstraints:^(MASConstraintMaker* make) {
    make.size.mas_equalTo(CGSizeMake(32, 32));
    make.centerX.mas_equalTo(self.mas_centerX);
    make.bottom.mas_equalTo(self.mas_centerY);
  }];

  [_label mas_makeConstraints:^(MASConstraintMaker* make) {
    make.left.mas_equalTo(10);
    make.right.mas_equalTo(-10);
    make.top.mas_equalTo(self.mas_centerY);
  }];
}

- (UIView*)bgView {
  if (!_bgView) {
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
  }
  return _bgView;
}

- (UILabel*)label {
  if (!_label) {
    _label = [[UILabel alloc] init];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont systemFontOfSize:15];
    _label.numberOfLines = 0;
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
  }
  return _label;
}

- (UIActivityIndicatorView*)loadView {
  if (!_loadView) {
    _loadView = [[UIActivityIndicatorView alloc] init];
    [_loadView
        setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadView.hidesWhenStopped = YES;
  }
  return _loadView;
}

- (UIImageView*)bgImageView {
  if (!_bgImageView) {
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImage* image = [[UIImage alloc]
        initWithContentsOfFile:[[NSBundle mainBundle]
                                   pathForResource:@"0"
                                            ofType:@"jpg"]];

    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _bgImageView.image = image;
    _bgImageView.clipsToBounds = YES;
  }
  return _bgImageView;
}

@end
