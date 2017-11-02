//
//  YddImagePickerViewController.m
//  Yddworkspace
//
//  Created by ispeak on 16/9/9.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "YddImagePickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface YddImagePickerViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
//基本设置


@end

@implementation YddImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initPickerController];
    
}

- (void)initPickerController
{
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePickerController.allowsEditing = YES;
    [self selectImageAndVideoFromCameraOrAlbum:_isCamera];
    
}

- (void)selectImageAndVideoFromCameraOrAlbum:(BOOL)isCamera
{
    if (isCamera) {
        //选择数据源
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        //设置最大录制时长
        _imagePickerController.videoMaximumDuration = 15;
        //相机类型（拍照、录像...）字符串需要做相应的类型转换
        _imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
        
        //视频质量
        //UIImagePickerControllerQualityTypeHigh 高清
        //UIImagePickerControllerQualityTypeMedium 中等质量
        //UIImagePickerControllerQualityTypeLow 地质量
        //UIImagePickerControllerQualityType640x480;
        
        _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
        //设置摄像头模式（拍照，录制视频）为录像模式
        _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        
        [self presentViewController:_imagePickerController animated:YES completion:nil];
        
        
    } else {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
    } else {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}

- (void)setImagePickerController:(UIImagePickerController *)imagePickerController
{
    
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
