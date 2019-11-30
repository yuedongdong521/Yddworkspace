//
//  KXLiveStickerView.m
//  KXLive
//
//  Created by ydd on 2019/11/22.
//  Copyright © 2019 ibobei. All rights reserved.
//

#import "KXLiveStickerView.h"
//#import "KXLivePusher.h"

@interface KXStickerImageView : UIImageView<UIGestureRecognizerDelegate>

@property (nonatomic, copy) void(^didChanged)(void);

@property (nonatomic, copy) void(^showTipsView)(BOOL isShow);

@property (nonatomic, assign) UIEdgeInsets insets;

@end

@implementation KXStickerImageView

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.insets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)panAction:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture translationInView:self];
    
    [gesture setTranslation:CGPointZero inView:self];

    UIGestureRecognizerState state = gesture.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            if (self.showTipsView) {
                self.showTipsView(YES);
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGRect rect = self.frame;
            rect.origin.x = rect.origin.x + point.x;
            rect.origin.y = rect.origin.y + point.y;
            
            self.frame = rect;
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
            CGFloat screenW = [UIScreen mainScreen].bounds.size.width;

            
            CGFloat top = CGRectGetMinY(self.frame);
            CGFloat left = CGRectGetMinX(self.frame);
            CGFloat bottom = screenH - CGRectGetMaxY(self.frame);
            CGFloat right = screenW - CGRectGetMaxX(self.frame);
            
            __block CGRect rect = self.frame;
            
            if (top < self.insets.top) {
                rect.origin.y = self.insets.top;
            }
            
            if (left < 0.f) {
                rect.origin.x = 0.f;
            }
            
            if (bottom < self.insets.bottom) {
                rect.origin.y = screenH - self.insets.bottom  - rect.size.height;
            }
            
            if (right < 0.f) {
                rect.origin.x = screenW - rect.size.width;
            }
            
            self.frame = rect;
            
            if (self.didChanged) {
                self.didChanged();
            }
            if (self.showTipsView) {
                self.showTipsView(NO);
            }
            
        }
            break;
            
        default:
            if (self.showTipsView) {
                self.showTipsView(NO);
            }
            break;
    }
}


@end

@interface KXLiveStickerView ()

@property (nonatomic, strong) NSMutableArray <KXStickerImageView *>* items;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *midView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) CGFloat edgeTop;

@property (nonatomic, assign) CGFloat edgeBottom;

@end

@implementation KXLiveStickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
                       midTop:(CGFloat)midTop
                    midBottom:(CGFloat)midBottom
                     anchorId:(NSInteger)anchorId;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.topView];
        [self addSubview:self.midView];
        [self addSubview:self.bottomView];
        self.edgeTop = midTop;
        self.edgeBottom = frame.size.height - midBottom;
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.mas_equalTo(0);
            make.height.mas_equalTo(midTop);
        }];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(midBottom);
        }];
        
        self.midView.frame = CGRectMake(0, midTop, ScreenWidth, midBottom - midTop);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.midView.bounds];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.frame = self.midView.bounds;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.path = path.CGPath;
        layer.strokeStart = 0;
        layer.strokeEnd = 1;
        layer.strokeColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
        layer.lineWidth = 1;
        [layer setLineJoin:kCALineJoinRound];
        [layer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2],[NSNumber numberWithInt:2],nil]];
        [self.midView.layer addSublayer:layer];
        
        [self addSubview:self.contentView];
        self.contentView.frame = self.bounds;
        [self hiddenTips:NO];
    }
    return self;
}

- (UIImage *)getStickerImage
{
    UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (void)addImage:(UIImage *)image
{
    if (image && !self.hidden) {
        KXStickerImageView *imageView = [[KXStickerImageView alloc] initWithImage:image];
        imageView.insets = UIEdgeInsetsMake(0, 0, _edgeBottom, 0);
        
        __weak typeof(self) weakself = self;
        __weak typeof(imageView) weakImageView = imageView;
        imageView.didChanged = ^{
            __strong typeof(weakImageView) strongImageView = weakImageView;
            __strong typeof(weakself) strongself = weakself;
            [strongself didChangeSticker:strongImageView];
        };
        
        imageView.showTipsView = ^(BOOL isShow) {
            __strong typeof(weakself) strongself = weakself;
            [strongself hiddenTips:isShow];
        };
        
        [self.contentView addSubview:imageView];
        CGFloat x = (self.frame.size.width - image.size.width) * 0.5;
        CGFloat y = (self.frame.size.height - image.size.height) * 0.5;
        imageView.frame = CGRectMake(x, y, image.size.width, image.size.height);
        
        [self.items addObject:imageView];
        [self addSticker];
    }
}


- (void)hiddenSticker
{
    self.hidden = YES;
//    [self.livePusher addStickerImage:nil frame:self.frame];
}

- (void)showSticker
{
    self.hidden = NO;
    [self addSticker];
}

- (void)hiddenTips:(BOOL)isShow
{
    self.topView.hidden = !isShow;
    self.midView.hidden = !isShow;
    self.bottomView.hidden = !isShow;
    if (self.hiddenHeaderView) {
        self.hiddenHeaderView(isShow);
    }
}

- (void)addSticker
{
    UIImage *image = nil;
    if (self.items.count > 0) {
        image = [self getStickerImage];
    }
//    [self.livePusher addStickerImage:image frame:self.frame];
}

- (void)didChangeSticker:(KXStickerImageView *)imageView
{
    if (imageView.frame.origin.y < CGRectGetMaxY(self.topView.frame)) {
        [self.items removeObject:imageView];
        [imageView removeFromSuperview];
    }
    [self addSticker];
}

- (void)deletedSticker:(KXStickerImageView *)imageView
{
    [self.items removeObject:imageView];
    [imageView removeFromSuperview];
    [self addSticker];
}

- (void)removeAllItems
{
    [self.items enumerateObjectsUsingBlock:^(KXStickerImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.items removeAllObjects];
}

- (NSMutableArray<KXStickerImageView *> *)items
{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.opaque = NO;
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = UIColorHexRGBA(0xFF5272, 0.2);
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = UIColorHexRGBA(0xFF2D55, 1);
        label.backgroundColor = [UIColor whiteColor];
        label.text = @"拖至此区域删除";
        [_topView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(130, 37));
            make.bottom.mas_equalTo(-14);
            make.centerX.mas_equalTo(_topView.mas_centerX);
        }];
        label.layer.cornerRadius = 18.5;
        label.layer.masksToBounds = YES;
    }
    return _topView;
}


- (UIView *)midView
{
    if (!_midView) {
        _midView = [[UIView alloc] init];
        _midView.backgroundColor = [UIColor clearColor];
        
    }
    return _midView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    }
    return _bottomView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    for (KXStickerImageView *view in self.items) {
        if (CGRectContainsPoint(view.frame, point)) {
            return YES;
        }
    }
    return NO;
}

@end
