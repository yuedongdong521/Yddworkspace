//
//  ISLookUpImageCell.m
//  Yddworkspace
//
//  Created by ydd on 2018/7/20.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "ISLookUpImageCell.h"
#import "TestImageModel.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@interface ISLookUpImageCell()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIScrollView *contentScrollView;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) NSString *qrCodeInfo;


@end

@implementation ISLookUpImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self.contentView addSubview:self.contentScrollView];
//    self.contentScrollView.userInteractionEnabled = NO;
//    [self.contentView addGestureRecognizer:self.contentScrollView.panGestureRecognizer];
//    [self.contentView addGestureRecognizer:self.contentScrollView.pinchGestureRecognizer];
    [self.contentScrollView addSubview:self.imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self.imageView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubletapAction:)];
    doubletap.numberOfTapsRequired = 2;
    doubletap.delegate = self;
    [self.imageView addGestureRecognizer:doubletap];
    
    [tap requireGestureRecognizerToFail:doubletap];
    
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesAction:)];
    longGes.minimumPressDuration = 1;
    [self.imageView addGestureRecognizer:longGes];
    
  }
  return self;
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
  if ([_delegate respondsToSelector:@selector(releaseLookUpViewDelegate)]) {
    [_delegate releaseLookUpViewDelegate];
  }
}

- (void)doubletapAction:(UITapGestureRecognizer *)tap
{
  self.contentScrollView.zoomScale = self.contentScrollView.zoomScale != 2 ? 2 : 1;
}

- (void)longGesAction:(UILongPressGestureRecognizer *)longGes
{
  if (longGes.state == UIGestureRecognizerStateBegan) {
    NSLog(@"二维码信息 :%@", _qrCodeInfo);
  }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  NSLog(@"gestureRecognizer : %@", NSStringFromClass([touch.view class]));
  if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIImageView"]) {
      return YES;
    }
  }
  return NO;
}

- (UIScrollView *)contentScrollView
{
  if (!_contentScrollView) {
    _contentScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.zoomScale = 2.0;
    _contentScrollView.minimumZoomScale = 0.5;
    _contentScrollView.maximumZoomScale = 2.0;
    _contentScrollView.delegate = self;
  }
  return _contentScrollView;
}

- (UIImageView *)imageView
{
  if (!_imageView) {
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
  }
  return _imageView;
}

- (void)setImageModel:(TestImageModel *)imageModel
{
  
  _contentScrollView.zoomScale = 1.0;
  if (_imageModel && [_imageModel.urlStr isEqualToString:imageModel.urlStr]) {
    return;
  }
  _imageModel = imageModel;
  __weak typeof(self) weakself = self;
  _qrCodeInfo = @"";
  [_imageView sd_setImageWithURL:[NSURL URLWithString:imageModel.urlStr]  placeholderImage:[UIImage imageNamed:@"0.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    [NSThread detachNewThreadSelector:@selector(scanCodeImage:) toTarget:weakself withObject:image];
//    [weakself scanCodeImage];
  }];
  CGFloat cellWidth = self.frame.size.width;
  CGFloat cellHeight = self.frame.size.height;
  CGFloat imageWidth = _imageModel.size.width;
  CGFloat imageHeight = _imageModel.size.height;
  CGFloat imageRate = imageWidth / imageHeight;
  CGFloat cellRate = cellWidth / cellHeight;
  if (imageRate > cellRate) {
    imageWidth = cellWidth;
    imageHeight = cellWidth / imageRate;
  } else {
    imageHeight = cellHeight;
    imageWidth = cellHeight * imageRate;
  }
  
  self.imageView.frame = CGRectMake((cellWidth - imageWidth) * 0.5, (cellHeight - imageHeight) * 0.5, imageWidth, imageHeight);
  self.contentScrollView.contentSize = self.imageView.frame.size;
  
}

- (void)scanCodeImage:(UIImage *)image {
  //
  @synchronized(self) {
    if (!image) {
      return;
    }
    CIContext* context = [CIContext
                          contextWithOptions:
                          [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                      forKey:kCIContextUseSoftwareRenderer]];
    if (!context) {
      return;
    }
    CIDetector* detector = [CIDetector
                            detectorOfType:CIDetectorTypeQRCode
                            context:context
                            options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    if (!detector) {
      return;
    }
    CIImage* ciImage = [CIImage imageWithCGImage:image.CGImage];
    if (!ciImage) {
      return;
    }
    NSArray* features = [detector featuresInImage:ciImage];
    if (!features) {
      return;
    }
    CIQRCodeFeature* feature = [features firstObject];
    if (!feature) {
      return;
    }
    _qrCodeInfo = feature.messageString;
    NSLog(@"二维码信息 %@", _qrCodeInfo);
  }
}


- (void)resetImageZoomScale
{
  if (self.contentScrollView.zoomScale != 1) {
    self.contentScrollView.zoomScale = 1;
  }
}

#pragma mark <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return scrollView.subviews.firstObject;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
  CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
  xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
  
  ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
  _imageView.center = CGPointMake(xcenter, ycenter);
  
}


@end
