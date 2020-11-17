//
//  DownLoadAnimationViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/10/27.
//  Copyright © 2020 QH. All rights reserved.
//

#import "DownLoadAnimationViewController.h"
#import "MenueScrollView.h"

@interface ContentCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;

@end

@implementation ContentCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor greenColor];
    }
    return _label;
}

@end

@interface DownLoadAnimationViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, MenueScrollViewDelegate>

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) CAShapeLayer *shapeLayer2;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) UISlider *slider;

@property (nonatomic, strong) MenueScrollView *menueView;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation DownLoadAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createShapeLayer1];
    [self createShapeLayer2];
    [self createMaskLayer];
    
    
    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(20, 300, 200, 50)];
    [self.view addSubview:self.slider];
    self.slider.maximumValue = 1.0;
    self.slider.minimumValue = 0.0;
    [self.slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    self.menueView = [[MenueScrollView alloc] init];
    _menueView.leftSpace = 10;
    _menueView.rightSpace = 10;
    _menueView.space = 10;
    _menueView.delegate = self;
    [self.view addSubview:self.menueView];
    [self.menueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.slider.mas_bottom).mas_offset(20);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    NSMutableArray *mutArr = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        [mutArr addObject:i % 2 == 0 ? @"九鼎记" : @"紫川"];
    }
    self.menueView.menues = mutArr;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.menueView.mas_bottom).mas_offset(10);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btn.mas_bottom).mas_offset(20);
        make.left.mas_equalTo(self.menueView.mas_left);
        make.width.height.mas_equalTo(200);
    }];
}

- (void)btnAction
{
    NSInteger index = arc4random() % self.menueView.menues.count;
    NSLog(@" menue index : %ld ", (long)index);
    self.menueView.seletcedIndex = index;
}

- (UIBezierPath *)createPathSize:(CGFloat)size startAngle:(CGFloat)angle
{
    CGFloat radius = size * 0.5;
    CGPoint center = CGPointMake(radius, radius);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:center];
    [path addLineToPoint:CGPointMake(radius, 0)];
    
    [path addArcWithCenter:center radius:radius startAngle:M_PI_2 * 3 + M_PI * 2 * angle endAngle:M_PI_2 * 3 + M_PI * 2 clockwise:YES];
    [path closePath];
    return path;
}

- (UIBezierPath *)createPathSize:(CGFloat)size endAngle:(CGFloat)angle
{
    CGFloat radius = size * 0.5;
    CGPoint center = CGPointMake(radius, radius);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:center];
    [path addLineToPoint:CGPointMake(radius, 0)];
    
    [path addArcWithCenter:center radius:radius startAngle:M_PI_2 * 3 endAngle:M_PI_2 * 3 + M_PI * 2 * angle clockwise:YES];
    [path closePath];
    return path;
}


- (void)sliderAction:(UISlider *)slider
{
    self.shapeLayer.path = [self createPathSize:100 endAngle:slider.value].CGPath;
    self.shapeLayer2.path = [self createPathSize:100 endAngle:slider.value].CGPath;
    self.maskLayer.path = [self createPathSize:100 endAngle:slider.value].CGPath;
    
    self.menueView.scrollIndex = slider.value * 3;
    
}

- (void)createShapeLayer1
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 100, 100)];
    [self.view addSubview:bgView];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 50;
    bgView.backgroundColor = [UIColor grayColor];
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = bgView.bounds;
    self.shapeLayer.fillColor = [UIColor cyanColor].CGColor;
    [bgView.layer addSublayer:self.shapeLayer];
    
    self.shapeLayer.path = [self createPathSize:100 endAngle:0].CGPath;
}

- (void)createShapeLayer2
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(200, 100, 100, 100)];
    [self.view addSubview:bgView];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 50;
    bgView.backgroundColor = [UIColor grayColor];
    bgView.layer.contents = (id)[UIImage imageNamed:@"0.jpg"].CGImage;
    bgView.layer.contentsGravity = kCAGravityResizeAspectFill;
    
    
    UIView *coverView = [[UIView alloc] initWithFrame:bgView.bounds];
    coverView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.8];
    [bgView addSubview:coverView];
    
    self.shapeLayer2 = [CAShapeLayer layer];
    self.shapeLayer2.frame = coverView.bounds;
    self.shapeLayer2.fillColor = [UIColor clearColor].CGColor;
    coverView.layer.mask = self.shapeLayer2;
    
    self.shapeLayer2.path = [self createPathSize:100 endAngle:0].CGPath;
}

- (void)createMaskLayer
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(20, 400, 100, 100)];
    [self.view addSubview:bgView];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 50;
    bgView.backgroundColor = [UIColor grayColor];
    bgView.layer.contents = (id)[UIImage imageNamed:@"0.jpg"].CGImage;
    bgView.layer.contentsGravity = kCAGravityResizeAspectFill;
    
    self.maskLayer = [CAShapeLayer layer];
    self.maskLayer.frame = bgView.bounds;
    self.maskLayer.fillColor = [UIColor grayColor].CGColor;
    bgView.layer.mask = self.maskLayer;
    
    self.maskLayer.path = [self createPathSize:100 endAngle:0].CGPath;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(200, 200);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor grayColor];
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[ContentCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.menueView.menues.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    self.menueView.scrollIndex = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    self.menueView.seletcedIndex = index;
}

- (void)menue:(MenueScrollView *)view selectedIndex:(NSInteger)index
{
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self.collectionView setContentOffset:CGPointMake(index * 200, 0)];
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
