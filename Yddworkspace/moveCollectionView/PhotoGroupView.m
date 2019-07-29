//
//  PhotoGroupView.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/27.
//  Copyright © 2019 QH. All rights reserved.
//

#import "PhotoGroupView.h"
#import "YYCategories.h"
#import "YYImage.h"
#import "YYWebImage.h"
#import "YYCache.h"

#define kPadding 20

@interface PhotoHeaderView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *rightImage;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, copy) void(^rightAction)(void);

@end

@implementation PhotoHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.titleLabel];
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        _rightBtn = rightBtn;
        
        [rightBtn addSubview:self.rightImage];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(80);
            make.right.mas_equalTo(-80);
            make.bottom.mas_equalTo(0);
        }];
        
        [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(self.titleLabel.mas_right);
            make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
            make.height.mas_equalTo(44);
        }];
        [self.rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(rightBtn.mas_centerY);
            make.right.mas_equalTo(-15);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
    }
    return self;
}



- (void)rightBtnAction:(UIButton *)btn
{
    if (_rightAction) {
        _rightAction();
    }
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIImageView *)rightImage
{
    if (!_rightImage) {
        _rightImage = [[UIImageView alloc] init];
        _rightImage.contentMode = UIViewContentModeScaleAspectFit;
        _rightImage.clipsToBounds = YES;
    }
    return _rightImage;
}


@end


@interface PhotoGroupItem()<NSCopying>

- (BOOL)shouldClipToTop:(CGSize)imageSize forView:(UIView *)view;
- (BOOL)thumbClippedToTop:(UIView *)thumbView;

@end
@implementation PhotoGroupItem

- (BOOL)thumbClippedToTop:(UIView *)thumbView {
    if (thumbView) {
        if (thumbView.layer.contentsRect.size.height < 1) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)shouldClipToTop:(CGSize)imageSize forView:(UIView *)view {
    if (imageSize.width < 1 || imageSize.height < 1) return NO;
    if (view.width < 1 || view.height < 1) return NO;
    return imageSize.height / imageSize.width > view.width / view.height;
}

- (id)copyWithZone:(NSZone *)zone {
    PhotoGroupItem *item = [self.class new];
    return item;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
}

@end


@class PhotoGroupCell;
@protocol PhotoGroupCellDelegate <NSObject>

- (UIImage *)cell:(PhotoGroupCell *)cell getImageWithPage:(NSInteger)page;

@end

@interface PhotoGroupCell : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, weak) id<PhotoGroupCellDelegate> cellDelegate;
@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) PhotoGroupItem *item;
@property (nonatomic, readonly) BOOL itemDidLoad;

- (void)resizeSubviewSize;
@end

@implementation PhotoGroupCell

- (instancetype)init {
    self = super.init;
    if (!self) return nil;
    self.delegate = self;
    self.bouncesZoom = YES;
    self.maximumZoomScale = 3;
    self.multipleTouchEnabled = YES;
    self.alwaysBounceVertical = NO;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.frame = [UIScreen mainScreen].bounds;
    
    _imageContainerView = [UIView new];
    _imageContainerView.clipsToBounds = YES;
    [self addSubview:_imageContainerView];
    
    _imageView = [YYAnimatedImageView new];
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    [_imageContainerView addSubview:_imageView];
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.size = CGSizeMake(40, 40);
    _progressLayer.cornerRadius = 20;
    _progressLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
    _progressLayer.path = path.CGPath;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    _progressLayer.lineWidth = 4;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [self.layer addSublayer:_progressLayer];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _progressLayer.center = CGPointMake(self.width / 2, self.height / 2);
}

