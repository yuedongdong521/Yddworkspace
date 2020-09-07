//
//  VideoOperation.m
//  Yddworkspace
//
//  Created by ydd on 2020/3/26.
//  Copyright © 2020 QH. All rights reserved.
//

#import "VideoOperation.h"



@implementation VideoOperation
@synthesize finished = _finished;
@synthesize executing = _executing;


- (void)start
{
   if ([self isCancelled]) {
       self.finished = YES;
       return;
   }
    if (self.taskStart) {
        __weak typeof(self) weakself = self;
        self.taskStart(self.videoPath, ^(BOOL finished) {
            __strong typeof(weakself) strongself = weakself;
            strongself.finished = YES;
        });
    }
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}




@end
