//
//  CustomGradBtn.h
//  Yddworkspace
//
//  Created by ydd on 2019/6/17.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface GradLayerModel : NSObject

@property (nullable, nonatomic, copy, readonly) NSArray *colors;
@property (nullable, nonatomic, copy) NSArray <NSNumber *>* locations;

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
/**
 kCAGradientLayerAxial default,
 kCAGradientLayerRadial,
 kCAGradientLayerConic
 */
@property (nullable, nonatomic, copy) CAGradientLayerType type;

- (void)setGradColors:(NSArray <UIColor*>*)colors;

@end

@interface CustomGradBtn : UIButton

@property (nonatomic, assign) BOOL gradLayerSelected;

- (void)setGradModel:(nullable GradLayerModel *)model gradState:(BOOL)state;

@end

NS_ASSUME_NONNULL_END
