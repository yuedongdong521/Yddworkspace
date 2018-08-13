//
//  CollectionDataModel.h
//  Yddworkspace
//
//  Created by ydd on 2018/5/19.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionCellModel.h"

@interface CollectionDataModel : NSObject

@property (nonatomic, strong) NSMutableArray <CollectionCellModel*> *cellModelArray;
@property (nonatomic, strong) CollectionCellModel *headerModel;
@property (nonatomic, strong) CollectionCellModel *footerModel;
@property (nonatomic, strong) CollectionCellModel *decorationModel;

@end
