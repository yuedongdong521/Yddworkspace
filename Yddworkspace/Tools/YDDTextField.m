//
//  YDDTextField.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/18.
//  Copyright © 2019 QH. All rights reserved.
//

#import "YDDTextField.h"
#import "YDDUtils.h"

@interface YDDTextField ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation YDDTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (UILabel *)placeholdLabel
{
    if (!_placeholdLabel) {
        _placeholdLabel = [[UILabel alloc] init];
        [self addSubview:_placeholdLabel];
        [_placeholdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _placeholdLabel;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        [self addSubview:_textField];
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _textField;
}


- (void)textFieldTextChange:(UITextField *)textField
{
    NSInteger kMaxLength = 12;
    NSString *toBeString = textField.text;
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { // 中文输入
        UITextRange *selectedRange = [textField markedTextRange];
        // 获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
      
            }
        }
    }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //表情限制
    if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
        return NO;
    }
    
    if (![YDDUtils isNineKeyBoard:string]){
        if ([YDDUtils hasThreadEmoji:string] || [YDDUtils hasSysEmoji:string]) {
            return NO;
        }
    }
    
    //特殊字符和空格限制
    if ([YDDUtils isInputRuleNotBlank:string] || [string isEqualToString:@""]) {
        [self textFieldWillChangeStr:string];
        return YES;
    } else {
        return NO;
    }
}

- (void)textFieldWillChangeStr:(NSString *)str
{
    if (str.length > 0) {
        _placeholdLabel.hidden = YES;
    } else {
        if (_textField.text.length > 1) {
            _placeholdLabel.hidden = NO;
        } else {
            _placeholdLabel.hidden = YES;
        }
    }
}


@end
