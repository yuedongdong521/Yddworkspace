//
//  KXProvisionView.h
//  Yddworkspace
//
//  Created by ydd on 2019/12/19.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KXProvisionModel : NSObject

@property (nonatomic, copy) NSString *frontStr;

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, copy) NSString *urlStr;

@property (nonatomic, copy) NSString *laterStr;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *color;

@end

@interface KXProvisionView : UIView

@property (nonatomic, strong) NSArray <KXProvisionModel *>*urlArray;


@end

NS_ASSUME_NONNULL_END
