//
//  GPUImageBeautifyFilter.h
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.
//

#import "GPUImage.h"

@class GPUImageCombinationFilter;
@class ISBrightnessFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
  GPUImageBilateralFilter* bilateralFilter;
  GPUImageCannyEdgeDetectionFilter* cannyEdgeFilter;
  GPUImageCombinationFilter* combinationFilter;
  // GPUImageHSBFilter *hsbFilter;
  ISBrightnessFilter* brightnessFilter;
}
// 更改磨皮参数
@property(nonatomic, assign) CGFloat intensity;
// 更改美白参数
@property(nonatomic, assign) CGFloat whiteness;

@end
