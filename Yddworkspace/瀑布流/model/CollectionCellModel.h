//
//  CollectionCellModel.h
//  Yddworkspace
//
//  Created by ydd on 2018/5/19.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionCellModel : NSObject

@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, strong) NSString *title;

@end
