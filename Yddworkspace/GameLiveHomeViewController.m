//
//  GameLiveHomeViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/8/22.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "GameLiveHomeViewController.h"

#define viewWidth(view) view.frame.size.width
#define viewHeight(view) view.frame.size.height
#define viewX(view) view.frame.origin.x
#define viewY(view) view.frame.origin.y

@interface GameLiveHomeViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIView *titleBgView;
@property (nonatomic, strong) UITextField *titleName;
@property (nonatomic, strong) UILabel *gameLabel;
@property (nonatomic, strong) UILabel *videoQuality;

@property (nonatomic, strong) UIButton *verBtn;
@property (nonatomic, strong) UIButton *horBtn;


@end

@implementation GameLiveHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:40 / 255.0 green:41 / 255.0 blue:51 / 255.0 alpha:1];
    //57 58 70 / 123 124 132  250 50 100
    [self initHeadView];
    [self initContentTitle];
    
    // Do any additional setup after loading the view.
}

- (void)initHeadView
{
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2.0 - 50, 84, 100, 100)];
    _headImageView.layer.borderWidth = 5.0;
    _headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _headImageView.layer.cornerRadius = 5.0;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:_headImageView];

}

- (void)initContentTitle
{
    _titleBgView = [[UIView alloc] initWithFrame:CGRectMake(20, viewY(_headImageView) + viewHeight(_headImageView) + 50, ScreenWidth - 40, 150)];
    [self.view addSubview:_titleBgView];
    
    [self addButtonForFrame:CGRectMake(0, 0, viewWidth(_titleBgView), 49.5) ForTitle:@"" ForAction:@selector(changeLiveName:) ForSubTitle:nil ForTag:1];
    [self addButtonForFrame:CGRectMake(0, 50, viewWidth(_titleBgView), 49.5) ForTitle:@"直播游戏" ForAction:@selector(changeLiveName:) ForSubTitle:@"王者荣耀>" ForTag:2];
    
    [self addButtonForFrame:CGRectMake(0, 100, viewWidth(_titleBgView), 49.5) ForTitle:@"直播清晰度" ForAction:@selector(changeLiveName:) ForSubTitle:@"高清>"  ForTag:3];
    
    self.horBtn = [self careatDrectionBtnForFrame:CGRectMake(50, viewY(_titleBgView) + viewHeight(_titleBgView) + 50, 100, 50) Image:nil ForTitle:@"横屏直播" ForTag:1];
    self.verBtn = [self careatDrectionBtnForFrame:CGRectMake(ScreenWidth - 150, viewY(_titleBgView) + viewHeight(_titleBgView) + 50, 100, 50) Image:nil ForTitle:@"竖屏直播" ForTag:2];
    
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(20, viewY(_titleBgView) + viewHeight(_titleBgView) + 150, ScreenWidth - 40, 50);
    startBtn.backgroundColor = [UIColor colorWithRed:250 / 255.0 green:50 / 255.0 blue:100 / 255.0 alpha:1.0];
    startBtn.layer.masksToBounds = YES;
    startBtn.layer.cornerRadius = 25;
    [startBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [startBtn setTintColor:[UIColor whiteColor]];
    [startBtn addTarget:self action:@selector(startLiveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    
}

- (void)startLiveAction
{
    
}

- (void)changeLiveName:(UIButton *)button
{
    if (button.tag != 1) {
        if ([_titleName isFirstResponder]) {
            [_titleName endEditing:YES];
        }
    }
    for (int i = 1; i < 4; i++) {
        if (button.tag == i) {
            [button setBackgroundColor:[UIColor colorWithRed:50 / 255.0 green:50 / 255.0 blue:60 / 255.0 alpha:1.0]];
            
        } else {
            UIButton *btn = (UIButton *)[self.titleBgView viewWithTag:i];
            if (btn) {
                [btn setBackgroundColor:[UIColor colorWithRed:57 / 255.0 green:58 / 255.0 blue:70 / 255.0 alpha:1.0]];
            }
        }
    }
}

- (UIButton *)addButtonForFrame:(CGRect)frame ForTitle:(NSString *)title ForAction:(SEL)action ForSubTitle:(NSString *)subTitle ForTag:(NSInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    button.frame = frame;
    [button setBackgroundColor:[UIColor colorWithRed:57 / 255.0 green:58 / 255.0 blue:70 / 255.0 alpha:1.0]];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.titleBgView addSubview:button];
    if (tag == 1) {
        if (_titleName == nil) {
            _titleName = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 20, 50)];
            _titleName.text = title;
            _titleName.textColor = [UIColor colorWithRed:123 / 255.0 green:124 / 255.0 blue:132 / 255.0 alpha:1.0];
            _titleName.backgroundColor = [UIColor clearColor];
            _titleName.font = [UIFont systemFontOfSize:14];
            _titleName.textAlignment = NSTextAlignmentLeft;
            _titleName.delegate = self;
            _titleName.returnKeyType = UIReturnKeyDone;
            _titleName.placeholder = @"请输入直播标题";
            [button addSubview:_titleName];
        }
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width / 2.0, 30)];
        label.text = title;
        label.textColor = [UIColor colorWithRed:123 / 255.0 green:124 / 255.0 blue:132 / 255.0 alpha:1.0];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        [button addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 2.0 + 10, 10, frame.size.width / 2.0 - 20, 30)];
        label2.text = subTitle;
        label2.textColor = [UIColor colorWithRed:123 / 255.0 green:124 / 255.0 blue:132 / 255.0 alpha:1.0];
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont systemFontOfSize:12];
        label2.textAlignment = NSTextAlignmentRight;
        [button addSubview:label2];
        if (tag == 2) {
            self.gameLabel = label2;
        } else {
            self.videoQuality = label2;
        }
        
    }
    return button;
}