- (void)setItem:(PhotoGroupItem *)item {
    if (_item == item || [item.largeImageURL.absoluteString isEqualToString:_item.largeImageURL.absoluteString ]) {
        [self resetImage];
        return;
    }
    _item = item;
    _itemDidLoad = NO;
    
    
    [self setZoomScale:1.0 animated:NO];
    self.maximumZoomScale = 1;
    
    [_imageView yy_cancelCurrentImageRequest];
    [_imageView.layer removePreviousFadeAnimation];
    
    _progressLayer.hidden = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [CATransaction commit];
    
    if (!_item) {
        _imageView.image = nil;
        return;
    }

    UIImage *placeholderImage = nil;
    if ([_cellDelegate respondsToSelector:@selector(cell:getImageWithPage:)]) {
        placeholderImage = [_cellDelegate cell:self getImageWithPage:_page];
    }
    @weakify(self);
    [_imageView yy_setImageWithURL:item.largeImageURL placeholder:placeholderImage options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        @strongify(self);
        if (!self) return;
        CGFloat progress = receivedSize / (float)expectedSize;
        progress = progress < 0.01 ? 0.01 : progress > 1 ? 1 : progress;
        if (isnan(progress)) progress = 0;
        self.progressLayer.hidden = NO;
        self.progressLayer.strokeEnd = progress;
    } transform:nil completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        @strongify(self);
        if (!self) return;
        self.progressLayer.hidden = YES;
        if (stage == YYWebImageStageFinished) {
            self.maximumZoomScale = 3;
            if (image) {
                self->_itemDidLoad = YES;
                
                [self resizeSubviewSize];
//                [self.imageView.layer addFadeAnimationWithDuration:0.1 curve:UIViewAnimationCurveLinear];
            }
        }
        
    }];
    [self resizeSubviewSize];
}

- (void)resetImage
{
    [self setZoomScale:1.0 animated:NO];
    self.maximumZoomScale = 3;
    [self resizeSubviewSize];
}

- (void)resizeSubviewSize {
    _imageContainerView.origin = CGPointZero;
    _imageContainerView.width = self.width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.height / self.width) {
        _imageContainerView.height = floor(image.size.height / (image.size.width / self.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        _imageContainerView.height = height;
        _imageContainerView.centerY = self.height / 2;
    }
    if (_imageContainerView.height > self.height && _imageContainerView.height - self.height <= 1) {
        _imageContainerView.height = self.height;
    }
    self.contentSize = CGSizeMake(self.width, MAX(_imageContainerView.height, self.height));
    [self scrollRectToVisible:self.bounds animated:NO];
    
    if (_imageContainerView.height <= self.height) {
        self.alwaysBounceVertical = NO;
    } else {
        self.alwaysBounceVertical = YES;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _imageView.frame = _imageContainerView.bounds;
    [CATransaction commit];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = _imageContainerView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}


- (void)dealloc
{
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
}


@end


@interface PhotoGroupView() <UIScrollViewDelegate, UIGestureRecognizerDelegate, PhotoGroupCellDelegate>
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;

@property (nonatomic, strong) UIImage *snapshotImage;
@property (nonatomic, strong) UIImage *snapshorImageHideFromView;

@property (nonatomic, strong) UIImageView *background;
@property (nonatomic, strong) UIImageView *blurBackground;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) UIPageControl *pager;
@property (nonatomic, assign) CGFloat pagerCurrentPage;
@property (nonatomic, assign) BOOL fromNavigationBarHidden;

@property (nonatomic, assign) NSInteger fromItemIndex;
@property (nonatomic, assign) BOOL isPresented;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint panGestureBeginPoint;

@property (nonatomic, strong) PhotoHeaderView *headerView;

@property (nonatomic, strong) NSMutableArray <PhotoGroupItem *>*groupItems;
@property (nonatomic, strong) NSMutableArray <PhotoGroupItem *>*sourceItems;
@property (nonatomic, assign) BOOL isReload;


@property (nonatomic, readonly) NSInteger currentPage;

@end

@implementation PhotoGroupView

- (instancetype)initWithGroupItems:(NSArray *)groupItems {
    self = [super init];
    if (groupItems.count == 0) return nil;
    [self setPhotoItems:groupItems];
    _blurEffectBackground = YES;
    
    NSString *model = [UIDevice currentDevice].machineModel;
    static NSMutableSet *oldDevices;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        oldDevices = [NSMutableSet new];
        [oldDevices addObject:@"iPod1,1"];
        [oldDevices addObject:@"iPod2,1"];
        [oldDevices addObject:@"iPod3,1"];
        [oldDevices addObject:@"iPod4,1"];
        [oldDevices addObject:@"iPod5,1"];
        
        [oldDevices addObject:@"iPhone1,1"];
        [oldDevices addObject:@"iPhone1,1"];
        [oldDevices addObject:@"iPhone1,2"];
        [oldDevices addObject:@"iPhone2,1"];
        [oldDevices addObject:@"iPhone3,1"];
        [oldDevices addObject:@"iPhone3,2"];
        [oldDevices addObject:@"iPhone3,3"];
        [oldDevices addObject:@"iPhone4,1"];
        
        [oldDevices addObject:@"iPad1,1"];
        [oldDevices addObject:@"iPad2,1"];
        [oldDevices addObject:@"iPad2,2"];
        [oldDevices addObject:@"iPad2,3"];
        [oldDevices addObject:@"iPad2,4"];
        [oldDevices addObject:@"iPad2,5"];
        [oldDevices addObject:@"iPad2,6"];
        [oldDevices addObject:@"iPad2,7"];
        [oldDevices addObject:@"iPad3,1"];
        [oldDevices addObject:@"iPad3,2"];
        [oldDevices addObject:@"iPad3,3"];
    });
    if ([oldDevices containsObject:model]) {
        _blurEffectBackground = NO;
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = [UIScreen mainScreen].bounds;
    self.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.delegate = self;
    tap2.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail: tap2];
    [self addGestureRecognizer:tap2];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress)];
    press.delegate = self;
    [self addGestureRecognizer:press];
    
    if (kSystemVersion >= 7) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
        _panGesture = pan;
    }
    
    _cells = @[].mutableCopy;
    
    
    [self addSubview:self.background];
    [self addSubview:self.blurBackground];
    [self addSubview:self.contentView];
    [_contentView addSubview:self.scrollView];
    [_contentView addSubview:self.pager];
    [self addSubview:self.headerView];
    
    return self;
}

