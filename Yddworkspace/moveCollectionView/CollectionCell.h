//
//  CollectionCell.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/3.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSIndexPath *indexPath;


@end


NS_ASSUME_NONNULL_END
