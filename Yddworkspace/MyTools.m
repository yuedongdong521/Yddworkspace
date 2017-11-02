//
//  MyTools.m
//  Yddworkspace
//
//  Created by ispeak on 2016/12/5.
//  Copyright © 2016年 QH. All rights reserved.
//


//文／王先森23（简书作者）
//原文链接：http://www.jianshu.com/p/4a551acf08c6
//著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。

#import "MyTools.h"

@implementation MyTools


+ (instancetype)shareMyTools
{
    static MyTools *tools = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tools = [[MyTools alloc] init];
    });
    return tools;
}


#pragma mark 获取当前控制器 {
-(UIViewController*) findBestViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    }
    else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}
-(UIViewController*) getCurrentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
}
#pragma mark }

#pragma mark - 计算label可以显示多少个字数
+ (NSInteger)numberOfStringInUpper:(UILabel *)label stringToSeperate:(NSString *)str{
    CGRect container = label.frame;
    CGSize detailSize;
    for (int i = 0; i < [str length]; i ++) {
        NSString *textStr = [str substringToIndex:i+1];
        NSDictionary *attribute = @{NSFontAttributeName: label.font};
        detailSize = [textStr boundingRectWithSize:CGSizeMake(container.size.width, CGFLOAT_MAX) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        if (detailSize.height > container.size.height) {
            return i;
        }
    }
    container.size.height = detailSize.height;
    [label setFrame:container]; //调整高度
    return [str length];
}

#pragma mark - 计算文本宽高 -
- (CGSize)getContentStr:(NSString *)text widthSize:(CGFloat)width heightSize:(CGFloat)height FontOfSize:(UIFont *)fontSize

{
    CGSize requiredSize;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, height)
                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:fontSize}
                                     context:nil];
    requiredSize = rect.size;
    return requiredSize;
    
}

#pragma mark - 当前视图大小变化

+ (CAAnimation *)starTimer:(CGFloat)duration original:(CGFloat)original midNumerical:(CGFloat)midNumerical endNumerical:(CGFloat)endNumerical

{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[[NSNumber numberWithFloat:original], [NSNumber numberWithFloat:midNumerical], [NSNumber numberWithFloat:endNumerical]];//大小变化倍数
    
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    /*
     
     速度控制函数(CAMediaTimingFunction)
     
     kCAMediaTimingFunctionLinear（线性）：匀速，给你一个相对静态的感觉
     
     kCAMediaTimingFunctionEaseIn（渐进）：动画缓慢进入，然后加速离开
     
     kCAMediaTimingFunctionEaseOut（渐出）：动画全速进入，然后减速的到达目的地
     
     kCAMediaTimingFunctionEaseInEaseOut（渐进渐出）：动画缓慢的进入，中间加速，然后减速的到达目的地。 这个是默认的动画行为。
     
     */
    
    animation.duration = duration;//动画执行的时间
    
    animation.repeatCount = HUGE_VALF;//播放次数
    
    animation.autoreverses = NO;// 当你设定这个属性为 YES 时,在它到达目的地之后,动画的返回到开始的值,代替了直接跳转到 开始的值。
    
    animation.removedOnCompletion = NO;//这个属性默认为 YES,那意味着,在指定的时间段完成后,动画就自动的从层上移除了。这个一般不用。假如你想要再次用这个动画时,你需要设定这个属性为 NO。这样的话,下次你在通过-set 方法设定动画的属 性时,它将再次使用你的动画,而非默认的动画
    
    animation.fillMode=kCAFillModeForwards;
    
    /*
     
     fillMode的作用就是决定当前对象过了非active时间段的行为. 比如动画开始之前,动画结束之后。如果是一个动画CAAnimation,则需要将其removedOnCompletion设置为NO,要不然fillMode不起作用.
     
     kCAFillModeRemoved 这个是默认值,也就是说当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态
     
     kCAFillModeForwards 当动画结束后,layer会一直保持着动画最后的状态
     
     kCAFillModeBackwards 这个和kCAFillModeForwards是相对的,就是在动画开始前,你只要将动画加入了一个layer,layer便立即进入动画的初始状态并等待动画开始.你可以这样设定测试代码,将一个动画加入一个layer的时候延迟5秒执行.然后就会发现在动画没有开始的时候,只要动画被加入了layer,layer便处于动画初始状态
     
     kCAFillModeBoth 理解了上面两个,这个就很好理解了,这个其实就是上面两个的合成.动画加入后开始之前,layer便处于动画初始状态,动画结束后layer保持动画最后的状态.
     
     */
    
    return animation;
    
}

#pragma mark - 当前视图透明度变化

- (CAAnimation *)fadeInOutAnimation:(CGFloat)duration fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue

{
    //通过keypath创建路径
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    animation.duration = duration;
    
    animation.repeatCount = HUGE_VALF;
    
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    
    animation.toValue = [NSNumber numberWithFloat:toValue];
    
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    animation.autoreverses = NO;
    
    animation.removedOnCompletion=NO;
    
    animation.fillMode=kCAFillModeForwards;
    
    return animation;
    
}

#pragma mark - 截取全屏

- (UIImage *)imageFromView:(UIView*)theView

{
    
    UIGraphicsBeginImageContext(theView.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [theView.layer renderInContext:context];
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
    
}

#pragma mark - 数组排序

- (NSArray *)getSortingArray:(NSArray *)array{
    
    // 返回一个排好序的数组，原来数组的元素顺序不会改变
    
    // 指定元素的比较方法：compare:
    
    NSArray *array2 = [array sortedArrayUsingSelector:@selector(compare:)];
    
    return array2;
    
}

#pragma mark - 点赞效果 大小变化

- (void)imageViewAnimationLayer:(UIView *)view{
    
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    k.values = @[@(0.1),@(1.0),@(1.2)];
    
    k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
    
    k.calculationMode = kCAAnimationLinear;
    [view.layer addAnimation:k forKey:@"trans"];
    
}

#pragma mark - 获取当前时间

- (NSString *)getCurrentTime{
    
    //现在时间
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *currentTime = [NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]];
    
    formatter = nil;
    
    return currentTime;
    
}

