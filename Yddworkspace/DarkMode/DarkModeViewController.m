//
//  DarkModeViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/5/13.
//  Copyright © 2020 QH. All rights reserved.
//

#import "DarkModeViewController.h"

@interface DarkModeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *changeModeBtn;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation DarkModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self updateUI];
    
}

- (void)updateUI
{
    [self.changeModeBtn setTitleColor:[self color:[UIColor blackColor] darkColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    self.textLabel.textColor = [self color:[UIColor blackColor] darkColor:[UIColor whiteColor]];
}

- (UIColor *)color:(UIColor *)color darkColor:(UIColor *)darkColor
{
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return darkColor;
            }
            return color;
        }];
        
    } else {
        return color;
    }
}

- (IBAction)changeAction:(id)sender {
    if (@available(iOS 13.0, *)) {
        
        NSLog(@"cur mode : %ld", (long)self.overrideUserInterfaceStyle);
        if (self.overrideUserInterfaceStyle == UIUserInterfaceStyleDark) {
            [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        } else {
           
            [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
        }
    } else {
        // Fallback on earlier versions
    }
    
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            NSLog(@"traitcollection 发生变化");
        } else {
            NSLog(@"traitcollection 未发生变化");
        }
    } else {
        // Fallback on earlier versions
    }
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