- (void)setPhotoItems:(NSArray<PhotoGroupItem *> *)items
{
    self.sourceItems = [NSMutableArray arrayWithArray:[items copy]];
    self.groupItems = [NSMutableArray arrayWithArray:[items copy]];
    if (items.count > 1) {
        [self.groupItems insertObject:items.lastObject atIndex:0];
        [self.groupItems addObject:items.firstObject];
    }
}

- (UIImageView *)background
{
    if (!_background) {
        _background = UIImageView.new;
        _background.frame = self.bounds;
        _background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _background;
}

- (UIImageView *)blurBackground
{
    if (!_blurBackground) {
        _blurBackground = UIImageView.new;
        _blurBackground.frame = self.bounds;
        _blurBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _blurBackground;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = UIView.new;
        _contentView.frame = self.bounds;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _contentView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = UIScrollView.new;
        _scrollView.frame = CGRectMake(-kPadding / 2, 0, self.width + kPadding, self.height);
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceHorizontal = _groupItems.count > 1;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
    }
    return _scrollView;
}

- (PhotoHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[PhotoHeaderView alloc] init];
        _headerView.frame = CGRectMake(0, 0, self.bounds.size.width, 64);
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _headerView.rightImage.image = [UIImage imageNamed:@"mine_icon_more_white"];
        __weak typeof(self) weakself = self;
        _headerView.rightAction = ^{
            [weakself headerRightAction];
        };
    }
    return _headerView;
}

- (void)headerRightAction
{
    if ([_delegate respondsToSelector:@selector(photoGroupView:rightActionWithPage:)]) {
        [_delegate photoGroupView:self rightActionWithPage:self.currentIndex];
    }
}

