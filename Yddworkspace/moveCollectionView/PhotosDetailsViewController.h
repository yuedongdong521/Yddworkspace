//
//  PhotosDetailsViewController.h
//  Yddworkspace
//
//  Created by ydd on 2019/7/24.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTransitionViewController.h"

@class PhotoGroupItem;
NS_ASSUME_NONNULL_BEGIN

@interface PhotosDetailsViewController : CustomTransitionViewController

@property (nonatomic, strong) NSURL *imageUrl;

@end

NS_ASSUME_NONNULL_END
