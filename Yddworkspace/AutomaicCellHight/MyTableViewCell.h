//
//  MyTableViewCell.h
//  Yddworkspace
//
//  Created by ispeak on 16/10/18.
//  Copyright © 2016年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTableViewModel.h"

@protocol MyTableViewDelegate <NSObject>

- (void)myTabelViewDelegateLeaveMessage:(MyTableViewModel *)myModel ForPlaceholderStr:(NSString *)str;

@end

@interface MyTableViewCell : UITableViewCell

@property (nonatomic, retain)MyTableViewModel *myTableViewModel;

@property (nonatomic, weak) id<MyTableViewDelegate>delegate;


@end
