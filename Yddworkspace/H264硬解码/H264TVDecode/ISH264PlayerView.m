//
//  ISH264PlayerView.m
//  ViewsTalk
//
//  Created by ispeak on 2018/1/17.
//  Copyright © 2018年 ydd. All rights reserved.
//

#import "ISH264PlayerView.h"
#import "ScreenRecorder.h"
@interface ISH264PlayerView ()

@property(nonatomic, strong) ISH264Player* player;
@property(nonatomic, assign) CGRect orignRect;
@property(nonatomic, strong) UIButton* fullButton;
@end

@implementation ISH264PlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
  [super layoutSubviews];
  _player.frame = self.bounds;
  _loadingView.frame = self.bounds;
  NSLog(@"_loadingView frame : %@", NSStringFromCGRect(_loadingView.frame));
}

#pragma mark 视频播放画面相关 {
- (void)setVideoContentModel:(ISVideoContentModel)model {
  _player.videoModel = model;
}

- (void)playForPixelBuffer:(CVPixelBufferRef)buffer {

  [_player playerForPixelBuffer:buffer];
  [[ScreenRecorder shareRecorder] writerVideoBuffer:buffer];
}


- (UIImage *)imageFromCVPixelBufferRef0:(CVPixelBufferRef)pixelBuffer{
  // MUST READ-WRITE LOCK THE PIXEL BUFFER!!!!
  CVPixelBufferLockBaseAddress(pixelBuffer, 0);
  CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
  CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
  CIContext *temporaryContext = [CIContext contextWithOptions:nil];
  CGImageRef videoImage = [temporaryContext
                           createCGImage:ciImage
                           fromRect:CGRectMake(0, 0,
                                               CVPixelBufferGetWidth(pixelBuffer),
                                               CVPixelBufferGetHeight(pixelBuffer))];
  
  UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
  CGImageRelease(videoImage);
//  CVPixelBufferRelease(pixelBuffer);
  return uiImage;
}


- (CGImageRef)getImageWidth:(CVPixelBufferRef)imageBuffer
{
  CVPixelBufferLockBaseAddress(imageBuffer, 0);
  // Get the number of bytes per row for the pixel buffer
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  // Get the pixel buffer width and height
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);
  // Generate image to edit
  unsigned char* pixel =
  (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(
                                               pixel, width, height, 8, bytesPerRow, colorSpace,
                                               kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
  CGImageRef image = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
  UIGraphicsEndImageContext();
  return image;
}

- (void)resetPlay {
  _loadingView.hidden = NO;
  [_player resetRenderBuffer];
}

- (void)clearBuff {
  [_player clearFrame];
}

- (void)appEnterBackgroundGlFinish {
  [_player playGlFinish];
}
#pragma mark }

- (void)showLoadingView:(NSString*)tipStr animation:(BOOL)animation {
  if (self.loadingView.hidden) {
    self.loadingView.hidden = NO;
  }
  if (animation) {
    [self.loadingView startLoading:tipStr];
  } else {
    [self.loadingView stopLoading];
  }
}

- (void)hiddenLoadingView {
  [self.loadingView stopLoading];
  if (!self.loadingView.hidden) {
    self.loadingView.hidden = YES;
  }
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _player = [[ISH264Player alloc] initWithFrame:self.bounds];
    _orignRect = frame;
    [self.layer addSublayer:_player];
//    [self addSubview:self.imageView];
    [self addSubview:self.loadingView];
  }
  return self;
}

- (ISPlayerLoadingView*)loadingView {
  if (!_loadingView) {
    //    //  视频显示UIImageView
    _loadingView = [[ISPlayerLoadingView alloc] initWithFrame:self.bounds];
  }
  return _loadingView;
}


- (UIButton*)fullButton {
  if (!_fullButton) {
    _fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fullButton setTitle:@"半屏" forState:UIControlStateNormal];
    [_fullButton addTarget:self
                    action:@selector(fullButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_fullButton];
    _fullButton.frame = CGRectMake(self.frame.size.width - 56,
                                   self.frame.size.height - 56, 46, 46);
    _fullButton.transform =
        CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
  }
  return _fullButton;
}

- (void)changePlayerFrameForFullScreen:(BOOL)isFull {
  if (_orignRect.size.width == 0 || _orignRect.size.height == 0) {
    return;
  }
  if (isFull) {
    CGFloat videoRote = _orignRect.size.width / _orignRect.size.height;
    CGFloat screenRote = ScreenWidth / ScreenHeight;
    CGFloat fullH = 0;
    CGFloat fullW = 0;
    if (videoRote > screenRote) {
      fullH = ScreenHeight;
      fullW = videoRote * fullH;
    } else {
      fullW = ScreenWidth;
      fullH = ScreenWidth / videoRote;
    }
    self.frame = CGRectMake((ScreenWidth - fullW) * 0.5,
                            (ScreenHeight - fullH) * 0.5, fullW, fullH);
    self.fullButton.frame = CGRectMake(
        -self.frame.origin.x + 10, self.frame.origin.y + fullH - 56, 46, 46);
    [UIView animateWithDuration:1.0
                     animations:^{
                       _player.transform = CATransform3DRotate(
                           CATransform3DIdentity, M_PI_2, 0, 0, 1);
                     }];
    self.fullButton.hidden = NO;

  } else {
    self.frame = _orignRect;
    [UIView animateWithDuration:1.0
                     animations:^{
                       _player.transform = CATransform3DRotate(
                           CATransform3DIdentity, 0, 0, 0, 1);
                     }];
    self.fullButton.hidden = YES;
  }
}

- (void)fullButtonAction:(UIButton*)btn {
//  if ([_delegate respondsToSelector:@selector(quiteFullScreen)]) {
//    [_delegate quiteFullScreen];
//  }
  btn.selected = !btn.selected;
  if (btn.selected) {
    [[ScreenRecorder shareRecorder] startWriter];
  } else {
    [[ScreenRecorder shareRecorder] stopWriter];
  }
  
}

@end