- (UIPageControl *)pager
{
    if (_pager) {
        _pager = [[UIPageControl alloc] init];
        _pager.hidesForSinglePage = YES;
        _pager.userInteractionEnabled = NO;
        _pager.width = self.width - 36;
        _pager.height = 10;
        _pager.center = CGPointMake(self.width / 2, self.height - 18);
        _pager.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _pager;
}

- (UIView *)getThumbViewWithPage:(NSInteger)page
{
    if ([_delegate respondsToSelector:@selector(photoGroupView:getThumbViewWithPage:)]) {
        return [_delegate photoGroupView:self getThumbViewWithPage:page];
    }
    return nil;
}

- (UIImage *)getThumbImageWithPage:(NSInteger)page
{
    if ([_delegate respondsToSelector:@selector(photoGroupView:getImageWithPage:)]) {
        return [_delegate photoGroupView:self getImageWithPage:page];
    }
    return nil;
}

- (NSInteger)pageCoverIndex:(NSInteger)page
{
    if (self.sourceItems.count > 1) {
        if (page == 0) {
            page = self.sourceItems.count - 1;
        } else if (page == self.groupItems.count - 1) {
            page = 0;
        } else {
            page -= 1;
        }
    }
    return page;
}

- (void)deletePhotoWithPage:(NSInteger)page
{
    if (self.sourceItems.count > page) {
        if (self.sourceItems.count == 1) {
            [self dismiss];
        } else {
            [self.sourceItems removeObjectAtIndex:page];
            [self setPhotoItems:[self.sourceItems copy]];
            [self reloadData];
        }
    }
}

- (void)updateGroupItems:(NSArray <PhotoGroupItem *>*)groupItems
{
    if (!groupItems || groupItems.count == 0) {
        return;
    }
    [self setPhotoItems:groupItems];
    [self reloadData];
}

- (void)reloadData
{
    _scrollView.contentSize = CGSizeMake(_scrollView.width * self.groupItems.count, _scrollView.height);
    
    CGFloat offsetX = _scrollView.width * self.currentPage;
    CGFloat contentMaxX = _scrollView.width * (self.groupItems.count - 1);
    if (self.sourceItems.count > 1) {
        if (offsetX == 0) {
            offsetX = (self.groupItems.count - 2) * _scrollView.width;
        } else if (offsetX == contentMaxX) {
            offsetX = _scrollView.width;
        }
    }
    [_scrollView scrollRectToVisible:CGRectMake(offsetX, 0, _scrollView.width, _scrollView.height) animated:NO];
    
    
//    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * self.currentPage, 0, _scrollView.width, _scrollView.height) animated:NO];
    for (PhotoGroupCell *cell in _cells) {
        if (cell.superview ) {
            [cell removeFromSuperview];
            cell.page = -1;
            cell.item = nil;
        }
    }
    _isPresented = YES;
    _isReload = YES;
    [self scrollViewDidScroll:_scrollView];
    _isReload = NO;
    
}

- (void)presentFromCurItem:(NSInteger)curItem
                  fromView:(UIView *)fromView
               toContainer:(UIView *)toContainer
                  animated:(BOOL)animated
                 ompletion:(void (^)(void))completion
{
    _fromView = fromView;
    _toContainerView = toContainer;
    _fromItemIndex = curItem;
    [self presentAnimated:animated completion:completion];
}

- (void)presentFromCurItem:(NSInteger)curItem
               toContainer:(UIView *)toContainer
                  animated:(BOOL)animated
                 ompletion:(void (^)(void))completion
{
    UIView *fromView = [self getThumbViewWithPage:curItem];
    _fromView = fromView;
    _toContainerView = toContainer;
    _fromItemIndex = curItem;
    [self presentAnimated:animated completion:completion];
}

- (void)presentAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    _snapshotImage = [_toContainerView snapshotImageAfterScreenUpdates:NO];
    BOOL fromViewHidden = _fromView.hidden;
    _fromView.hidden = YES;
    _snapshorImageHideFromView = [_toContainerView snapshotImage];
    _fromView.hidden = fromViewHidden;
    
    _background.image = _snapshorImageHideFromView;
    if (_blurEffectBackground) {
        _blurBackground.image = [_snapshorImageHideFromView imageByBlurDark]; //Same to UIBlurEffectStyleDark
    } else {
        _blurBackground.image = [UIImage imageWithColor:[UIColor blackColor]];
    }
    
    CGFloat fromPage = _fromItemIndex + 1;
    
    self.size = _toContainerView.size;
    self.blurBackground.alpha = 0;
    self.pager.alpha = 0;
    self.pager.numberOfPages = self.sourceItems.count;
    self.pager.currentPage = _fromItemIndex;
    [_toContainerView addSubview:self];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.width * self.groupItems.count, _scrollView.height);
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * fromPage, 0, _scrollView.width, _scrollView.height) animated:NO];
    [self scrollViewDidScroll:_scrollView];
    
    [UIView setAnimationsEnabled:YES];
    _fromNavigationBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    
    
    PhotoGroupCell *cell = [self cellForPage:self.currentPage];
    PhotoGroupItem *item = _groupItems[self.currentPage];
    
    if (![item thumbClippedToTop:_fromView]) {
        NSString *imageKey = [[YYWebImageManager sharedManager] cacheKeyForURL:item.largeImageURL];
        if ([[YYWebImageManager sharedManager].cache getImageForKey:imageKey withType:YYImageCacheTypeMemory]) {
            cell.item = item;
        }
    }
    if (!cell.item) {
        cell.imageView.image = [self getThumbImageWithPage:_fromItemIndex];
        [cell resizeSubviewSize];
    }
    
    if ([item thumbClippedToTop:_fromView]) {
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell];
        CGRect originFrame = cell.imageContainerView.frame;
        CGFloat scale = fromFrame.size.width / cell.imageContainerView.width;
        
        cell.imageContainerView.centerX = CGRectGetMidX(fromFrame);
        cell.imageContainerView.height = fromFrame.size.height / scale;
        cell.imageContainerView.layer.transformScale = scale;
        cell.imageContainerView.centerY = CGRectGetMidY(fromFrame);
        
        float oneTime = animated ? 0.25 : 0;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.blurBackground.alpha = 1;
        }completion:NULL];
        
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageContainerView.layer.transformScale = 1;
            cell.imageContainerView.frame = originFrame;
            self.pager.alpha = 1;
        }completion:^(BOOL finished) {
            self.isPresented = YES;
            [self scrollViewDidScroll:self.scrollView];
            self.scrollView.userInteractionEnabled = YES;
            [self hidePager];
            if (completion) completion();
        }];
        
    } else {
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell.imageContainerView];
        
        cell.imageContainerView.clipsToBounds = NO;
        cell.imageView.frame = fromFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        float oneTime = animated ? 0.18 : 0;
        [UIView animateWithDuration:oneTime*2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.blurBackground.alpha = 1;
        }completion:NULL];
        
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageView.frame = cell.imageContainerView.bounds;
            cell.imageView.layer.transformScale = 1.01;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                cell.imageView.layer.transformScale = 1.0;
                self.pager.alpha = 1;
            }completion:^(BOOL finished) {
                cell.imageContainerView.clipsToBounds = YES;
                self.isPresented = YES;
                [self scrollViewDidScroll:self.scrollView];
                self.scrollView.userInteractionEnabled = YES;
                [self hidePager];
                if (completion) completion();
            }];
        }];
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [UIView setAnimationsEnabled:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    NSInteger currentIndex = self.currentIndex;
    PhotoGroupCell *cell = [self cellForPage:self.currentPage];
    UIView *fromView = nil;
    if (_fromItemIndex == currentIndex) {
        fromView = _fromView;
    } else {
        fromView = [self getThumbViewWithPage:currentIndex];
    }
    
    [self cancelAllImageLoad];
    _isPresented = NO;
    BOOL isFromImageClipped = fromView.layer.contentsRect.size.height < 1;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (isFromImageClipped) {
        CGRect frame = cell.imageContainerView.frame;
        cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0);
        cell.imageContainerView.frame = frame;
    }
    cell.progressLayer.hidden = YES;
    [CATransaction commit];
    
    if (fromView == nil) {
        self.background.image = _snapshotImage;
        [UIView animateWithDuration:animated ? 0.25 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0.0;
            self.scrollView.layer.transformScale = 0.95;
            self.scrollView.alpha = 0;
            self.pager.alpha = 0;
            self.blurBackground.alpha = 0;
        }completion:^(BOOL finished) {
            self.scrollView.layer.transformScale = 1;
            [self removeFromSuperview];
            [self cancelAllImageLoad];
            if (completion) completion();
        }];
        return;
    }
    
    if (_fromItemIndex != currentIndex) {
        _background.image = _snapshotImage;
        [_background.layer addFadeAnimationWithDuration:0.25 curve:UIViewAnimationCurveEaseOut];
    } else {
        _background.image = _snapshorImageHideFromView;
    }
    
    
    if (isFromImageClipped) {
        [cell scrollToTopAnimated:NO];
    }
    
    [UIView animateWithDuration:animated ? 0.2 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        self.pager.alpha = 0.0;
        self.blurBackground.alpha = 0.0;
        if (isFromImageClipped) {
            
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell];
            CGFloat scale = fromFrame.size.width / cell.imageContainerView.width * cell.zoomScale;
            CGFloat height = fromFrame.size.height / fromFrame.size.width * cell.imageContainerView.width;
            if (isnan(height)) height = cell.imageContainerView.height;
            
            cell.imageContainerView.height = height;
            cell.imageContainerView.center = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMinY(fromFrame));
            cell.imageContainerView.layer.transformScale = scale;
            
        } else {
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell.imageContainerView];
            cell.imageContainerView.clipsToBounds = NO;
            cell.imageView.contentMode = fromView.contentMode;
            cell.imageView.frame = fromFrame;
        }
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:animated ? 0.15 : 0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            [self removeFromSuperview];
            if (completion) completion();
        }];
    }];
    
    
}

