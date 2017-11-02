//
//  LinkMicReminderView.m
//  ViewsTalk
//
//  Created by ispeak on 2017/7/20.
//  Copyright © 2017年 ywx. All rights reserved.
//

#import "LinkMicReminderView.h"

@interface LinkMicReminderView ()

@property (nonatomic, assign) int timeNum;

@end

@implementation LinkMicReminderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithTitle:(NSString *)title ContentStr:(NSString *)contentStr
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"LinkMicReminderView" owner:self options:nil] lastObject];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        self.frame = [UIScreen mainScreen].bounds;
        self.reminderView.layer.cornerRadius = 15;
        self.reminderView.layer.masksToBounds = YES;
        self.reminderView.layer.shadowColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        self.titleLabel.text = title;
        self.contentLabel.text = contentStr;
        self.timeNum = 10;
        self.hidden = YES;
        self.cancelBtn.layer.borderWidth = 0.5;
        self.cancelBtn.layer.borderColor = [UIColor grayColor].CGColor;
        self.agreeLabel.layer.borderWidth = 0.5;
        self.agreeLabel.layer.borderColor = [UIColor grayColor].CGColor;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    return self;
}

- (void)startTimer
{
    self.timeNum = 10;
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
        [_timer fire];
    }
}

- (void)timerAction:(NSTimer *)timer
{
    if (self.timeNum >= 0) {
        NSString *str = [NSString stringWithFormat:@"同意(%ds)", self.timeNum];
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:str];
        NSRange range = [str rangeOfString:@")"];
        if (range.location != NSNotFound) {
            if (range.location - 3 > 0) {
                NSRange range1 = NSMakeRange(3, range.location - 3);
                [att addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range1];
            }
        }
        self.agreeLabel.attributedText = att;
    } else {
        [self userResult:NO];
    }
     self.timeNum--;
}

- (void)invalidateTimer
{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}

- (IBAction)agreedAction:(id)sender {
    [self userResult:YES];
}
- (IBAction)cancelAction:(id)sender {
    [self userResult:NO];
}

- (void)userResult:(BOOL)isAgreed
{
    if ([_delegate respondsToSelector:@selector(agreedLinkMicRequset:)]) {
        [_delegate agreedLinkMicRequset:isAgreed];
    }
    [self invalidateTimer];
    [self hiddenRemindView:YES];
}

- (void)hiddenRemindView:(BOOL)hidden
{
    if (hidden) {
        self.reminderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        [UIView animateWithDuration:0.3 animations:^{
            self.reminderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    } else {
        self.hidden = NO;
        self.reminderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0);
        [UIView animateWithDuration:0.3 animations:^{
            self.reminderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        } completion:^(BOOL finished) {
            [self startTimer];
        }];
    }
}

@end
