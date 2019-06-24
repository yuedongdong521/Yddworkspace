//
//  CustomXibView.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/12.
//  Copyright © 2019 QH. All rights reserved.
//

#import "CustomXibView.h"

@interface CustomXibView ()

@property (weak, nonatomic) IBOutlet UIButton *topBtn;


@end

@implementation CustomXibView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)backAction:(id)sender {
    
    NSLog(@"customView clicked");
    
}


- (instancetype)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"customXibView" owner:nil options:nil].lastObject;
    if (self) {
        
    }
    return self;
}


@end