- (void)dismiss {
    [self dismissAnimated:YES completion:^{
        
    }];
}


- (void)cancelAllImageLoad {
    [_cells enumerateObjectsUsingBlock:^(PhotoGroupCell *cell, NSUInteger idx, BOOL *stop) {
        [cell.imageView yy_cancelCurrentImageRequest];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat floatPage = _scrollView.contentOffset.x / _scrollView.width;
    NSInteger page = floatPage + 0.5;
    
    NSInteger allCount =  _groupItems.count;
    NSInteger curIndex = page;
    curIndex = curIndex < 0  ? 0  : curIndex >= allCount ? allCount - 1 : curIndex;
    
    if (!_isReload) {
        [self updateCellsForReuse];
    }
    
    for (NSInteger i = page - 1; i <= page + 1; i++) { // preload left and right cell
        if (i >= 0 && i < self.groupItems.count) {
            PhotoGroupCell *cell = [self cellForPage:i];
            if (!cell) {
                PhotoGroupCell *cell = [self dequeueReusableCell];
                cell.page = i;
                cell.left = (self.width + kPadding) * i + kPadding / 2;
                
                if (_isPresented) {
                    cell.item = self.groupItems[i];
                }
                [self.scrollView addSubview:cell];
            } else {
                if (_isPresented && !cell.item) {
                    cell.item = self.groupItems[i];
                }
            }
        }
    }
    
    _currentIndex = 0;
 
    if (self.sourceItems.count > 1) {
        if (curIndex == 0) {
            _currentIndex = self.sourceItems.count - 1;
        } else if (curIndex == allCount - 1) {
           _currentIndex = 0;
        } else {
            _currentIndex = curIndex - 1;
        }
    }
    
    if (!_headerView.hidden) {
        NSInteger index = 1;
        if (self.sourceItems.count > 1) {
            if (curIndex == 0) {
                index = self.sourceItems.count;
            } else if (curIndex == allCount - 1) {
                index = 1;
            } else {
                index = curIndex;
            }
        }
        _headerView.titleLabel.text = [NSString stringWithFormat:@"%@/%@", @(index), @(self.sourceItems.count)];
    }
    
    if (!_pager.hidden) {
        _pager.currentPage = _currentIndex;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            self.pager.alpha = 1;
        }completion:^(BOOL finish) {
        }];
    }
   
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self hidePager];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self hidePager];
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat contentMaxX = scrollView.width * (self.groupItems.count - 1);
    if (self.sourceItems.count > 1) {
        if (offsetX == 0) {
            [self.scrollView setContentOffset:CGPointMake((self.groupItems.count - 2) * scrollView.width, 0) animated:NO];
        } else if (offsetX == contentMaxX) {
            [self.scrollView setContentOffset:CGPointMake(scrollView.width, 0) animated:NO];
        }
    }
    
}


