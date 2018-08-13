//
//  Config.h
//  SUNTV
//
//  Created by Dongwu Wang on 11-5-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

// #import "FileOperation.h"

#define DK_SYSTEM_VERSION_SUPPORT_7_0 \
  [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0

#define UploadProgressNotification @"uploadProgressNotification"
#define Ku6CheckVersionUpdate @"Ku6CheckVersionUpdate"
#define WillEnterResignNotification @"WillEnterResignNotification"

#define DK_NOTIF_ENCODING_NOTIFICATION_PROGRESS \
  @"DK_NOTIF_ENCODING_NOTIFICATION_PROGRESS"

#define NOTIF_SHOW_LOGIN_PANEL @"NOTIF_SHOW_LOGIN_PANEL"
#define NOTIF_SHOW_SERVICE_ERR_INFO @"NOTIF_SHOW_SERVICE_ERR_INFO"
#define NOTIF_GET_APNS @"NOTIF_GET_APNS"
#define NOTIF_SHOW_MESSAGE @"NOTIF_SHOW_MESSAGE"
#define NOTIF_REFRESH_VIDEO_COMMENT_COUNT @"NOTIF_REFRESH_VIDEO_COMMENT_COUNT"

#define NOTIF_SHOW_MESSAGE_VC @"NOTIF_SHOW_MESSAGE_VC"
#define NOTIF_SHOW_SQUARE_VC @"NOTIF_SHOW_SQUARE_VC"
#define NOTIF_SHOW_HOMEPAGE_VC @"NOTIF_SHOW_HOMEPAGE_VC"

#define FontName @"FZLiShu-S01S"

#define APPNAME @"iPhoKu6Duanku"
// #define APPNAME                   @"testDuanku"

#define DATEFORSHELVES @"2013.1.5"

#define UseDataChargeShelves @"1"

// #define UUID                      [FileOperation MD5:[FileOperation macaddress]]

#define NetNotReachablePrompt @"网络连接异常，请配置好网络后重试!"

#define UPLOADOfTimeout 18000.0f
#define IMAGEOfTimeout 20.0f
#define INTERVALOfTimeout 20.0f

#define kAPIRequestRequestorKey @"kAPIRequestRequestorKey"
#define kAPIRequestCodeKey @"kAPIRequestCodeKey"
#define kAPIRequestUrl @"kAPIRequestUrl"

#define kAPIRequestUploadURLKey @"kAPIRequestUploadURLKey"
#define kAPIRequestUploadKey @"kAPIRequestUploadKey"
#define kAPIRequestAddVideoKey @"kAPIRequestAddVideoKey"

#define kAPIRequestThumbnailURLKey @"kAPIRequestThumbnailURLKey"
#define kAPIRequestUploadThumbnailKey @"kAPIRequestUploadThumbnailKey"

#define KAPIRequestAddUser @"KAPIRequestAddUser"
#define KAPIRequestLogin @"KAPIRequestLogin"
#define kAPIRequestWithSNS @"kAPIRequestWithSNS"
#define KAPIRequestRegister @"KAPIRequestRegister"
#define KAPIRequestLoginWithPhone @"KAPIRequestLoginWithPhone"
#define KAPIRequestFindPsw @"KAPIRequestFindPsw"
#define KAPIRequestGetUserInfo @"KAPIRequestGetUserInfo"
#define KAPIRequestLoginKu6WithPhone @"KAPIRequestLoginKu6WithPhone"
#define KAPIRequestListData @"KAPIRequestListData"
#define KAPIRequestImage @"KAPIRequestImage"

#define KAPIRequestAppRecommend @"km/recommend/app"

#define REQUESTSTART @"begin"
#define REQUESTUPLOADING @"uploading"
#define REQUESTSTATUS @"status"

#define REQUESTSUCCES @"succes"
#define REQUESTWRONG @"wrong"
#define RESPONSEDATA @"data"

#define kFilePath @"filePath"
#define REQUESTCOOKIE @"REQUESTCOOKIE"
#define RESPONSECOOKIE @"RESPONSECOOKIE"

#define REQUESTCOOKIE @"REQUESTCOOKIE"
#define RESPONSECOOKIE @"RESPONSECOOKIE"
#define REQUESRT_ID @"REQUESRT_ID"
#define LOGINCOOKIES @"loginCookie.plist"

#define USER_INFO_DESC @"USER_INFO_DESC"
#define USER_INFO_ICON @"USER_INFO_ICON"

#define APNS_TOKEN @"APNS_TOKEN"
#define APNS_UID_BOUND @"APNS_UID_BOUND"
#define APNS_UNREAD_COUNT @"APNS_UNREAD_COUNT"
#define APNS_UNREAD_USERMSG_COUNT @"APNS_UNREAD_USERMSG_COUNT"

// 推广渠道
#define App_Stroe @"Ku6IOS0000"
#define Ku6 @"Ku6IOS0001"
#define Wei_Feng @"Ku6IOS0002"
#define JiuYao_IPhone @"Ku6IOS0004"
#define JiKeWang @"Ku6IOS0020"
#define LianTong @"Ku6GOS0024"
#define Paojiao @"Ku6IOS0009"
#define PPAssistant @"Ku6IOS0022"
#define TongbuAssistant @"Ku6IOS0023"
#define Liqu @"Ku6IOS0024"
#define BaiXinZhongLian @"Ku6IOS0025"
#define AiSiAssistant @"Ku6IOS0026"
#define Baidu @"Ku6IOS0068"

// 主站服务器
// #define KU6BASEURL                @"http://my.ku6.com/"  // 生产环境
#define KU6BASEURLNEW @"http://new.ku6.com/"
#define kIOS @"ios?"
#define kLOGINURL @"mobile/logindkwoa?"  // @"mobile/loginforsnda?"

#define KU6DOMAINURL @"http://mapi.ku6.com"
// #warning 当前是测试环境
// #define KU6DOMAINURL              @"http://122.11.32.135"

#define ADDUSER @"/dk/user/add?"
// 0:初始状态，真 1:假　2:真
#define UserDefaultNetKey @"UserDefaultNetKey"
#define UserDefaultUserNameSd @"UserDefaultUserNameSd"
#define UserDefaultUserNamePhone @"UserDefaultUserNamePhone"
#define UserDefaultUserCountry @"UserDefaultUserCountry"
#define UserDefaultMobile @"UserDefaultMobile"

// 微薄类型、ID
#define SNDALOGIN_CODE @"0"
#define SINALOGIN_CODE @"1"
#define QQLOGIN_CODE @"2"
#define RENRENLOGIN_CODE @"3"
#define WANGYILOGIN_CODE @"4"

#define SNDATX @"盛大通行证"
#define SINAWEIBO @"新浪微博帐号"
#define QQWEIBO @"QQ微博帐号"
#define RENRENWANG @"人人网帐号"
#define WANGYIWEIBO @"网易微博帐号"

#define IPHONE_5                                                     \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]      \
       ? CGSizeEqualToSize(CGSizeMake(640, 1136),                    \
                           [[UIScreen mainScreen] currentMode].size) \
       : NO)
#define MUICOLOR(r, g, b, a) \
  [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define PHOTOMAXCOUNT 5
#define DYNAMICPHOTOMAXCOUNT \
  [AppDelegate appDelegate].appDelegatePlatformUserStructure.MaxPhotoCount
#define DYNAMICPHOTOSHOWCOUNT 9
// 关掉蜂窝网络后上传下载提示
// #define NoWifiTips              @"当前没有WIFI网络，暂时不能进行上传或下载，如果想继续，请修改设置项"
