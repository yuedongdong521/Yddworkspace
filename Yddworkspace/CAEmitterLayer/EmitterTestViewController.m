//
//  EmitterTestViewController.m
//  AnimationDemo
//
//  Created by lotus on 2017/12/5.
//  Copyright © 2017年 李灿荣. All rights reserved.
//

#import "EmitterTestViewController.h"

@interface EmitterTestViewController ()
{
    CAEmitterLayer *_testEmitter;
}
@property (nonatomic, strong) UISegmentedControl *shapeSegmentView;
@property (nonatomic, strong) UISegmentedControl *modeSegmentView;

@property (nonatomic, strong) UISegmentedControl *degreeSegmentView;
@property (nonatomic, strong) UISlider *slider;
@end

@implementation EmitterTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.slider];
    self.slider.frame = CGRectMake(20, ScreenHeight - 300, ScreenWidth - 40, 50);
    
    [self.view addSubview:self.shapeSegmentView];
    [self.view addSubview:self.degreeSegmentView];
    [self.view addSubview:self.modeSegmentView];
    
    self.shapeSegmentView.frame = CGRectMake(20, ScreenHeight - 230, ScreenWidth - 40, 50);
    self.degreeSegmentView.frame = CGRectMake(20, ScreenHeight - 170, ScreenWidth - 40, 50);
    self.modeSegmentView.frame = CGRectMake(20, ScreenHeight - 110, ScreenWidth - 40, 50);
    
    [self configureTestEmitter];
    
    
}

- (void)configureTestEmitter{
    CAEmitterLayer *tmpEmitter = [CAEmitterLayer layer];
    tmpEmitter.frame = self.view.bounds;
    tmpEmitter.emitterPosition = self.view.center;
    
    tmpEmitter.emitterShape = kCAEmitterLayerPoint;
    //    tmpEmitter.emitterMode = kCAEmitterLayerOutline;
    tmpEmitter.renderMode = kCAEmitterLayerAdditive;
    
    tmpEmitter.emitterSize = CGSizeMake(100, 100);
    _testEmitter = tmpEmitter;
    [self.view.layer addSublayer:_testEmitter];
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.name = @"testCell";
    cell.birthRate = 20;
    
    cell.lifetime = 3.0;
    cell.lifetimeRange = 0.35;
    
    cell.velocity = 80;
//        cell.yAcceleration = -100;
    
//    cell.emissionLatitude = M_PI_2;
//    cell.emissionLongitude = M_PI_2;
//        cell.emissionRange = M_PI_4;
    
    cell.contents = (id)[UIImage imageNamed:@"dot"].CGImage;
    
    _testEmitter.emitterCells = @[cell];
}

#pragma mark - event methods

- (void)shapeAction:(UISegmentedControl *)sender {
    
    NSInteger index = sender.selectedSegmentIndex;
    
    switch (index) {
        case 0:_testEmitter.emitterShape = kCAEmitterLayerPoint;
            break;
        case 1:_testEmitter.emitterShape = kCAEmitterLayerLine;
            break;
        case 2:_testEmitter.emitterShape = kCAEmitterLayerRectangle;
            break;
        case 3:_testEmitter.emitterShape = kCAEmitterLayerCuboid;
            break;
        case 4:_testEmitter.emitterShape = kCAEmitterLayerCircle;
            break;
        case 5:_testEmitter.emitterShape = kCAEmitterLayerSphere;
            break;
    }
    
    
}
- (void)modeAction:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    
    switch (index) {
        case 0:_testEmitter.emitterMode = kCAEmitterLayerPoints;
            break;
        case 1:_testEmitter.emitterMode = kCAEmitterLayerOutline;
            break;
        case 2:_testEmitter.emitterMode = kCAEmitterLayerSurface;
            break;
        case 3:_testEmitter.emitterMode = kCAEmitterLayerVolume;
            break;
    }
}
- (void)degreeAction:(UISegmentedControl *)sender {
    
    NSInteger index = sender.selectedSegmentIndex;
    
    switch (index) {
        case 0:[_testEmitter setValue:@(0) forKeyPath:@"emitterCells.testCell.emissionLongitude"];
            break;
        case 1:[_testEmitter setValue:@(M_PI_2) forKeyPath:@"emitterCells.testCell.emissionLongitude"];
            break;
        case 2:[_testEmitter setValue:@(M_PI) forKeyPath:@"emitterCells.testCell.emissionLongitude"];
            break;
        case 3:[_testEmitter setValue:@(M_PI_2 * 3) forKeyPath:@"emitterCells.testCell.emissionLongitude"];
            break;
    }
}

- (void)sliderAction:(UISlider *)sender {
    float value = sender.value / 100;
    [_testEmitter setValue:@(value * 20)   forKeyPath:@"emitterCells.testCell.birthRate"];
}

- (UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        _slider.maximumValue = 100;
        _slider.minimumValue = 0;
    }
    return _slider;
}


- (UISegmentedControl *)shapeSegmentView
{
    if (!_shapeSegmentView) {
        _shapeSegmentView = [[UISegmentedControl alloc] initWithItems:@[@"point", @"line", @"rectangle", @"cuboid", @"circle", @"sphere"]];
        [_shapeSegmentView addTarget:self action:@selector(shapeAction:) forControlEvents:UIControlEventValueChanged];
        _shapeSegmentView.selectedSegmentIndex = 0;
    }
    return _shapeSegmentView;
}

- (UISegmentedControl *)degreeSegmentView
{
    if (!_degreeSegmentView) {
        _degreeSegmentView = [[UISegmentedControl alloc] initWithItems:@[@"0", @"90", @"180", @"270"]];
        [_degreeSegmentView addTarget:self action:@selector(degreeAction:) forControlEvents:UIControlEventValueChanged];
        _degreeSegmentView.selectedSegmentIndex = 0;
    }
    return _degreeSegmentView;
}


- (UISegmentedControl *)modeSegmentView
{
    if (!_modeSegmentView) {
        _modeSegmentView = [[UISegmentedControl alloc] initWithItems:@[@"point", @"outline", @"surface", @"volumn"]];
        [_modeSegmentView addTarget:self action:@selector(modeAction:) forControlEvents:UIControlEventValueChanged];
        _modeSegmentView.selectedSegmentIndex = 0;
    }
    return _modeSegmentView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
