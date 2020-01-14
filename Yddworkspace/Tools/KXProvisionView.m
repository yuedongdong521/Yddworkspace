//
//  KXProvisionView.m
//  Yddworkspace
//
//  Created by ydd on 2019/12/19.
//  Copyright © 2019 QH. All rights reserved.
//

#import "KXProvisionView.h"

@implementation KXProvisionModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frontStr = @"";
        _titleStr = @"";
        _urlStr = @"";
        _laterStr = @"";
        _font = [UIFont systemFontOfSize:17];
        _color = [UIColor blackColor];
    }
    return self;
}


@end


@interface KXProvisionView ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIButton *choseBtn;

@end

@implementation KXProvisionView

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
        [self addSubview:self.choseBtn];
        [self addSubview:self.textView];
        
        
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.mas_equalTo(0);
            make.left.mas_equalTo(self.choseBtn.mas_right).mas_offset(5);
            make.height.mas_equalTo(self.choseBtn.mas_height);
        }];
    }
    return self;
}

- (void)setUrlArray:(NSArray<KXProvisionModel *> *)urlArray
{
    _urlArray = urlArray;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSMutableAttributedString *mutAtt = [[NSMutableAttributedString alloc] init];
    [self.urlArray enumerateObjectsUsingBlock:^(KXProvisionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = @{NSFontAttributeName : obj.font,
                              NSForegroundColorAttributeName : obj.color
        };
        if (obj.frontStr.length > 0) {
            [mutAtt appendAttributedString:[[NSAttributedString alloc] initWithString:obj.frontStr attributes:dic]];
        }
        if (obj.titleStr.length > 0 && obj.urlStr.length > 0) {
            NSMutableDictionary *urlDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [urlDic setObject:obj.urlStr forKey:NSLinkAttributeName];
            [mutAtt appendAttributedString:[[NSAttributedString alloc] initWithString:obj.titleStr attributes:urlDic]];
        }
        if (obj.laterStr.length > 0) {
            [mutAtt appendAttributedString:[[NSAttributedString alloc] initWithString:obj.laterStr attributes:dic]];
        }
    }];
    CGFloat width = self.textView.bounds.size.width;
    CGFloat h = [mutAtt boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(h);
    }];
    
    
}




- (void)choseBtnAction:(UIButton *)btn
{
    
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([[URL scheme] isEqualToString:@"protocol"]) {
//        if (self.privacyBlock) {
//            self.privacyBlock(NO);
//        }
        return NO;
    }
    
    if ([[URL scheme] isEqualToString:@"privacy"]) {
//        if (self.privacyBlock) {
//            self.privacyBlock(YES);
//        }
        return NO;
    }
    
    return YES;
}


- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.editable = NO;
        _textView.scrollEnabled = NO;
//        _textView.font = kFont_13;
//        _textView.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#FB1554"]};
        for (UIGestureRecognizer *ges in _textView.gestureRecognizers) {
            NSLog(@" app privacy : %@", NSStringFromClass([ges class]));
            if (![ges isMemberOfClass:[UITapGestureRecognizer class]]) {
                [_textView removeGestureRecognizer:ges];
            } else {
                NSLog(@" app privacy tap : %@", NSStringFromClass([ges class]));
            }
        }
        
    }
    return _textView;
}

- (UIButton *)choseBtn
{
    if (!_choseBtn) {
        _choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_choseBtn addTarget:self action:@selector(choseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _choseBtn;
}


@end