#pragma mark 图片压缩

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage*)selectedImage

{
    //方法2
    CGFloat scaxy=1.0;
    
    const int maxW = targetSize.width, maxH = targetSize.height;
    
    if (selectedImage.size.height>maxH && selectedImage.size.width >maxW)
        
    {
        
        CGFloat scax = maxH/selectedImage.size.width;
        
        CGFloat scay = maxW/selectedImage.size.height;
        
        if (scax > scay)
            
        {
            
            scaxy = scay;
            
        }
        
        else
            
        {
            
            scaxy = scax;
            
        }
        
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(selectedImage.size.width * scaxy, selectedImage.size.height *scaxy));
    
    // Tell the old image to draw in this new context, with the desired// new size
    
    [selectedImage drawInRect:CGRectMake(0,0,selectedImage.size.width * scaxy, selectedImage.size.height *scaxy)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

#pragma mark - 随机颜色

-(UIColor *)randomColor:(CGFloat)alpha

{
    
    CGFloat red = arc4random_uniform(253);
    
    CGFloat green = arc4random_uniform(254);
    
    CGFloat blue = arc4random_uniform(255);
    
    //    CGFloat red = arc4random() % 256 ;//(CGFloat)random()/(CGFloat)RAND_MAX;
    
    //    CGFloat green =arc4random() % 256 ; //(CGFloat)random()/(CGFloat)RAND_MAX;
    
    //    CGFloat blue = arc4random() % 256 ;//(CGFloat)random()/(CGFloat)RAND_MAX;
    
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
    
}

// 正则判断电话号码地址格式,固话
-(BOOL)isTelePhone:(NSString *)telePhoneNum

{
    /**
     
     * 手机号码
     
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     
     * 联通：130,131,132,152,155,156,185,186
     
     * 电信：133,1349,153,180,189
     
     */
    
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     
     10        * 中国移动：China Mobile
     
     11        * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     
     12        */
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    /**
     
     15        * 中国联通：China Unicom
     
     16        * 130,131,132,152,155,156,185,186
     
     17        */
    
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    /**
     
     20        * 中国电信：China Telecom
     
     21        * 133,1349,153,180,189
     
     22        */
    
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    /**
     
     25        * 大陆地区固话及小灵通
     
     26        * 区号：010,020,021,022,023,024,025,027,028,029
     
     27        * 号码：七位或八位
     
     28        */
    
    //    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSString * PHS = @"^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$";
    
    //    NSString * PHS = @"^(\\b0[1-2]\\d-\\d{8}(-\\d{1,4})?\\b)|(\\b0\\d{3}-\\d{7,8}(-\\d{1,4})?\\b)$";
    
    //    NSString * PHS = @"^(0?1[358]\\d{9})|((0(10|2[1-3]|[3-9]\\d{2}))?[1-9]\\d{6,7})$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:telePhoneNum] == YES)
        
        ||([regextestphs evaluateWithObject:telePhoneNum] == YES)
        
        || ([regextestcm evaluateWithObject:telePhoneNum] == YES)
        
        || ([regextestct evaluateWithObject:telePhoneNum] == YES)
        
        || ([regextestcu evaluateWithObject:telePhoneNum] == YES))
        
    {
        return YES;
    }
    
    else
        
    {
        return NO;
    }
    
}

//判断是否中文

-(BOOL)isChinese:(NSString *)string{
    
    NSString *miaoNumRegex =@"^[\u4e00-\u9fa5]{0,}$";
    
    NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",miaoNumRegex];
    
    return [passTest evaluateWithObject:string];
    
}


//身份证号

- (BOOL)validateIdentityCard: (NSString *)identityCard

{
    
    BOOL flag;
    
    if (identityCard.length <= 0) {
        
        flag = NO;
        
        return flag;
        
    }
    
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    
    return [identityCardPredicate evaluateWithObject:identityCard];
    
}

// 判断邮箱是否正确

- (BOOL)isValidateEmail:(NSString *)Email

{
    
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    
    return [emailTest evaluateWithObject:Email];
    
}

//判断字母数字

- (BOOL)IsNumber:(NSString *)number

{
    //是否字母数字
    NSString *miaoNumRegex =@"^[a-zA-Z0-9_]+$";
    
    NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",miaoNumRegex];
    
    return [passTest evaluateWithObject:number];
    
}

#pragma mark 改变图片方向
-(UIImage *)scaleAndRotateImage:(UIImage *)image resolution:(int)kMaxResolution{
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);

    CGFloat height = CGImageGetHeight(imgRef);
 
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);

    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;

        } else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }

    CGFloat scaleRatio = bounds.size.width / width;

    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));

    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;

    switch(orient) {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);

            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];

    }
    UIGraphicsBeginImageContext(CGSizeMake(floorf(bounds.size.width), floorf(bounds.size.height)));
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, floorf(width), floorf(height)), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

- (UIColor *)getColorValueForRGBStr:(NSString *)rgbStr
{
    unsigned int rgbValue;
    BOOL isCan = [[NSScanner scannerWithString:rgbStr] scanHexInt:&rgbValue];
    if (isCan) {
        return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
    } else {
        return [UIColor clearColor];
    }
}

- (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
