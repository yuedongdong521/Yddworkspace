//
//  KXBeautifulIdLabel.m
//  Yddworkspace
//
//  Created by ydd on 2020/9/7.
//  Copyright © 2020 QH. All rights reserved.
//

#import "KXBeautifulIdLabel.h"

@implementation KXBeautifulIdLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _bHeight = 30;
        [self addSubview:self.contentView];
        [self.contentView.layer addSublayer:self.gradientLayer];
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            make.width.equalTo(self.imageView.mas_height);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 5, 0, 0));
        }];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.imageView.mas_right).mas_offset(5);
            make.right.mas_equalTo(-10);
            make.top.bottom.mas_equalTo(0);
        }];
        
    }
    return self;
}

- (void)updateImageStr:(NSString *)imageStr beautId:(NSInteger)beautId
{
    if (!self.superview) {
        return;
    }

    self.imageView.image = [UIImage imageNamed:imageStr];
    self.label.text = [NSString stringWithFormat:@"%ld", (long)beautId];
    
    self.gradientLayer.colors = @[(id)[UIColor redColor].CGColor, (id)[UIColor greenColor].CGColor];
    
    [self.label sizeToFit];
    CGFloat w = _bHeight + 15 + self.label.bounds.size.width;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(w);
    }];
    
    
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.contentView.layer.cornerRadius = self.contentView.bounds.size.height * 0.5;
    self.gradientLayer.frame = self.contentView.bounds;
    [CATransaction commit];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.borderWidth = 1;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.borderColor = [UIColor colorWithRed:245.0 / 255 green:224.0 / 255 blue:163.0 / 255 alpha:1].CGColor;
    }
    return _contentView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentLeft;
        
        _label.font = UIFontPFMedium(16);
    }
    return _label;
}


- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        [_gradientLayer setStartPoint:CGPointMake(0.5, 0)];
        [_gradientLayer setEndPoint:CGPointMake(0.5, 1)];
        _gradientLayer.locations = @[@(0), @(1)];
    }
    return _gradientLayer;
}

@end
