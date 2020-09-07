//
//  AlphaFrameFilter.m
//  Yddworkspace
//
//  Created by ydd on 2020/3/24.
//  Copyright © 2020 QH. All rights reserved.
//

#import "AlphaFrameFilter.h"
#import <CoreImage/CoreImage.h>

@implementation AlphaFrameFilter

static CIColorKernel* getKernel() {
    return [CIColorKernel kernelWithString:@"kernel vec4 alphaFrame(__sample s, __sample m) { return vec4(s.rgb, m.r); }"];
}

- (CIImage *)outputImage
{
    CIColorKernel *kernel = getKernel();
    if (self.inputImage && self.maskImage) {
        
        
        
        CIImage *image = [kernel applyWithExtent:self.inputImage.extent arguments:@[self.inputImage, self.maskImage]];
        return image;
    }
    return nil;
}


@end
