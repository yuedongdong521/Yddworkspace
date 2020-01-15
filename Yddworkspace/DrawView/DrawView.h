//
//  DrawView.h
//  Yddworkspace
//
//  Created by ydd on 2020/1/15.
//  Copyright © 2020 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DrawType_line = 0,
    DrawType_text,
    DrawType_box,
    DrawType_box_border,
    DrawType_box_bgColor,
    DrawType_ellipse,
    DrawType_arc,
    DrawType_gradient,
    DrawType_addLine,
    DrawType_fillEllipse,
    DrawType_prism,
    DrawType_fillColorPrism,
    DrawType_fillBorder,
    DrawType_bezier,
    DrawType_bezier2,
    DrawType_dottedline,
    DrawType_image,
    DrawType_image1,
    DrawType_image2,
    DrawType_image3,
    
} DrawType;

NS_ASSUME_NONNULL_BEGIN

@interface DrawView : UIView

@property (nonatomic, assign) DrawType type;

@end

NS_ASSUME_NONNULL_END
