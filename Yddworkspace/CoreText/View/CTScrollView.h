//
//  CTScrollView.h
//  Yddworkspace
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/Coretext.h>
#import "CTModel.h"

@interface CTScrollView : UIScrollView

@property (nonatomic , assign) int imageIndex;

- (void)buildFramesAttrString:(NSAttributedString *)attrString AndImages:(NSArray *)images;
@end
