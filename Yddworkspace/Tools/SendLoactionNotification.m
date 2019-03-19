//
//  SendLoactionNotification.m
//  Yddworkspace
//
//  Created by ydd on 2019/3/19.
//  Copyright © 2019 QH. All rights reserved.
//

#import "SendLoactionNotification.h"
#import <UserNotifications/UserNotifications.h>

@implementation SendLoactionNotification

- (void)addAVChatCommandLocalNotificationForFriendId:(int)friendId
                                          friendName:(NSString*)friendName
                                              avtype:(int)avtype
                                                 cmd:(int)cmd {
  if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
    [self addLocalNotificationForIOS10FriendId:friendId
                                    friendName:friendName
                                           cmd:cmd
                                        avtype:avtype];
  } else {
    UIApplication* application = [UIApplication sharedApplication];
    if ([application currentUserNotificationSettings]) {
      UIUserNotificationSettings* setting = [UIUserNotificationSettings
                                             settingsForTypes:UIUserNotificationTypeBadge |
                                             UIUserNotificationTypeSound |
                                             UIUserNotificationTypeAlert
                                             categories:nil];
      [application registerUserNotificationSettings:setting];
    }
    [application cancelAllLocalNotifications];
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDictionary* friendInfo = @{
                                 @"friendId" : @(friendId),
                                 @"avtype" : @(avtype),
                                 @"command" : @(cmd)
                                 };
    NSString* alertBody;
    switch (avtype) {
      case 0:
        alertBody = @"[语音聊天]";
        break;
      case 1:
        alertBody = @"[视频聊天]";
        break;
      default:
        alertBody = @"一条消息";
        break;
    }
    if (friendName.length > 0) {
      alertBody = [NSString stringWithFormat:@"%@: %@", friendName, alertBody];
    }
    UILocalNotification* localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = date;
    localNotif.alertBody = alertBody;
    localNotif.userInfo = friendInfo;
    localNotif.soundName = @"voip_call.caf";
    localNotif.alertAction = @"ISAVChatNotification";
    [application scheduleLocalNotification:localNotif];
  }
}

- (void)deleteAVChatLocalNotificationForFriendid:(int)friendId
                                       ForAVtype:(int)avtype {
  if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
    UNUserNotificationCenter* center =
    [UNUserNotificationCenter currentNotificationCenter];
    [center getPendingNotificationRequestsWithCompletionHandler:^(
                                                                  NSArray<UNNotificationRequest*>* _Nonnull requests) {
      for (UNNotificationRequest* request in requests) {
        if ([request.identifier isEqualToString:@"ISAVChatNotification"]) {
          NSDictionary* userInfo = request.content.userInfo;
          NSLog(@"本地推送 userinfo = %@", userInfo);
          if (userInfo) {
          }
        }
      }
    }];
    
    [center
     removeDeliveredNotificationsWithIdentifiers:@[ @"ISAVChatNotification" ]];
  } else {
    UIApplication* application = [UIApplication sharedApplication];
    NSArray* localNotifications = [application scheduledLocalNotifications];
    NSLog(@"音视频本地推送通知 : %@", localNotifications);
    for (UILocalNotification* local in localNotifications) {
      if ([local.alertAction isEqualToString:@"ISAVChatNotification"]) {
        NSDictionary* friendInfo = local.userInfo;
        if (friendInfo) {
          int userId, type;
          if ([friendInfo objectForKey:@"friendId"]) {
            userId = [[friendInfo objectForKey:@"friendId"] intValue];
          } else {
            userId = 0;
          }
          if ([friendInfo objectForKey:@"avtype"]) {
            type = [[friendInfo objectForKey:@"avtype"] intValue];
          } else {
            type = 0;
          }
          if (userId == friendId && avtype == type) {
            [application cancelLocalNotification:local];
            NSInteger num = [application applicationIconBadgeNumber];
            if (num > 1) {
              [application setApplicationIconBadgeNumber:num - 1];
            } else {
              [application setApplicationIconBadgeNumber:0];
            }
          }
        }
      }
    }
  }
  
}

- (void)addLocalNotificationForIOS10FriendId:(int)friendId
                                  friendName:(NSString*)friendName
                                         cmd:(int)cmd
                                      avtype:(int)avtype {
  NSDictionary* friendInfo = @{
                               @"friendId" : @(friendId),
                               @"avtype" : @(avtype),
                               @"command" : @(cmd)
                               };
  UNUserNotificationCenter* center =
  [UNUserNotificationCenter currentNotificationCenter];
  UNMutableNotificationContent* content =
  [[UNMutableNotificationContent alloc] init];
  NSString* alertBody;
  switch (avtype) {
    case 0:
      alertBody = @"[语音聊天]";
      break;
    case 1:
      alertBody = @"[视频聊天]";
      break;
    default:
      alertBody = @"一条消息";
      break;
  }
  if (friendName.length > 0) {
    alertBody = [NSString stringWithFormat:@"%@: %@", friendName, alertBody];
  }
  content.body = alertBody;
  UNNotificationSound* sound =
  [UNNotificationSound soundNamed:@"voip_call.caf"];
  content.sound = sound;
  content.userInfo = friendInfo;
  UNTimeIntervalNotificationTrigger* tirgger =
  [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1
                                                     repeats:NO];
  UNNotificationRequest* request =
  [UNNotificationRequest requestWithIdentifier:@"ISAVChatNotification"
                                       content:content
                                       trigger:tirgger];
  
  [center addNotificationRequest:request
           withCompletionHandler:^(NSError* _Nullable error) {
             NSLog(@"%@本地推送 :( 报错 %@", @"ISAVChatNotification", error);
           }];
}


@end
