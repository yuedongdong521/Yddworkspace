//
//  LinkMicReminderView.h
//  ViewsTalk
//
//  Created by ispeak on 2017/7/20.
//  Copyright © 2017年 ywx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LinkMicReminderViewDelegate <NSObject>

- (void)agreedLinkMicRequset:(BOOL)isAgreed;

@end

@interface LinkMicReminderView : UIView
@property (weak, nonatomic) IBOutlet UIView *reminderView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *agreeLabel;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) id<LinkMicReminderViewDelegate>delegate;

- (instancetype)initWithTitle:(NSString *)title ContentStr:(NSString *)contentStr;
- (void)hiddenRemindView:(BOOL)hidden;
@end
