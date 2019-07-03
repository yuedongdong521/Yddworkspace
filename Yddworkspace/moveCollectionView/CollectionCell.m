//
//  CollectionCell.m
//  Yddworkspace
//
//  Created by ydd on 2019/7/3.
//  Copyright © 2019 QH. All rights reserved.
//

#import "CollectionCell.h"


@implementation CollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        //        [self addSubview:self.label];
        //        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.edges.mas_equalTo(UIEdgeInsetsZero);
        //        }];
        
        
    }
    return self;
}


- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}


- (void)dealloc
{
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
}

@end
