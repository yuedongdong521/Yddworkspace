//
//  CTColumnView.h
//  Yddworkspace
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface CTColumnView : UIView

@property (nonatomic, assign) CTFrameRef ctFrame;
@property (nonatomic, strong) NSMutableArray *images;
- (instancetype)initWithFrame:(CGRect)frame andCTFrame:(CTFrameRef)ctFrame;
@end
