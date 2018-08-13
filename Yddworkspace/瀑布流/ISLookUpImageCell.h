//
//  ISLookUpImageCell.h
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TestImageModel;

@protocol ISLookUpImageCellDelegate <NSObject>

- (void)releaseLookUpViewDelegate;

@end

@interface ISLookUpImageCell : UICollectionViewCell

@property(nonatomic, strong) TestImageModel *imageModel;

@property(nonatomic, weak) id<ISLookUpImageCellDelegate> delegate;

- (void)resetImageZoomScale;


@end
