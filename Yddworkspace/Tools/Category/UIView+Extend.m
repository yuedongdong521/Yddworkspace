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

- (void)transformToSacleFrame:(CGRect)sacleFrame
                     duration:(CGFloat)duration
                      options:(UIViewAnimationOptions)options
                    animation:(BOOL)animation
                   completion:(void(^)(BOOL finished))completion;
{
    CGRect orignFrame = self.frame;
    CGFloat rateW = sacleFrame.size.width / orignFrame.size.width;
    CGFloat rateH = sacleFrame.size.height / orignFrame.size.height;
    CGFloat offsetX = sacleFrame.origin.x + sacleFrame.size.width * 0.5 - (orignFrame.origin.x + orignFrame.size.width * 0.5);
    CGFloat offsetY = sacleFrame.origin.y + sacleFrame.size.height * 0.5 - (orignFrame.origin.y + orignFrame.size.height * 0.5);
    if (!animation) {
        self.transform = CGAffineTransformMake(rateW, 0, 0, rateH, offsetX, offsetY);
        return;
    }
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.transform = CGAffineTransformMake(rateW, 0, 0, rateH, offsetX, offsetY);
    } completion:completion];
}

- (CGAffineTransform)transformFrame:(CGRect)frame
{
    CGRect orignFrame = self.frame;
    CGFloat a = frame.size.width / orignFrame.size.width;
    CGFloat d = frame.size.height / orignFrame.size.height;
    
    CGFloat offsetX = CGRectGetMidX(frame) - CGRectGetMidX(orignFrame);
    CGFloat offsetY = CGRectGetMidY(frame) - CGRectGetMidY(orignFrame);
    
    return CGAffineTransformMake(a, 0, 0, d, offsetX, offsetY);
}


- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    CGPoint oldOrigin = self.frame.origin;
    self.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = self.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    self.center = CGPointMake (self.center.x - transition.x, self.center.y - transition.y);
}

- (void)setDefaultAnchorPoint
{
    [self setAnchorPoint:CGPointMake(0.5f, 0.5f)];
}

- (UIViewController *)superViewController
{
    UIResponder *responder = self.nextResponder;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = responder.nextResponder;
    }
    
    return (UIViewController *)responder;
}


- (void)addMaskLayerImage:(UIImage *)image
{
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.contents = (__bridge id)[image CGImage];
//    maskLayer.contentsRect = CGRectMake(0, 0, 1, 1);
    maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
    self.layer.mask = maskLayer;
}

@end