- (void)hidePager {
    if (_pager.hidden) {
        return;
    }
    [UIView animateWithDuration:0.3 delay:0.8 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.pager.alpha = 0;
    }completion:^(BOOL finish) {
    }];
}

/// enqueue invisible cells for reuse
- (void)updateCellsForReuse {
    for (PhotoGroupCell *cell in _cells) {
        if (cell.superview) {
            if (cell.left > _scrollView.contentOffset.x + _scrollView.width * 2||
                cell.right < _scrollView.contentOffset.x - _scrollView.width) {
                [cell removeFromSuperview];
                cell.page = -1;
//                cell.item = nil;
            }
        }
    }
}

/// dequeue a reusable cell
- (PhotoGroupCell *)dequeueReusableCell {
    PhotoGroupCell *cell = nil;
    for (cell in _cells) {
        if (!cell.superview) {
            return cell;
        }
    }
    
    cell = [PhotoGroupCell new];
    cell.frame = self.bounds;
    cell.imageContainerView.frame = self.bounds;
    cell.imageView.frame = cell.bounds;
    cell.cellDelegate = self;
    cell.page = -1;
    cell.item = nil;
    [_cells addObject:cell];
    return cell;
}

#pragma mark - PhotoGroupCellDelegate
- (UIImage *)cell:(PhotoGroupCell *)cell getImageWithPage:(NSInteger)page
{
    NSInteger index = [self pageCoverIndex:page];
    return [self getThumbImageWithPage:index];
}

