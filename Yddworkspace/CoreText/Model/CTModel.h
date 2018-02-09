//
//  CTModel.h
//  Yddworkspace
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTModel : NSObject

@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat columnsPerPage;
@property (nonatomic, assign) CGRect pageRect;
@property (nonatomic, assign) CGRect columnRect;
- (instancetype)initWithViewSize:(CGSize)size;
@end
