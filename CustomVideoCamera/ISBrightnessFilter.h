//
//  ISBrightnessFilter.h
//  iShow
//
//  Created by student on 2017/8/3.
//
//

#import "GPUImage.h"

@interface ISBrightnessFilter : GPUImageFilter {
  GLint brightnessUniform;
}

// Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
@property(readwrite, nonatomic) CGFloat brightness;
@end
