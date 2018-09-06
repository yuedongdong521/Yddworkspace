//
//  CoreTextTestView.h
//  Yddworkspace
//
//  Created by ydd on 2018/9/6.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CoreTextImageModel.h"

@interface CoreTextTestView : UIView
{
  CTFrameRef _frameRef;
}

@property (nonatomic, strong) NSArray *imageArr;

-(instancetype)initWithFrame:(CGRect)frame;
- (void)setFrameRef:(CTFrameRef)frameRef;
@end
