//
//  LoadPickerImageTool.h
//  Yddworkspace
//
//  Created by ydd on 2018/12/6.
//  Copyright © 2018 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PickerImageModel : NSObject

@property (nonatomic, strong) NSArray<UIImage *>*imageList;
@property (nonatomic, strong) NSString *groupName;

@end

@interface LoadPickerImageTool : NSObject

+ (void)loadPhotosAssetSuccess:(void(^)(NSArray *images))successBlock;

@end

NS_ASSUME_NONNULL_END
