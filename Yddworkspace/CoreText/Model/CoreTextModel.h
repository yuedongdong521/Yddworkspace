//
//  CoreTextModel.h
//  Yddworkspace
//
//  Created by ydd on 2018/9/5.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "CoreTextImageModel.h"

@interface CoreTextModel : NSObject
{
  CTFrameRef _frameRef;
}

@property(nonatomic, strong) NSMutableArray *imageArr;
@property(nonatomic, assign) CGFloat contentMaxWidth;
@property(nonatomic, assign, readonly) CGFloat contentHeight;

- (instancetype)initWithContentStr:(NSString *)contentStr contentMaxWidth:(CGFloat)width;

- (CTFrameRef)getFrameRef;

@end
