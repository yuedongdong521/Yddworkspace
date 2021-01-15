//
//  UIImage+Extra.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/20.
//  Copyright © 2019年 Qihe. All rights reserved.
//

#import "UIImage+Extra.h"

@implementation UIImage (Extra)
+(UIImage *)reduceScaleToWidth:(CGFloat)width andImage:(UIImage *)image
{  
    //若图片宽度小于传入的压缩后宽度那么直接返回原图
    if (image.size.width <= width) {
        return image;
    }
    CGFloat height = image.size.height * (width/image.size.width);
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage * returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

+(UIImage *)reduceWithImageScaleWithScreenScaleToWidth:(CGFloat)width andImage:(UIImage *)image
{
    //若图片宽度小于传入的压缩后宽度那么直接返回原图
    if (image.size.width <= width) {
        return image;
    }
    
    CGFloat height = image.size.height * (width/image.size.width);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //This function may be called from any thread of your app.见注解
    UIGraphicsBeginImageContextWithOptions(rect.size,NO, UIScreen.mainScreen.scale);
    [image drawInRect:rect];
    UIImage * returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

+(UIImage *)reduceWithImageScaleWithScreenScaleToHeight:(CGFloat)height andImage:(UIImage *)image
{
    if (!image) {
        return image;
    }
    //若图片高度小于传入的压缩后高度那么直接返回原图
    if (image.size.height <= height) {
        return image;
    }
    
    CGFloat width = image.size.width * (height/image.size.height);
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContextWithOptions(rect.size,NO, UIScreen.mainScreen.scale);
    [image drawInRect:rect];
    UIImage * returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

+ (UIImage *)reducePhotoScaleToWidth:(CGFloat)width andImage:(UIImage *)image
{
    //若图片宽度小于传入的压缩后宽度那么直接返回原图
    if (image.size.width <= width) {
        return image;
    }
    
    CGFloat height = 0.75 * width;
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage * returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

+ (UIImage *)extraImageWithColor:(UIColor *)color
{
    CGFloat imageW = 3;
    CGFloat imageH = 3;
    // 1.开启基于位图的图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageW, imageH), NO, 0.0);
    // 2.画一个color颜色的矩形框
    [color set];
    UIRectFill(CGRectMake(0, 0, imageW, imageH));
    
    // 3.拿到图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 4.关闭上下文
    UIGraphicsEndImageContext();
    
    return image;
}


/**生成纯色图片*/
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    size = CGSizeMake(size.width*[UIScreen mainScreen].scale, size.height*[UIScreen mainScreen].scale);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return myImage;
}


+ (UIImage *)gradientColorImageFromColors:(NSArray*)colors gradientType:(GradientType)gradientType imgSize:(CGSize)imgSize {
    
    if (colors.count < 1) {
        return [UIImage imageWithColor:[UIColor blackColor] size:imgSize];
    }
    
    if (colors.count == 1) {
        return [UIImage imageWithColor:colors.firstObject size:imgSize];
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    for (UIColor *c in colors) {
        [arr addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)arr, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case GradientTypeTopToBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, imgSize.height);
            break;
        case GradientTypeLeftToRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(imgSize.width, 0.0);
            break;
        case GradientTypeUpleftToLowright:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(imgSize.width, imgSize.height);
            break;
        case GradientTypeUprightToLowleft:
            start = CGPointMake(imgSize.width, 0.0);
            end = CGPointMake(0.0, imgSize.height);
            break;
        case GradientTypeLowRightToUpLeft:
            start = CGPointMake(imgSize.width, imgSize.height);
            end = CGPointMake(0, 0);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end,kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    //CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)gradientColorImageFromColors:(NSArray*)colors
                             gradientType:(GradientType)gradientType
                                  imgSize:(CGSize)imgSize
                               startPoint:(CGPoint)startPoint
                                 endPoint:(CGPoint)endPoint {
    if (colors.count < 1) {
        return [UIImage imageWithColor:[UIColor blackColor] size:imgSize];
    }
    
    if (colors.count == 1) {
        return [UIImage imageWithColor:colors.firstObject size:imgSize];
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    for (UIColor *c in colors) {
        [arr addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)arr, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case GradientTypeTopToBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, imgSize.height);
            break;
        case GradientTypeLeftToRight:
            start = startPoint;
            end = CGPointMake(imgSize.width+endPoint.x, endPoint.y);
            break;
        case GradientTypeUpleftToLowright:
            start = startPoint;
            end = CGPointMake(imgSize.width+endPoint.x, imgSize.height+endPoint.y);
            break;
        case GradientTypeUprightToLowleft:
            start = CGPointMake(imgSize.width+startPoint.x, startPoint.y);
            end = CGPointMake(endPoint.x, imgSize.height+endPoint.y);
            break;
        case GradientTypeLowRightToUpLeft:
            start = CGPointMake(imgSize.width+startPoint.x, imgSize.height+startPoint.y);
            end = CGPointMake(endPoint.x, endPoint.y);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end,kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    //CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

+(UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
        {
            rotate =M_PI_2;
            rect =CGRectMake(0,0,image.size.height, image.size.width);
            translateX=0;
            translateY= -rect.size.width;
            scaleY =rect.size.width/rect.size.height;
            scaleX =rect.size.height/rect.size.width;
        }
            break;
        case UIImageOrientationRight:
        {
            rotate =3 *M_PI_2;
            rect =CGRectMake(0,0,image.size.height, image.size.width);
            translateX= -rect.size.height;
            translateY=0;
            scaleY =rect.size.width/rect.size.height;
            scaleX =rect.size.height/rect.size.width;
        }
            break;
        case UIImageOrientationDown:
        {
            rotate =M_PI;
            rect =CGRectMake(0,0,image.size.width, image.size.height);
            translateX= -rect.size.width;
            translateY= -rect.size.height;
        }
            break;
        default:
        {
            rotate =0.0;
            rect =CGRectMake(0,0,image.size.width, image.size.height);
            translateX=0;
            translateY=0;
        }
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX,translateY);
    
    CGContextScaleCTM(context, scaleX,scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0,0,rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic =UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

- (UIImage *)jj_imageWithCornerRadius:(CGFloat)radius
{
    CGRect rect = (CGRect){0.f, 0.f, self.size};
    UIGraphicsBeginImageContextWithOptions(self.size, NO,
                                           UIScreen.mainScreen.scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:rect
                                                cornerRadius:radius].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageWithAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    [self drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:alpha];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage *)kx_gradiant:(CGSize)size withColors:(NSArray<UIColor *>*)colors alpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetAlpha(ctx, alpha);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 渐变色的颜色
    NSArray *colorArr = @[
                          (id)colors[0].CGColor,
                          (id)colors[1].CGColor
                          ];
    
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorArr, NULL);
    // 释放色彩空间
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0),CGPointMake(size.width, 0), 0);
    CGContextRestoreGState(ctx);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    // 释放gradient
    CGGradientRelease(gradient);
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)kx_gradiant:(CGSize)size withColors:(NSArray<UIColor *>*)colors
{
    return [self kx_gradiant:size withColors:colors alpha:1.0];
}

+ (UIImage *)cutImageFromImage:(UIImage *)image inRect:(CGRect)rect
{
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:scale orientation:UIImageOrientationUp];
    if (newImageRef) {
        CFRelease(newImageRef);
    }
    return newImage;
}

+ (UIImage *)cutImageFromImage:(UIImage *)image inRect:(CGRect)rect withScale:(CGFloat)scale
{
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:scale orientation:UIImageOrientationUp];
    if (newImageRef) {
        CFRelease(newImageRef);
    }
    return newImage;
}

+ (nullable UIImage *)scaleWithRatio:(float)ratio ForImage:(UIImage *)image {
    CGSize mSize = CGSizeMake(image.size.width / ratio, image.size.height / ratio);
    CGRect rect = CGRectMake(0, 0, mSize.width, mSize.height);
    UIGraphicsBeginImageContextWithOptions(mSize, NO, 0);
    // 读取当前画布的内容
    [image drawInRect:rect];
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tempImage;
}

// 中心点拉伸
+ (UIImage *)resizableImageWithImage:(UIImage *)image {
    //拉伸图片
    CGFloat top = image.size.height * 0.5;
    CGFloat left = image.size.width * 0.5;
    CGFloat bottom = image.size.height * 0.5;
    CGFloat right = image.size.width * 0.5;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
    UIImage* newImage = [image resizableImageWithCapInsets:edgeInsets];
    return newImage;
}

// 指定点拉伸
+ (UIImage *)resizableImageWithImage:(UIImage *)image withEdgeInsets:(UIEdgeInsets)edgeInsets {
    UIImage* newImage = [image resizableImageWithCapInsets:edgeInsets];
    return newImage;
}

+(UIImage*)circleImage:(UIImage*)image
{
    
  return  [self circleOldImage:image borderWidth:0 borderColor:[UIColor clearColor]];
}


+ (instancetype)circleOldImage:(UIImage *)originalImage borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    // 1.加载原图
    UIImage *oldImage = originalImage;
    
    // 2.开启上下文
    CGFloat imageW = oldImage.size.width + 2 * borderWidth;
    CGFloat imageH = oldImage.size.height + 2 * borderWidth;
    
    CGFloat size = imageW > imageH ? imageH : imageW;
    CGSize  imageSize = CGSizeMake(size, size);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    
    // 3.取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 4.画边框(大圆)
    [borderColor set];
    CGFloat bigRadius = size * 0.5; // 大圆半径
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆
    
    // 5.小圆
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    // 裁剪(后面画的东西才会受裁剪的影响)
    CGContextClip(ctx);
    
    // 6.画图
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    
    // 7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}
#pragma mark - 高斯模糊 在一些机器上有崩溃，不能使用
//+ (UIImage*)blureImage:(UIImage*)originImage
//       withInputRadius:(CGFloat)inputRadius {
//  CIImage* inputImage = [CIImage
//      imageWithCGImage:
//          originImage
//              .CGImage];  // [[CIImage alloc] initWithCGImage:originImage.CGImage options:nil];
//  CIContext* context = [CIContext
//      contextWithOptions:
//          [NSDictionary
//              dictionaryWithObject:[NSNumber numberWithBool:YES]
//                            forKey:
//                                kCIContextUseSoftwareRenderer]];  // CPU渲染[CIContext contextWithOptions:nil];
//  CIFilter* filter = [CIFilter filterWithName:@"CIGaussianBlur"];
//  [filter setValue:inputImage forKey:kCIInputImageKey];
//  [filter setValue:[NSNumber numberWithFloat:inputRadius]
//            forKey:@"inputRadius"];
//  // blur image
//  CIImage* result = [filter valueForKey:kCIOutputImageKey];
//  CGImageRef cgImage =
//      [context createCGImage:result fromRect:[inputImage extent]];
//  UIImage* image = [UIImage imageWithCGImage:cgImage];
//  CGImageRelease(cgImage);
//  return image;
//}

- (CGFloat)scaleWidthWithHeight:(CGFloat)height
{
    if (self.size.height <= height) {
        return self.size.height;
    }
    return height / self.size.height * self.size.width;
}


/// 此方法还原真实图片 zego新加
- (CVPixelBufferRef)getCVPixelBufferRefFromImage{
    CGSize size = self.size;
    //TODO:郁玉涛 720 1280 更换标准尺寸图片
    size = CGSizeMake(720, 720/size.width*size.height);
    CGImageRef image = [self CGImage];
    
    BOOL hasAlpha = CGImageRefContainsAlpha(image);
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             empty, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, inputPixelFormat(), (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    uint32_t bitmapInfo = bitmapInfoWithPixelFormatType(inputPixelFormat(), (bool)hasAlpha);
    
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, bitmapInfo);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    return pxbuffer;
}

static OSType inputPixelFormat(){
    return kCVPixelFormatType_32BGRA;
}

static uint32_t bitmapInfoWithPixelFormatType(OSType inputPixelFormat, bool hasAlpha){
    
    if (inputPixelFormat == kCVPixelFormatType_32BGRA) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        return bitmapInfo;
    }else if (inputPixelFormat == kCVPixelFormatType_32ARGB) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big;
        return bitmapInfo;
    }else{
        NSLog(@"不支持此格式");
        return 0;
    }
}

// alpha的判断
BOOL CGImageRefContainsAlpha(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}



+ (UIImage *)changeGrayImage:(UIImage *)oldImage {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:oldImage.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    if (superImage) {
        [lighten setValue:superImage forKey:kCIInputImageKey];
    }
    
    // 修改亮度   -1---1   数越大越亮
    [lighten setValue:@(0) forKey:@"inputBrightness"];
    // 修改饱和度  0---2
    [lighten setValue:@(0) forKey:@"inputSaturation"];
    // 修改对比度  0---4
    [lighten setValue:@(1) forKey:@"inputContrast"];
    CIImage *result = [lighten valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    UIImage *newImage =  [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return newImage;
}


@end