- (UIButton *)careatDrectionBtnForFrame:(CGRect)frame Image:(UIImage *)image ForTitle:(NSString *)title ForTag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    btn.frame = frame;
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(choseVideoDrection:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.3, frame.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    imageView.tag = 100 + tag;
    [btn addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width * 0.3, 0, frame.size.width * 0.7, frame.size.height)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentLeft;
    label.tag = 200 + tag;
    if (tag == 1) {
        label.textColor = [UIColor colorWithRed:250 / 255.0 green:50 / 255.0 blue:100 / 255.0 alpha:1.0];
    } else {
        label.textColor = [UIColor colorWithRed:123 / 255.0 green:124 / 255.0 blue:132 / 255.0 alpha:1.0];
    }
    [btn addSubview:label];
    return btn;
}


- (void)choseVideoDrection:(UIButton *)button
{
    UIImageView *horImageView = (UIImageView *)[self.horBtn viewWithTag:100 + self.horBtn.tag];
    UILabel *horLabel = (UILabel *)[self.horBtn viewWithTag:200 + self.horBtn.tag];
    
    UIImageView *verImageView = (UIImageView *)[self.verBtn viewWithTag:100 + self.verBtn.tag];
    UILabel *verLabel = (UILabel *)[self.verBtn viewWithTag:200 + self.verBtn.tag];
    
    if (button == self.horBtn) {
        if (horLabel) {
            horLabel.textColor = [UIColor colorWithRed:250 / 255.0 green:50 / 255.0 blue:100 / 255.0 alpha:1.0];
        }
        if (horImageView) {
            
        }
        if (verLabel) {
            verLabel.textColor = [UIColor colorWithRed:123 / 255.0 green:124 / 255.0 blue:132 / 255.0 alpha:1.0];
        }
        if (verImageView) {
            
        }
    } else {
        if (verLabel) {
            verLabel.textColor = [UIColor colorWithRed:250 / 255.0 green:50 / 255.0 blue:100 / 255.0 alpha:1.0];
        }
        if (verImageView) {
            
        }
        if (horLabel) {
            horLabel.textColor = [UIColor colorWithRed:123 / 255.0 green:124 / 255.0 blue:132 / 255.0 alpha:1.0];
        }
        if (horLabel) {
            
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [textField endEditing:YES];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    for (int i = 1; i < 4; i++) {
        UIButton *btn = (UIButton *)[self.titleBgView viewWithTag:i];
        if (btn) {
            if (1 == i) {
                [btn setBackgroundColor:[UIColor colorWithRed:50 / 255.0 green:50 / 255.0 blue:60 / 255.0 alpha:1.0]];
                
            } else {
                [btn setBackgroundColor:[UIColor colorWithRed:57 / 255.0 green:58 / 255.0 blue:70 / 255.0 alpha:1.0]];
            }
        }
    }

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