/// get the cell for specified page, nil if the cell is invisible
- (PhotoGroupCell *)cellForPage:(NSInteger)page {
    for (PhotoGroupCell *cell in _cells) {
        if (cell.page == page) {
            return cell;
        }
    }
    return nil;
}

- (NSInteger)currentPage {
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    if (page >= _groupItems.count) page = (NSInteger)_groupItems.count - 1;
    if (page < 0) page = 0;
    return page;
}

- (void)showHUD:(NSString *)msg {
    if (!msg.length) return;
    UIFont *font = [UIFont systemFontOfSize:17];
    CGSize size = [msg sizeForFont:font size:CGSizeMake(200, 200) mode:NSLineBreakByCharWrapping];
    UILabel *label = [UILabel new];
    label.size = CGSizePixelCeil(size);
    label.font = font;
    label.text = msg;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    
    UIView *hud = [UIView new];
    hud.size = CGSizeMake(label.width + 20, label.height + 20);
    hud.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.650];
    hud.clipsToBounds = YES;
    hud.layer.cornerRadius = 8;
    
    label.center = CGPointMake(hud.width / 2, hud.height / 2);
    [hud addSubview:label];
    
    hud.center = CGPointMake(self.width / 2, self.height / 2);
    hud.alpha = 0;
    [self addSubview:hud];
    
    [UIView animateWithDuration:0.4 animations:^{
        hud.alpha = 1;
    }];
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.4 animations:^{
            hud.alpha = 0;
        } completion:^(BOOL finished) {
            [hud removeFromSuperview];
        }];
    });
}

- (void)doubleTap:(UITapGestureRecognizer *)g {
    if (!_isPresented) return;
    PhotoGroupCell *tile = [self cellForPage:self.currentPage];
    if (tile) {
        if (tile.zoomScale > 1) {
            [tile setZoomScale:1 animated:YES];
        } else {
            CGPoint touchPoint = [g locationInView:tile.imageView];
            CGFloat newZoomScale = tile.maximumZoomScale;
            CGFloat xsize = self.width / newZoomScale;
            CGFloat ysize = self.height / newZoomScale;
            [tile zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        }
    }
}

- (void)longPress {
    if (!_isPresented) return;
    
    PhotoGroupCell *tile = [self cellForPage:self.currentPage];
    if (!tile.imageView.image) return;
    
    // try to save original image data if the image contains multi-frame (such as GIF/APNG)
    id imageItem = [tile.imageView.image yy_imageDataRepresentation];
    YYImageType type = YYImageDetectType((__bridge CFDataRef)(imageItem));
    if (type != YYImageTypePNG &&
        type != YYImageTypeJPEG &&
        type != YYImageTypeGIF) {
        imageItem = tile.imageView.image;
    }
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[imageItem] applicationActivities:nil];
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
        activityViewController.popoverPresentationController.sourceView = self;
    }
    
    UIViewController *toVC = self.toContainerView.viewController;
    if (!toVC) toVC = self.viewController;
    [toVC presentViewController:activityViewController animated:YES completion:nil];
}

