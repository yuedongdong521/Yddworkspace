//
//  CustomGradBtn.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/17.
//  Copyright © 2019 QH. All rights reserved.
//

#import "CustomGradBtn.h"



@implementation GradLayerModel

- (void)setGradColors:(NSArray<UIColor *> *)colors
{
    NSMutableArray *mutArr = [NSMutableArray array];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutArr addObject:(__bridge id)obj.CGColor];
    }];
    _colors = mutArr;
}

- (NSArray<NSNumber *> *)locations
{
    if (_locations) {
        return _locations;
    }
    NSMutableArray *mutAtt = [NSMutableArray array];
    [_colors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutAtt addObject:@(idx * 1.0 / _colors.count)];
    }];
    _locations = mutAtt;
    return _locations;
}


- (CAGradientLayerType)type
{
    if (_type) {
        return _type;
    }
    return kCAGradientLayerAxial;
}

@end

@interface CustomGradBtn ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) NSMutableDictionary *gradMutDic;

@end

@implementation CustomGradBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    CustomGradBtn *button = [super buttonWithType:buttonType];
    if (button) {
        [button.layer insertSublayer:button.gradientLayer atIndex:0];
        [button addObserver:button forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    }
    return button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
}


- (void)setGradModel:(GradLayerModel *)model gradState:(BOOL)state
{
    _gradLayerSelected = state;
    if (model) {
        [self.gradMutDic setObject:model forKey:@(state)];
    }
    [self setGradLayerWithModel:model];
}

- (void)setGradLayerWithModel:(GradLayerModel *)model
{
    if (!model) {
        if ([self.gradientLayer superlayer]) {
            [self.gradientLayer removeFromSuperlayer];
        }
        return;
    }
    if (![self.gradientLayer superlayer]) {
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    self.gradientLayer.colors = model.colors;
    self.gradientLayer.locations = model.locations;
    self.gradientLayer.startPoint = model.startPoint;
    self.gradientLayer.endPoint = model.endPoint;
    self.gradientLayer.type = model.type;
}


- (void)setGradLayerSelected:(BOOL)gradLayerSelected
{
    _gradLayerSelected = gradLayerSelected;
    [self setGradLayerWithModel:self.gradMutDic[@(_gradLayerSelected)]];
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [[CAGradientLayer alloc] init];
    }
    return _gradientLayer;
}

- (NSMutableDictionary *)gradMutDic
{
    if (!_gradMutDic) {
        _gradMutDic = [NSMutableDictionary dictionary];
    }
    return _gradMutDic;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
    [self removeObserver:self forKeyPath:@"state"];
}

@end
