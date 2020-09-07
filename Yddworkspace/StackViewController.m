//
//  StackViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/3/23.
//  Copyright © 2020 QH. All rights reserved.
//

#import "StackViewController.h"

@interface StackViewController ()


@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, strong) UILabel *firstLabel;

@property (nonatomic, strong) UILabel *secondLabel;

@property (nonatomic, strong) UILabel *thirdLabel;

@end

@implementation StackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.stackView];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self.thirdLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
//    [self.secondLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
//     [self.firstLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    
    
    self.stackView.frame = CGRectMake(20, 150, ScreenWidth - 40, 100);
    self.firstLabel.text = @"firstLabel";
    self.secondLabel.text = @"secondLabel";
    self.thirdLabel.text = @"thirdLabel";
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    self.stackView.alignment = UIStackViewAlignmentLeading;
    self.stackView.spacing = 0;
    self.stackView.distribution = UIStackViewDistributionFillProportionally;
    self.stackView.baselineRelativeArrangement = YES;
    self.stackView.layoutMarginsRelativeArrangement = YES;
    
    [self.firstLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    
    UISegmentedControl *alignmentSeg = [[UISegmentedControl alloc] initWithItems:@[@"Fill", @"Leading", @"FirstBaseline", @"Center", @"Trailing", @"LastBaseline"]];
    [alignmentSeg addTarget:self action:@selector(alignmentSegAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:alignmentSeg];
    alignmentSeg.frame = CGRectMake(10, 400, ScreenWidth - 20, 50);
    
    UISegmentedControl *distributionSeg = [[UISegmentedControl alloc] initWithItems:@[@"Fill", @"FillEqually", @"FillProportionally", @"EqualSpacing", @"EqualCentering"]];
    [distributionSeg addTarget:self action:@selector(distributionSegAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:distributionSeg];
    distributionSeg.frame = CGRectMake(10, 500, ScreenWidth - 20, 50);
    
    
  

    
}

- (void)alignmentSegAction:(UISegmentedControl *)seg
{
    self.stackView.alignment = seg.selectedSegmentIndex;
    
    [self.stackView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"frame = %@", NSStringFromCGRect(obj.frame));
    }];
}

- (void)distributionSegAction:(UISegmentedControl *)seg
{
    self.stackView.distribution = seg.selectedSegmentIndex;
}

- (UIStackView *)stackView
{
    if (!_stackView) {
        _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.firstLabel, self.secondLabel, self.thirdLabel]];
        _stackView.backgroundColor = [UIColor whiteColor];
    }
    return _stackView;
}

- (UILabel *)firstLabel
{
    if (!_firstLabel) {
        _firstLabel = [[UILabel alloc] init];
        _firstLabel.backgroundColor = [UIColor redColor];
    }
    return _firstLabel;
}

- (UILabel *)secondLabel
{
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc] init];
        _secondLabel.backgroundColor = [UIColor greenColor];
    }
    return _secondLabel;
}

- (UILabel *)thirdLabel
{
    if (!_thirdLabel) {
        _thirdLabel = [[UILabel alloc] init];
        _thirdLabel.backgroundColor = [UIColor blueColor];
    }
    return _thirdLabel;
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
