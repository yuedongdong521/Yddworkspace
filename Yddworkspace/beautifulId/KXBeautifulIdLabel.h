//
//  KXBeautifulIdLabel.h
//  Yddworkspace
//
//  Created by ydd on 2020/9/7.
//  Copyright © 2020 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KXBeautifulIdLabel : UIView


@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, assign) CGFloat bHeight;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

//@property (nonatomic, strong, readonly) NSString *beautifullId;

- (void)updateImageStr:(NSString *)imageStr beautId:(NSInteger)beautId;


@end

NS_ASSUME_NONNULL_END
