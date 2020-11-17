//
//  ProgressAnimationView.m
//  Yddworkspace
//
//  Created by ydd on 2020/11/12.
//  Copyright © 2020 QH. All rights reserved.
//

#import "ProgressAnimationView.h"

@interface ArrowView : UIView

@property (nonatomic, strong) CAShapeLayer *leftLayer;

@property (nonatomic, strong) CAShapeLayer *rightLayer;

@property (nonatomic, assign) CGFloat progress;

@end

@implementation ArrowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self.layer addSublayer:self.leftLayer];
        [self.layer addSublayer:self.rightLayer];
        
        self.leftLayer.hidden = YES;
        self.rightLayer.hidden = YES;
        
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (_progress > 0.5) {
        self.leftLayer.hidden = NO;
        self.rightLayer.hidden = YES;
    } else if (_progress < 0.5) {
        self.leftLayer.hidden = YES;
        self.rightLayer.hidden = NO;
    } else {
        self.leftLayer.hidden = YES;
        self.rightLayer.hidden = YES;
    }
}



- (CAShapeLayer *)leftLayer
{
    if (!_leftLayer) {
        _leftLayer = [[CAShapeLayer alloc] init];
        
        CGFloat w = self.bounds.size.width * 0.5;
        CGFloat h = self.bounds.size.height;
        
        _leftLayer.frame = CGRectMake(0, 0, w, h);
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(w - h * 0.5, 0)];
        [path addLineToPoint:CGPointMake(w, h * 0.5)];
        [path addLineToPoint:CGPointMake(w - h * 0.5, h)];
        [path addLineToPoint:CGPointMake(0, h)];
        [path closePath];
        _leftLayer.path = path.CGPath;
        _leftLayer.fillColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        _leftLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    return _leftLayer;
}

- (CAShapeLayer *)rightLayer
{
    if (!_rightLayer) {
        _rightLayer = [[CAShapeLayer alloc] init];
        CGFloat w = self.bounds.size.width;
        CGFloat h = self.bounds.size.height;
        
        _rightLayer.frame = CGRectMake(0, 0, w, h);
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(w, 0)];
        [path addLineToPoint:CGPointMake(w * 0.5 + h * 0.5, 0)];
        [path addLineToPoint:CGPointMake(w * 0.5, h * 0.5)];
        [path addLineToPoint:CGPointMake(w * 0.5 + h * 0.5, h)];
        [path addLineToPoint:CGPointMake(w, h)];
        [path closePath];
        _rightLayer.path = path.CGPath;
        _rightLayer.fillColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        _rightLayer.strokeColor = [UIColor clearColor].CGColor;
    }
    return _rightLayer;
}


@end

@interface ProgressAnimationView ()

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UILabel *leftLabel;

@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UILabel *rightLabel;

@property (nonatomic, strong) ArrowView *arrowView;

@property (nonatomic, strong) UIView *midLineView;


@end

@implementation ProgressAnimationView

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
        [self addSubview:self.rightLabel];
        [self addSubview:self.rightView];
        
        [self addSubview:self.leftLabel];
        [self addSubview:self.leftView];
        
        [self addSubview:self.midLineView];
        
        
        CGFloat w = ScreenWidth - 40 - 120;
        
        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(60);
        }];
        
        [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(60);
        }];
        
        [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.leftLabel.mas_right);
            make.top.bottom.mas_equalTo(0);
            make.right.mas_equalTo(self.rightLabel.mas_left);
        }];
        
        [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(self.leftLabel.mas_right);
            make.width.mas_equalTo(w * 0.5);
        }];
        
        
        [self addSubview:self.arrowView];
        [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.leftView.mas_right);
            make.centerY.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(80, 30));
        }];
        
        [self.midLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(1);
            make.centerX.equalTo(self);
        }];
        
    }
    return self;
}

- (void)updateWithLeft:(NSInteger)left right:(NSInteger)right
{
    CGFloat sum = (CGFloat)(left + right);
    CGFloat progress = 0;
    if (sum <= 0) {
        progress = 0.5;
    } else {
        progress = left / sum;
    }
    
    self.arrowView.progress = progress;
    
    CGFloat w = (ScreenWidth - 40 - 120) * progress;
    
    self.leftLabel.text = [NSString stringWithFormat:@"%ld", (long)left];
    self.rightLabel.text = [NSString stringWithFormat:@"%ld", (long)right];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.leftView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(w);
        }];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!finished) {
            [self.leftView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(w);
            }];
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    }];
    
}

- (UILabel *)leftLabel
{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.text = @"0";
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.backgroundColor = [UIColor redColor];
    }
    return _leftLabel;
}

- (UIView *)leftView
{
    if (!_leftView) {
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [UIColor redColor];
    }
    return _leftView;
}

- (UILabel *)rightLabel
{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.text = @"0";
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.backgroundColor = [UIColor blueColor];
    }
    return _rightLabel;
}

- (UIView *)rightView
{
    if (!_rightView) {
        _rightView = [[UIView alloc] init];
        _rightView.backgroundColor = [UIColor blueColor];
    }
    return _rightView;
}

- (ArrowView *)arrowView
{
    if (!_arrowView) {
        _arrowView = [[ArrowView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    }
    return _arrowView;
}

- (UIView *)midLineView
{
    if (!_midLineView) {
        _midLineView = [[UIView alloc] init];
        _midLineView.backgroundColor = [UIColor greenColor];
    }
    return _midLineView;
}

@end
