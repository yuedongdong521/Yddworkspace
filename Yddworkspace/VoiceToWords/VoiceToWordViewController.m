//
//  VoiceToWordViewController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/3/6.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "VoiceToWordViewController.h"
#import <AVFoundation/AVSpeechSynthesis.h>

@interface VoiceToWordViewController ()<AVSpeechSynthesizerDelegate>
{
    AVSpeechSynthesizer *av;
}


@end

@implementation VoiceToWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame=CGRectMake(100,100,100,50);
    
    [button setTitle:@"讲"forState:UIControlStateNormal];
    
    [button setTitle:@"停"forState:UIControlStateSelected];
    
    [button setTitleColor:[UIColor blueColor]forState:UIControlStateNormal];
    
    button.backgroundColor=[UIColor grayColor];
    
    button.showsTouchWhenHighlighted=YES;
    [button addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
}

-(void)start:(UIButton*)sender{
    
    if(sender.selected==NO) {
        
        if([av isPaused]) {
            //如果暂停则恢复，会从暂停的地方继续
            [av continueSpeaking];
            
            sender.selected=!sender.selected;
            
        }else{
            //初始化对象
            av= [[AVSpeechSynthesizer alloc]init];
            
            av.delegate=self;//挂上代理
            
            AVSpeechUtterance*utterance = [[AVSpeechUtterance alloc]initWithString:/*@"Own projects before used xunfei text to speech technology, but through the actual test, found the free online to speech is not very good, is affected by network voice often intermittent;Offline to speech and its price is too expensive, the cheapest is 8000 RMB / 2000 installations, many developers hope and stopped.So since pay not the xunfei the expensive cost, iOS bring text to speech is our right choice, but his pronunciation effect is not ideal, but also can accept.Today I'd take you learn iOS bring text to speech!"*/@"锦瑟无端五十弦，一弦一柱思华年。庄生晓梦迷蝴蝶，望帝春心托杜鹃。沧海月明珠有泪，蓝田日暖玉生烟。此情可待成追忆，只是当时已惘然。"];//需要转换的文字
            
            utterance.rate=0.5;// 设置语速，范围0-1，注意0最慢，1最快；AVSpeechUtteranceMinimumSpeechRate最慢，AVSpeechUtteranceMaximumSpeechRate最快
            
            AVSpeechSynthesisVoice*voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"/*@"zh-CN"*//*@"zh-HK"*/];//设置发音，这是中文普通话
            
            utterance.voice= voice;
            
            [av speakUtterance:utterance];//开始
            
            sender.selected=!sender.selected;
            
        }
        
    }else{
        
        //[av stopSpeakingAtBoundary:AVSpeechBoundaryWord];//感觉效果一样，对应代理>>>取消
        
        [av pauseSpeakingAtBoundary:AVSpeechBoundaryWord];//暂停
        
        sender.selected=!sender.selected;
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [av stopSpeakingAtBoundary:AVSpeechBoundaryWord];
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
