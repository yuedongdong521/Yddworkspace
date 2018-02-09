//
//  MyCoreTextView.h
//  Yddworkspace
//
//  Created by ispeak on 2017/12/1.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface MyCoreTextView : UIView
{
    CTFrameRef _frameRef;
}

@property (nonatomic, strong) NSArray *images;

- (instancetype)initWithFrame:(CGRect)frame WithCTFrame:(CTFrameRef)frameRef;

@end
