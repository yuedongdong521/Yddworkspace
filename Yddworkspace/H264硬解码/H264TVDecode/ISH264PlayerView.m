//
//  ISH264PlayerView.m
//  ViewsTalk
//
//  Created by ispeak on 2018/1/17.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import "ISH264PlayerView.h"
#import "ISH264Player.h"
#import "Masonry.h"

@interface ISH264PlayerView ()

@property (nonatomic, strong) ISH264Player *player;
@property (nonatomic, assign) CGRect orignRect;
@property (nonatomic, strong) UIButton *fullButton;

@end

@implementation ISH264PlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _player = [[ISH264Player alloc] initWithFrame:self.bounds];
        _orignRect = frame;
        [self.layer addSublayer:_player];
    }
    return self;
}

- (UIButton *)fullButton
{
    if (!_fullButton) {
        _fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullButton setTitle:@"半屏" forState:UIControlStateNormal];
        [_fullButton addTarget:self action:@selector(fullButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_fullButton];
        [_fullButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(CGSizeMake(46, 46));
            make.left.mas_offset(10);
            make.bottom.mas_offset(-10);
        }];
        _fullButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
    }
    return _fullButton;
}

- (void)playForPixelBuffer:(CVPixelBufferRef)buffer
{
    [_player playerForPixelBuffer:buffer];
}

- (void)resetPlay
{
    [_player resetRenderBuffer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _player.frame = self.bounds;
}

- (void)changePlayerFrameForFullScreen:(BOOL)isFull
{
    if (isFull) {
        [UIView animateWithDuration:1.0 animations:^{
            self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            _player.transform = CATransform3DRotate(CATransform3DIdentity, M_PI_2, 0, 0, 1);
        }];
        self.fullButton.hidden = NO;
        
    } else {
        [UIView animateWithDuration:1.0 animations:^{
            self.frame = _orignRect;
            _player.transform = CATransform3DRotate(CATransform3DIdentity, 0, 0, 0, 1);
        }];
        self.fullButton.hidden = YES;
    }
}

- (void)fullButtonAction:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(quiteFullScreen)]) {
        [_delegate quiteFullScreen];
    }
}

@end