- (void)pan:(UIPanGestureRecognizer *)g {
//    PhotoGroupCell *tile = [self cellForPage:self.currentPage];
//    if (tile && tile.zoomScale != 1) {
//        return;
//    }
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            self.scrollView.transform = CGAffineTransformIdentity;
            NSLog(@"scrollView orign center : %@, frame : %@", NSStringFromCGPoint(_scrollView.center), NSStringFromCGRect(self.scrollView.frame));
            if (_isPresented) {
                _panGestureBeginPoint = [g locationInView:self];
            } else {
                _panGestureBeginPoint = CGPointZero;
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            CGFloat deltaX = p.x - _panGestureBeginPoint.x;
//            _scrollView.top = deltaY;
            
            CGFloat alphaDelta = 300;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 100) / alphaDelta;
            alpha = YY_CLAMP(alpha, 0, 1);
            
//            if (deltaY > 0) {
            CGFloat scale =  (ScreenHeight - fabs(deltaY)) / ScreenHeight;
                CGPoint moveP = [g translationInView:self];
            
//            scale = scale > 0.6 ? scale : 0.6;
            CGFloat tx = moveP.x; // p.x - _panGestureBeginPoint.x; // moveP.x;// + (1 - scale) * ScreenWidth * 0.5; //* moveScale;
            CGFloat ty = moveP.y;// p.y - _panGestureBeginPoint.y; // moveP.y; //+ (1 - scale) * ScreenHeight * 0.5 ; //* moveScale;
            
//            }
            
//            CGPoint scrollViewPanPoint = CGPointMake(_panGestureBeginPoint.x * scale, _panGestureBeginPoint.y * scale);
////            CGPoint coverPoint = [self.scrollView convertPoint:scrollViewPanPoint fromView:self];
//            if (deltaY > 0) {
//                ty -= (0.5 * ScreenHeight * (1 - scale));
//            } else {
//                ty += (0.5 * ScreenHeight * (1 - scale));
//            }
//            if (deltaX > 0) {
//                tx -= (0.5 * ScreenWidth * (1 - scale));
//            } else {
//                tx += (0.5 * ScreenWidth * (1 - scale));
//            }
            
            
            
//            CGPoint newCenter = CGRectGetCenter(self.scrollView.frame);
            
            NSLog(@"\n scrollView center : %@, \n movepoint : %@, \n frame : %@ \n tx = %f, \n ty = %f", NSStringFromCGPoint(CGRectGetCenter(self.scrollView.frame)), NSStringFromCGPoint(moveP), NSStringFromCGRect(self.scrollView.frame), tx, ty);
            
            
            
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                self.blurBackground.alpha = alpha;
                self.pager.alpha = alpha;
                self.scrollView.transform = CGAffineTransformMake(scale, 0, 0, scale, tx, ty);
            } completion:nil];
            
        } break;
        case UIGestureRecognizerStateEnded: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            // 手指移动速度, fasb(v.y) > fabs(v.x)竖直方向移动,反之水方向移动
            CGPoint v = [g velocityInView:self];
            // 手指在self上的位置
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                /*
                [self cancelAllImageLoad];
                
                _isPresented = NO;
                [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:UIStatusBarAnimationFade];
                
                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = (moveToTop ? _scrollView.bottom : self.height - _scrollView.top) / vy;
                duration *= 0.8;
                duration = YY_CLAMP(duration, 0.05, 0.3);
                
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.blurBackground.alpha = 0;
                    self.pager.alpha = 0;
                    if (moveToTop) {
                        self.scrollView.bottom = 0;
                    } else {
                        self.scrollView.top = self.height;
                    }
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
                
                _background.image = _snapshotImage;
                [_background.layer addFadeAnimationWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut];
                 */
                [self dismissAnimated:YES completion:^{
                    
                }];
                
            } else {
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
//                    self.scrollView.top = 0;
                    self.blurBackground.alpha = 1;
                    self.pager.alpha = 1;
                    self.scrollView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    
                }];
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
//            _scrollView.top = 0;
            _blurBackground.alpha = 1;
            self.scrollView.transform = CGAffineTransformIdentity;
        }
        default:break;
    }
}

- (void)hiddenPageControl:(BOOL)isHidden
{
    _pager.hidden = isHidden;
}

- (void)hiddenTitle:(BOOL)isHidden
{
    self.headerView.titleLabel.hidden = isHidden;
}

- (void)hiddenRightBtn:(BOOL)isHidden
{
    self.headerView.rightBtn.hidden = isHidden;
}


- (void)dealloc
{
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
}


@end
