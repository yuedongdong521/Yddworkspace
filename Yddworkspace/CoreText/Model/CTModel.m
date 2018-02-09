//
//  CTModel.m
//  Yddworkspace
//
//  Created by ispeak on 2017/11/24.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "CTModel.h"

@implementation CTModel

- (instancetype)initWithViewSize:(CGSize)size
{
    self = [super init];
    if (self) {
        _margin = 20;
        _columnsPerPage = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 1 : 2;
        _pageRect = CGRectMake(_margin, _margin, size.width - _margin * 2,size.height - _margin * 2); //每页大小
        _columnRect = CGRectMake(_margin, _margin, _pageRect.size.width / _columnsPerPage - _margin * 2, _pageRect.size.height - _margin * 2);//每个内容大小
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"CTModel dealloc");
}

@end
