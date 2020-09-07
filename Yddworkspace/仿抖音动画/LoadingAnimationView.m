//
//  LoadingAnimationView.m
//  Yddworkspace
//
//  Created by ydd on 2020/7/13.
//  Copyright © 2020 QH. All rights reserved.
//

#import "LoadingAnimationView.h"

@interface LoadingAnimationView ()

@property (nonatomic, strong) UIView *leftView;

@property (nonatomic, strong) UIView *rightView;

@end

@implementation LoadingAnimationView

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
        [self addSubview:self.leftView];
        [self addSubview:self.rightView];
        
        
        [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(10);
            make.centerY.equalTo(self);
            make.centerX.equalTo(self).mas_offset(-5);
        }];
        
        [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(10);
            make.centerY.equalTo(self);
            make.centerX.equalTo(self).mas_offset(5);
        }];
    }
    return self;
}

- (void)startAnimation
{
    
}

- (UIView *)leftView
{
    if (!_leftView) {
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [UIColor colorWithRed:45 / 255.0 green:245 / 255.0 blue:237 / 255.0 alpha:1];
        _leftView.layer.cornerRadius = 5;
        _leftView.layer.masksToBounds = YES;
    }
    return _leftView;
}

- (UIView *)rightView
{
    if (!_rightView) {
        _rightView = [[UIView alloc] init];
        _rightView.backgroundColor = [UIColor colorWithRed:250 / 255.0 green:9 / 255.0 blue:70 / 255.0 alpha:1];
        _rightView.layer.cornerRadius = 5;
        _rightView.layer.masksToBounds = YES;
    }
    return _rightView;
}


@end
