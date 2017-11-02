//
//  AppDelegate.m
//  Yddworkspace
//
//  Created by ispeak on 16/8/15.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <iflyMSC/IFlyMSC.h>
#import "MyTabBarViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self initIFlySDK];
    
    MyTabBarViewController *VC = [[MyTabBarViewController alloc]init];
//    UINavigationController *navig = [[UINavigationController alloc] initWithRootViewController:VC];
    self.window.rootViewController = VC;
    [self.window makeKeyAndVisible];
    
//    NSString *str = [NSString stringWithUTF8String:nil];
    
    [self initTabBar];
    
    [self testC_strToOC_str];
    
    [self test16Str];
    
    return YES;
}

- (void)initTabBar
{
    
}

- (void)initIFlySDK
{
    
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"58b7e78a"];
    
    //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
    [IFlySpeechUtility createUtility:initString];
    
    
//    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"58b7e78a"];
//    [IFlySpeechUtility createUtility:initString];
    
}

- (void)test16Str
{
    NSString *str = @"ffccee";
    int a = 0Xffeecc;
    unsigned int value;
    [[NSScanner scannerWithString:str] scanHexInt:&value];
    NSLog(@"16进制value = %x \n a = %x", value, a);
}

- (void)testC_strToOC_str
{
    const char *cString = "这是一个C字符串， c string";
    NSString *nsstring = @"这是个NSString字符串， nsstring";
    NSLog(@"cString字符串-->%s ",cString);
    NSLog(@"NSString字符串-->%@",nsstring);
    
    const  char *cString2 = [nsstring UTF8String];
    NSString *nsstring2 = [NSString stringWithUTF8String:cString];
    NSLog(@"cString2字符串-->%s ",cString2);
    NSLog(@"NSString2字符串-->%@",nsstring2);
}


/**
 *  将阿拉伯数字转换为中文数字
 */
+(NSString *)translationArabicNum:(NSInteger)arabicNum
{
    NSString *arabicNumStr = [NSString stringWithFormat:@"%ld",(long)arabicNum];
    NSArray *arabicNumeralsArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chineseNumeralsArray = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chineseNumeralsArray forKeys:arabicNumeralsArray];
    
    if (arabicNum < 20 && arabicNum > 9) {
        if (arabicNum == 10) {
            return @"十";
        }else{
            NSString *subStr1 = [arabicNumStr substringWithRange:NSMakeRange(1, 1)];
            NSString *a1 = [dictionary objectForKey:subStr1];
            NSString *chinese1 = [NSString stringWithFormat:@"十%@",a1];
            return chinese1;
        }
    }else{
        NSMutableArray *sums = [NSMutableArray array];
        for (int i = 0; i < arabicNumStr.length; i ++)
        {
            NSString *substr = [arabicNumStr substringWithRange:NSMakeRange(i, 1)];
            NSString *a = [dictionary objectForKey:substr];
            NSString *b = digits[arabicNumStr.length -i-1];
            NSString *sum = [a stringByAppendingString:b];
            if ([a isEqualToString:chineseNumeralsArray[9]])
            {
                if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
                {
                    sum = b;
                    if ([[sums lastObject] isEqualToString:chineseNumeralsArray[9]])
                    {
                        [sums removeLastObject];
                    }
                }else
                {
                    sum = chineseNumeralsArray[9];
                }
                
                if ([[sums lastObject] isEqualToString:sum])
                {
                    continue;
                }
            }
            
            [sums addObject:sum];
        }
        NSString *sumStr = [sums  componentsJoinedByString:@""];
        NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
        return chinese;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
