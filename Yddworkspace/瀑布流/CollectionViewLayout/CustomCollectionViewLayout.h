//
//  CustomCollectionViewLayout.h
//  Yddworkspace
//
//  Created by ydd on 2018/5/21.
//  Copyright © 2018年 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COLUMNCOUNT 3

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width

#define INTERITEMSPACING 10.0f

#define LINESPACING 10.0f

#define ITEMWIDTH (SCREENWIDTH - (COLUMNCOUNT - 1)*INTERITEMSPACING) / 3



@interface CustomCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) NSMutableDictionary * attributes;

@property (nonatomic, strong) NSMutableArray * colArray;

@end
