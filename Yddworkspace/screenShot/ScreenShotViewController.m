
//
//  ScreenShotViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/12/5.
//  Copyright © 2018 QH. All rights reserved.
//

#import "ScreenShotViewController.h"
#import "LoadPickerImageTool.h"
#import "UIImage+ydd.h"


@interface ScreenShotViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *imageMutArr;

@property (nonatomic, strong) UIImageView *qrImageView;
@property (nonatomic, strong) UILabel *label;



@end

@implementation ScreenShotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.scrollView];
  [self.scrollView addSubview:self.imageView];
  
  [self.view addSubview:self.tableView];
  [self.tableView reloadData];
  
  [self.view addSubview:self.qrImageView];
  self.qrImageView.image = [UIImage createQrCodeImageWithQrContent:@"大风起兮，云飞扬，威震海内兮,归故乡" qrSize:200 qrLevel:@"L" logoImage:[UIImage imageNamed:@"1yasuo.jpg"] logoSizeScale:0.1];
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.frame = CGRectMake(20, 450, 100, 50);
  [button setTitle:@"截图" forState:UIControlStateNormal];
  [button addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  
  [self.view addSubview:self.label];
  self.label.frame = CGRectMake(20, 520, 300, 100);
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTalkScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
  
  
  

}

- (void)userDidTalkScreenshot:(NSNotification *)notify
{
  NSLog(@"object : %@,\n userInfo: %@", notify.object, notify.userInfo);
}

- (NSMutableArray *)imageMutArr
{
  if (!_imageMutArr) {
    _imageMutArr = [NSMutableArray array];
  }
  return _imageMutArr;
}

- (UITableView *)tableView
{
  if (!_tableView) {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 100, 300, 300) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
  }
  return _tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  cell.imageView.image = [UIImage imageNamed:@"0.jpg"];
  cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
  return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 20;
}

- (void)screenShotTableView
{
  CGRect tableViewFrame = self.tableView.frame;
  CGPoint contentOffset = self.tableView.contentOffset;
  self.tableView.frame = CGRectMake(0, 0, tableViewFrame.size.width, self.tableView.contentSize.height);
  self.tableView.contentOffset = CGPointZero;
  UIImage *image = [self screenShotView:self.tableView];
  self.tableView.frame = tableViewFrame;
  self.tableView.contentOffset = contentOffset;
  UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)btnAction
{
  [self screenShotTableView];
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
  NSString *msg = nil ;
  if(error != NULL){
    msg = @"保存图片失败" ;
  }else{
    msg = @"保存图片成功" ;
  }
  NSLog(@"%@", msg);
}

- (UIScrollView *)scrollView
{
  if (!_scrollView) {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 100, 300, 300)];
    _scrollView.contentSize = CGSizeMake(300, 900);
    _scrollView.backgroundColor = [UIColor grayColor];
  }
  return _scrollView;
}

- (UIImageView *)imageView
{
  if (!_imageView) {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 900)];
    _imageView.image = [UIImage imageNamed:@"0.jpg"];
  }
  return _imageView;
}

- (UIImageView *)qrImageView
{
  if (!_qrImageView) {
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 300, 300)];
    _qrImageView.backgroundColor = [UIColor cyanColor];
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesAction:)];
    [_qrImageView addGestureRecognizer:longGes];
    _qrImageView.userInteractionEnabled = YES;
  }
  return _qrImageView;
}

- (void)longGesAction:(UILongPressGestureRecognizer *)longges
{
  if (longges.state == UIGestureRecognizerStateBegan) {
    self.label.text = [UIImage scanCodeImage:self.qrImageView.image];
  }
}

- (UIImage *)screenShotView:(UIView *)view
{
  UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
  [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

- (UIImage*)mergeImageWithImages:(NSArray<UIImage *>*)images
{
  CGFloat locationX = 0;
  CGFloat locationY = 0;
  CGSize mergedSize = CGSizeZero;
  
  for (int i = 0; i < images.count; i++) {
    UIImage *image = images[i];
    mergedSize = CGSizeMake(MAX(mergedSize.width, image.size.width), mergedSize.height + image.size.height);
  }
  UIGraphicsBeginImageContext(mergedSize);
  for (int i = 0; i < images.count; i++) {
    UIImage *image = images[i];
    [image drawInRect:CGRectMake(locationX, locationY, image.size.width, image.size.height)];
    locationY += image.size.height;
  }
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

- (NSMutableAttributedString *)getAttributedString:(NSString *)content image:(UIImage *)image font:(UIFont *)font {
  NSMutableAttributedString *contentAtt = [[NSMutableAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName : font}];
  NSTextAttachment *imageMent = [[NSTextAttachment alloc] init];
  imageMent.image = image;
  CGFloat paddingTop = font.lineHeight - font.pointSize;
  imageMent.bounds = CGRectMake(0, -paddingTop, font.lineHeight, font.lineHeight);
  NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment:imageMent];
  [contentAtt appendAttributedString:imageAtt];
  return contentAtt;
}

- (UILabel *)label
{
  if (!_label) {
    _label = [[UILabel alloc] init];
    _label.numberOfLines = 0;
  }
  return _label;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
