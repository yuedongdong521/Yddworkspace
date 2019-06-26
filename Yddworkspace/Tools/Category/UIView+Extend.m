//
//  UIView+Extend.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/26.
//  Copyright © 2019 QH. All rights reserved.
//

#import "UIView+Extend.h"
#import <objc/runtime.h>

static void *BtnResponsEdgeKey = &"BtnResponsEdgeKey";

@implementation UIView (Extend)


- (void)setResponsEdge:(UIEdgeInsets)edge
{
    objc_setAssociatedObject(self, BtnResponsEdgeKey, NSStringFromUIEdgeInsets(edge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)respondEdge
{
   NSString * edgeStr = objc_getAssociatedObject(self, BtnResponsEdgeKey);
    if ([edgeStr isKindOfClass:NSString.class]) {
        return  UIEdgeInsetsFromString(edgeStr);
    }
    return UIEdgeInsetsZero;
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    UIEdgeInsets respondEdge = [self respondEdge];
    CGRect respondRect = self.bounds;
    if (!UIEdgeInsetsEqualToEdgeInsets(respondEdge, UIEdgeInsetsZero)) {
        respondRect =  UIEdgeInsetsInsetRect(respondRect, respondEdge);
    }
    
    if (CGRectContainsPoint(respondRect, point)) {
        return YES;
    }
    return  NO;
}







@end
