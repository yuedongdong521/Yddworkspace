//
//  BarrageController.m
//  Yddworkspace
//
//  Created by ispeak on 2017/1/16.
//  Copyright © 2017年 QH. All rights reserved.
//

#import "BarrageController.h"
#import "BarrageItemView.h"


#define kDuration 5
#define kSpeed 75.0
#define kWidth(view) view.frame.size.width
#define kHeight(view) view.frame.size.height
#define kX(view) view.frame.origin.x
#define kY(View) view.frame.origin.y

#define lineHeight  40
#define lineSpac 60

@interface BarrageController()

@property (nonatomic, strong)NSMutableArray *saveArray;
@property (nonatomic, assign)BOOL isPlaying;
@property (nonatomic, strong)BarrageItemView *lastItemView;
@property (nonatomic, strong)NSMutableDictionary *itemDic;
@property (nonatomic, strong)NSTimer *barrageTimer;

@end

@implementation BarrageController

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initBarrageController
{
    self = [super init];
    if (self) {
        _saveArray = [NSMutableArray arrayWithCapacity:0];
        _itemDic = [NSMutableDictionary dictionaryWithCapacity:0];
        _isPlaying = NO;
    }
    return self;
}

- (void)sendBarrageForBarrageModel:(BarrageModel *)barrageModel bgView:(UIView *)bgView
{
    [self createBarrageForUserId:barrageModel.uid ForUserNameStr:barrageModel.nameStr ForContentStr:barrageModel.contentStr ForUserRank:barrageModel.rankStr ForBgView:bgView];
}

- (CGSize)getStringSizeWithContentStr:(NSString *)contentStr FontValue:(NSInteger)fonValue MaxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fonValue], NSParagraphStyleAttributeName:paragraphStyle};
    CGSize returnSize = [contentStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return returnSize;
}

- (void)createBarrageForUserId:(int)userId ForUserNameStr:(NSString *)nameStr ForContentStr:(NSString *)contentStr ForUserRank:(NSString *)rank ForBgView:(UIView *)bgView
{
    CGSize maxSize = CGSizeMake(1000, 20);
    CGFloat nameW = [self getStringSizeWithContentStr:nameStr FontValue:14 MaxSize:maxSize].width + 40;
    
    CGFloat contentW = [self getStringSizeWithContentStr:contentStr FontValue:14 MaxSize:maxSize].width + 10;
    
    CGFloat itemW = nameW > contentW? nameW : contentW;
    
    BarrageItemView *itemView = [[BarrageItemView alloc] initWithFrame:CGRectMake(ScreenWidth, kHeight(bgView) / 4.0, itemW + lineHeight, lineHeight) WithNameWidth:nameW WithContentWidth:contentW];
    if (_isUniform) {
        itemView.durationTime = (ScreenWidth + kWidth(itemView)) / kSpeed;
    } else {
        itemView.durationTime = kDuration;
    }
    itemView.headImage.image = [UIImage imageNamed:@"0.jpg"];
    
    itemView.nameLabel.attributedText = [self getnameStr:nameStr ForImageStr:rank];
    itemView.concentLabel.text = contentStr;
    [bgView addSubview:itemView];
    [self.saveArray addObject:itemView];
    
        [self barrageStart:itemView];
}

- (NSMutableAttributedString *)getnameStr:(NSString *)nameStr ForImageStr:(NSString *)imageStr
{
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:nameStr];
    if (nameStr.length > 0) {
        NSShadow *shadw = [[NSShadow alloc] init];
        shadw.shadowColor = [UIColor grayColor];
        shadw.shadowOffset = CGSizeMake(1, 1);
        shadw.shadowBlurRadius = 5;
        NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSShadowAttributeName:shadw, NSVerticalGlyphFormAttributeName:@(0)};
        [att addAttributes:dic range:NSMakeRange(0, nameStr.length)];
    }
    if(imageStr.length > 0) {
        NSTextAttachment *ment = [[NSTextAttachment alloc] init];
        ment.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageStr ofType:@"png"]];
        ment.bounds = CGRectMake(5, - 2, 30, 14);
        NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment:ment];
        [att appendAttributedString:imageAtt];
    }
    return att;
}

