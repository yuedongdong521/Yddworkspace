//
//  AlphaFrameFilter.h
//  Yddworkspace
//
//  Created by ydd on 2020/3/24.
//  Copyright © 2020 QH. All rights reserved.
//

#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlphaFrameFilter : CIFilter

@property (nonatomic, strong) CIImage *inputImage;
@property (nonatomic, strong) CIImage *maskImage;

@end

NS_ASSUME_NONNULL_END
