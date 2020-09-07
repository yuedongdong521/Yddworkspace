//
//  TextRollAnimationLabel.m
//  Yddworkspace
//
//  Created by ydd on 2020/3/23.
//  Copyright © 2020 QH. All rights reserved.
//

#import "TextRollAnimationLabel.h"
#import <CoreImage/CoreImage.h>

#define kTextRoll @"TextRoll"

@interface TextRollAnimationLabel ()<CAAnimationDelegate>

@property (nonatomic, assign) CGFloat contentWidth;

@property (nonatomic, copy) void(^finished)(BOOL flag);

@end

@implementation TextRollAnimationLabel

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
        [self addSubview:self.contentLabel];
        self.layer.masksToBounds = YES;
        _speed = 20;
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];

    }
    return self;
}


- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
    }
    return _contentLabel;
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.contentLabel.text = text;
    
     _contentWidth = [[[NSAttributedString alloc] initWithString:_text attributes:@{NSFontAttributeName:self.contentLabel.font}] boundingRectWithSize:CGSizeMake(1000, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    
}

- (void)appWillEnterForegroundNotification:(NSNotification *)notify
{
    if (_isAnimation) {
        [self stopAnimation];
        [self startAnimationFinished:_finished];
    }
    
}

- (void)startAnimationFinished:(void(^)(BOOL flag))finished
{
    if (_isAnimation) {
        return;
    }
    _finished = finished;
    _isAnimation = YES;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = _function ? _function : [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    animation.beginTime = CACurrentMediaTime() + _dealyTime;
    CGFloat durationTime = _duration > 0 ? _duration : _contentWidth / (_speed > 0 ? _speed : 20.0);
    animation.duration = durationTime;
    animation.keyTimes = @[@(0), @(_dealyTime / durationTime), @(durationTime/ durationTime)];
    animation.values = @[@(0), @(0), @(-_contentWidth)];
    animation.repeatCount = _repeatCount;
    animation.delegate = self;
    [self.contentLabel.layer addAnimation:animation forKey:@"textRoll"];
    
    
}

- (void)stopAnimation
{
    _isAnimation = NO;
    CAKeyframeAnimation *animation = [self.contentLabel.layer animationForKey:kTextRoll];
    if (animation) {
        [self.contentLabel.layer removeAnimationForKey:kTextRoll];
    }
    
}

- (void)destoryAnimation
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    [self stopAnimation];
    _finished = nil;
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"animation : %d", flag);
    if (flag) {
        _isAnimation = NO;
    }
    
    if (_finished) {
        _finished(flag);
    }
}

@end
