//
//  PhotoNumber.m
//  Yddworkspace
//
//  Created by ydd on 2019/12/18.
//  Copyright © 2019 QH. All rights reserved.
//

#import "PhotoNumber.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

extern NSString* CTSettingCopyMyPhoneNumber();

@implementation PhotoNumber

// 私有api
+(NSString *)myNumber{
    return CTSettingCopyMyPhoneNumber();
}

+ (NSString *)photoNumber {
    NSString *number = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
    return number;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        //当sim卡更换时弹出此窗口
        networkInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier){
           
                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@ "Sim card changed" delegate:nil cancelButtonTitle:@ "Dismiss" otherButtonTitles:nil];
           
                   [alert show];
        };
    }
    return self;
}

@end
