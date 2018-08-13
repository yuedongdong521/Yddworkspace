//
//  ISLookUpImageView.h
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISLookUpImageView : UIView

@property(nonatomic, copy) void (^tapBlock)();

- (instancetype)initWithFrame:(CGRect)frame scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

- (void)reloadWithImageList:(NSArray *)imageList currentIndex:(NSInteger)index;

@end
