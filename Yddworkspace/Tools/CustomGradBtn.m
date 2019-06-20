//
//  CustomGaridBtn.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/17.
//  Copyright © 2019 QH. All rights reserved.
//

#import "CustomGaridBtn.h"

@interface CustomGaridBtn ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation CustomGaridBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    CustomGaridBtn *button = [super buttonWithType:buttonType];
    if (button) {
        
    }
    return button;
}


@end
