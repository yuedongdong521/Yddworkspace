//
//  CustomPopAnimateViewController.h
//  Yddworkspace
//
//  Created by ispeak on 2018/1/22.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomPopAnimateViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic, strong) UIImage *image;

@property(nonatomic,strong)UIPercentDrivenInteractiveTransition *interactiveTransition;

@end