- (void)barrageStart:(BarrageItemView *)itemView
{
        
        NSInteger lineValueCount = self.itemDic.allKeys.count;
        if (lineValueCount == 0) {
            
            itemView.currentLineCount = 0;
            [self playBarrayeView:itemView];
            return;
        }
        
        for (int i = 0; i < lineValueCount; i++){
            BarrageItemView *oldItemView = self.itemDic[@(i)];
            if (!oldItemView) {
                break;
            }
            if ([self judgeIsRunintoWithFirstBarrageItemView:itemView OldItemView:oldItemView]) {
                
                itemView.currentLineCount = i;
                [self playBarrayeView:itemView];
                break;
            } else if (i == lineValueCount - 1) {
                if (lineValueCount < self.maxLineCount) {
                    itemView.currentLineCount = i+1;
                    [self playBarrayeView:itemView];
                    
                    break;
                } else {
                    if (_barrageTimer == nil) {
                        _barrageTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
                    }
                    NSLog(@"当前弹幕太多");
                    
                }
            }
        }
        self.lastItemView = itemView;
    
}

- (void)timerAction
{
    if (self.saveArray.count > 0) {
        BarrageItemView *itemView = [self.saveArray firstObject];
                [self barrageStart:itemView];
    } else {
        [self timerInval];
    }
}

- (void)timerInval
{
    if (_barrageTimer != nil) {
        if (_barrageTimer.isValid) {
            [_barrageTimer invalidate];
        }
        _barrageTimer = nil;
    }
}

// 检测碰撞 -- 默认从右到左
- (BOOL)judgeIsRunintoWithFirstBarrageItemView:(BarrageItemView *)itemView OldItemView:(BarrageItemView *)oldItemView
{
    
    unsigned long long currentTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000 ;
    CGFloat oldStartTime = (currentTime - oldItemView.startTime) / 1000;
    
    NSLog(@"\n oldStartTime ====== %f \n currentTime ====== %llu \n  staartTime ====== %llu", oldStartTime, currentTime, oldItemView.startTime);
    
    if (_isUniform) {
        // 固定速度
        if (oldStartTime > itemView.durationTime) {
            return YES;
        }
        CGFloat timeS = kWidth(oldItemView)/kSpeed;
        if (timeS >= oldStartTime) {
            return NO;
        }
        CGFloat timeE = kX(itemView)/kSpeed;
        if (timeE <= oldStartTime) {
            return NO;
        }
        return YES;
        
    } else {
        //固定时间
        CGFloat currentSpeed = [self getSpeedFromBarrageItemView:itemView];
        CGFloat oldSpeed = [self getSpeedFromBarrageItemView:oldItemView];
        
        if (oldStartTime > kDuration) {
            return YES;
        }
        CGFloat oldRight = oldStartTime * oldSpeed;
        if (oldRight < kWidth(oldItemView)) {
            return NO;
        }
        
        CGFloat lastTime = kDuration - oldStartTime;
        
        CGFloat currentLeft = lastTime * currentSpeed;
        if (currentLeft > ScreenWidth) {
            return NO;
        }
        
        return YES;
    }
}

// 计算速度
- (CGFloat)getSpeedFromBarrageItemView:(BarrageItemView *)itemView
{
    return (ScreenWidth + kWidth(itemView)) / kDuration;
}

- (void)playBarrayeView:(BarrageItemView *)itemView
{
    [self.saveArray removeObject:itemView];
    itemView.frame = CGRectMake(ScreenWidth, ScreenHeight / 2 - itemView.currentLineCount * lineSpac,  kWidth(itemView), kHeight(itemView));
    itemView.startTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    self.itemDic[@(itemView.currentLineCount)] = itemView;
    [UIView animateWithDuration:itemView.durationTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        itemView.frame = CGRectMake(kWidth(itemView) * (-1.0), ScreenHeight / 2.0 - itemView.currentLineCount * lineSpac, kWidth(itemView), kHeight(itemView));
        
    } completion:^(BOOL finished) {
        if (finished) {
            [itemView removeFromSuperview];
        }
    }];
}

- (void)dealloc
{

    NSLog(@"barrageView______dealloc");
}



@end
