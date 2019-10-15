//
//  DeleteCellViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/6/27.
//  Copyright © 2019 QH. All rights reserved.
//

#import "DeleteCellViewController.h"
#import "MoveView.h"
#import "Yddworkspace-Swift.h"
#import "CropPhotoHelper.h"

@interface DeleteCellViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) MoveView *contentView;
@property (nonatomic, assign) BOOL hidStatusBar;

@end

@implementation DeleteCellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.fd_prefersNavigationBarHidden = YES;
    [self addNavigationBarView];
    self.view.backgroundColor = [UIColor grayColor];
    MoveView *moveView = [[MoveView alloc] init];
    __weak typeof(self) weakself = self;
    moveView.addImage = ^{
        __strong typeof(weakself) strongself = weakself;
        [strongself addImage];
    };
    [self.view addSubview:moveView];
    _contentView = moveView;
    _contentView.preporeImage = ^(BOOL openPre) {
        weakself.hidStatusBar = openPre;
        [weakself setNeedsStatusBarAppearanceUpdate];
    };
    CGFloat navBh = kNavBarHeight;
    [moveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(kNavBarHeight, 0, 0, 0));
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return _hidStatusBar;
}



- (void)addNavigationBarView
{
    CustomNavigationBarView *navigView = [[CustomNavigationBarView alloc] init];
    [self.view addSubview:navigView];
    [navigView setTitleWithTitle:@"相册"];
    [navigView setRightBtnTitleWithTitle:@"保存" image:nil];
    [navigView.rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    __weak typeof(self) weakself = self;
    navigView.leftAction = ^{
        if (weakself.navigationController) {
           [weakself.navigationController popViewControllerAnimated:YES];
        } else {
            [weakself dismissViewControllerAnimated:YES completion:nil];
        }
    };
    navigView.rightAction = ^{
        NSLog(@"rightAction clicked");
    };

    [navigView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(kNavBarHeight);
    }];
}

- (void)addImage
{
    __weak typeof(self) weakself = self;
    CustomAlertSheepView *sheepView = [[CustomAlertSheepView alloc] initWithContentItes:@[@"相册", @"拍照"] cancelTitle:@"c取消" itemAction:^(NSInteger index) {
        __strong typeof(weakself) strongself = weakself;
        if (index == 0) {
            [strongself getImageWithPhotos];
        } else {
            [strongself getImageWithCapture];
        }
        
    } cancelAction:^{
       
    }];
    
    [sheepView showAnimationWithAnimation:YES];
}

- (void)getImageWithPhotos
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationPopover;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)getImageWithCapture
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.editing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *orignImage = info[UIImagePickerControllerOriginalImage];
    if (orignImage) {
        __weak typeof(self) weakself = self;
        [CropPhotoHelper cropPhotoTargetViewController:self orignImage:orignImage cropComplete:^(UIImage * _Nonnull image) {
            __strong typeof(weakself) strongself = weakself;
            [strongself.contentView addImage:image];
        }];
    }
}

#pragma mark -  UIImagePickerController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        
        navigationController.navigationBar.translucent = NO;
        
        //设置成想要的背景颜色
        [navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.9 alpha:1]];
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
