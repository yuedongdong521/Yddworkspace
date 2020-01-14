//
//  RedPacketView.m
//  Yddworkspace
//
//  Created by ydd on 2020/1/10.
//  Copyright © 2020 QH. All rights reserved.
//

#import "RedPacketView.h"



@interface RedPacketItem : UIImageView<CAAnimationDelegate>

@property (nonatomic, assign) NSInteger redPacketId;
@property (nonatomic, copy) void(^clickedBlock)(NSInteger redPacketId);

@property (nonatomic, copy) void(^animationFinished)(void);



@end

@implementation RedPacketItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)startAnimation
{
    self.animationImages = [self createAnimationImages];
    self.animationDuration = 0.4;
    [self startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopAnimating];
        if (self.clickedBlock) {
            self.clickedBlock(self.redPacketId);
        }
    });
    
}

- (NSArray<UIImage*>*)createAnimationImages
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i < 6; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"img_red_packet_boom_%d", i]];
        if (image) {
            [array addObject:image];
        }
    }
    return array;
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    NSLog(@"cur item = %ld", (long)self.redPacketId);
    [self startAnimation];
    
}

- (void)addAnimationWithPath:(UIBezierPath *)path
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    // 设置动画的路径为心形路径
    animation.path = path.CGPath;
    // 动画时间间隔
    animation.duration = 3.0f;
    // 重复次数为最大值
    animation.repeatCount = 1; // FLT_MAX;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    // 将动画添加到动画视图上
    [self.layer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.animationFinished) {
        self.animationFinished();
    }
}

+ (UIBezierPath *)pathWithStartPoint:(CGPoint)startPoint
                            endPoint:(CGPoint)endPoint
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    CGFloat h = endPoint.y - startPoint.y;
    CGPoint midPoint = CGPointMake(startPoint.x + 200, startPoint.y + h * 0.3);
    CGPoint midPoint2 = CGPointMake(startPoint.x - 200, startPoint.y + h * 0.6);
    [path addCurveToPoint:endPoint controlPoint1:midPoint controlPoint2:midPoint2];
//    [path addQuadCurveToPoint:endPoint controlPoint:midPoint];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    return path;
}


@end

@interface RedPacketView ()

@property (nonatomic, strong) NSMutableArray <RedPacketItem *>*packetArr;

@end

@implementation RedPacketView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (NSMutableArray<RedPacketItem *> *)packetArr
{
    if (!_packetArr) {
        _packetArr = [NSMutableArray array];
    }
    return _packetArr;
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (self.packetArr.count > 0) {
        return;
    }
    [self addMoreItem];
}

- (void)addMoreItem
{
    static int i = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createRedPacketItem];
        i++;
        if (i < 30) {
            [self addMoreItem];
        } else {
            i = 0;
        }
    });
    
}

- (void)createRedPacketItem
{
    NSArray *locations = @[@(0.25), @(0.5), @(0.75)];
    static int i = 0;
    i = i >= locations.count ? 0 : i;
    CGFloat x = [locations[i] floatValue] * ScreenWidth - 40;
    i++;
    RedPacketItem *item = [[RedPacketItem alloc] init];
    item.image = [UIImage imageNamed:@"img_red_packet"];
    item.frame = CGRectMake(x, 0, 79, 86);
    [self addSubview:item];
    UIBezierPath *path = [RedPacketItem pathWithStartPoint:item.center endPoint:CGPointMake(item.center.x, ScreenHeight)];
    [item addAnimationWithPath:path];
    [self.packetArr addObject:item];
    
    __weak typeof(self) weakself = self;
    __weak typeof(item) weakitem = item;
    item.clickedBlock = ^(NSInteger redPacketId) {
        __strong typeof(weakself) strongself = weakself;
        __strong typeof(weakitem) strongitem = weakitem;
        [strongself destoryItem:strongitem];
    };
    item.animationFinished = ^{
        __strong typeof(weakself) strongself = weakself;
        __strong typeof(weakitem) strongitem = weakitem;
        [strongself destoryItem:strongitem];
    };
}

- (void)destoryItem:(RedPacketItem *)item
{
    if ([item superview]) {
        [item removeFromSuperview];
    }
    [self.packetArr removeObject:item];
}

- (void)drawRect:(CGRect)rect
{
    RedPacketItem *item = [[RedPacketItem alloc] init];
       item.image = [UIImage imageNamed:@"img_red_packet"];
       item.frame = CGRectMake(ScreenWidth * 0.5, 0, 79, 86);
    [[UIColor redColor] set];
    UIBezierPath *path = [RedPacketItem pathWithStartPoint:item.center endPoint:CGPointMake(item.center.x, ScreenHeight)];
    [path stroke];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    __block RedPacketItem *item = nil;
    [self.packetArr enumerateObjectsUsingBlock:^(RedPacketItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.layer.presentationLayer hitTest:point]) {
            item = obj;
        }
    }];
    if (item) {
        return item;
    }
    return [super hitTest:point withEvent:event];
}



@end
