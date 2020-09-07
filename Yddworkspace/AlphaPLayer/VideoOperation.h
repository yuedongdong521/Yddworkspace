//
//  VideoOperation.h
//  Yddworkspace
//
//  Created by ydd on 2020/3/26.
//  Copyright © 2020 QH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoOperation : NSOperation

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, copy) void(^taskStart)(NSString *videoPath, void(^completed)(BOOL finished));


@end

NS_ASSUME_NONNULL_END
