//
//  TestCollectionViewCell.h
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong)UIImageView *imageview;

- (void)setImageURL:(NSString *)urlStr;

@end
