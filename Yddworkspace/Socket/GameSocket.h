//
//  GameSocket.h
//  LiveGameSDK
//
//  Created by ywx on 2017/9/7.
//  Copyright © 2017年 ywx. All rights reserved.
//


#define kSocketHost @"121.196.203.170"
#define kSocketPort 8000

typedef NS_ENUM(NSInteger, GameCenterPersonENUM) {
  PERSON_XIAOQIAO = 0,
  PERSON_DIAOCHAN = 1,
  PERSON_DAQIAO = 2,
  PERSON_SUNSHANGXIAN = 3
  
};
typedef NS_ENUM(NSInteger, GameCardENUM) {
  CARD_XIAOQIAO = 1,  // 小乔
  CARD_DIAOCHAN = 2,  // 貂蝉
  CARD_DAQIAO = 3,  // 大桥
  CARD_SUNSHANGXIAN = 4  // 孙尚香
};

enum GAME_COMMANDS_TAG {
  GAME_COMMANDS_TAG_PING = 1,  // 心跳发
  GAME_COMMANDS_TAG_PONG = 2,  // 心跳收
  GAME_COMMANDS_TAG_SIGNIN = 3,  // 登录
  GAME_COMMANDS_TAG_SIGNOUT = 4,  // 登出
  GAME_COMMANDS_TAG_GAME_LISTS = 10,  // 获取游戏列表
  GAME_COMMANDS_TAG_GAME_INFO = 11,  // 获取游戏配置
  GAME_COMMANDS_TAG_JOIN_IN_CHANNEL = 12,  // 进入频道 丢弃
  GAME_COMMANDS_TAG_BETTING = 13,  // 下注
  GAME_COMMANDS_TAG_BETTING_BROADCAST = 14,  // 下注广播
  GAME_COMMANDS_TAG_BETTING_RESULT = 15,  // 开奖结果
  GAME_COMMANDS_TAG_TIMER = 16,  // 倒计时
  GAME_COMMANDS_TAG_GAME_BACK = 17,  // 游戏返回
  
  GAME_COMMANDS_TAG_GAMES_INFO = 101,  // 获取所有游戏配置
  GAME_COMMANDS_TAG_RUNNING_GAME = 102,  // 获取正在进行中的游戏
  GAME_COMMANDS_TAG_GAME_START = 103,  // 游戏开始
  GAME_COMMANDS_TAG_GAME_JOIN = 104,  // 加入游戏
  GAME_COMMANDS_TAG_GAME_MAINTENANCE = 105  // 游戏服务器维护
};

typedef NS_ENUM(NSInteger, GAME_ALERTVIEWTYPE) {
  GAME_ALERTVIEW_LEAVE = 0,  // 离开
  GAME_ALERTVIEW_RECONNECTSOCKET = 1,  // socket 重连
};

#define kGameMaintenanceDescription @"系统服务器维护,开放时间敬请期待..."

typedef void (^TimeToSocketBlock)(unsigned int timestamp);

@protocol GameSocketDelegate <NSObject>

- (void)backTimeOfGameSocket:(TimeToSocketBlock)block;

- (void)gameWinningResultsMoney:(long long)winningMoney forCid:(int)cid;

- (void)gameloginSucessOfNumber:(long long)amount_money;

@end

@interface GameSocket : NSObject {
  int userId;
  NSString* appid;
  NSString* appkey;
  int partnerId;
  int subPartnerId;
  NSString* cSecurityCodeString;  // 验证元宝code

  int cmGameId;  // 游戏id
  BOOL socketGameBack;  // 暂时离开游戏

  __weak id<GameSocketDelegate> _delegate;
}

@property(nonatomic, weak) id<GameSocketDelegate> _delegate;
@property(nonatomic, assign) int userId;
@property(nonatomic, strong) NSString* appid;
@property(nonatomic, strong) NSString* appkey;
@property(nonatomic, assign) int partnerId;
@property(nonatomic, assign) int subPartnerId;
@property(nonatomic, strong) NSString* cSecurityCodeString;

@property(nonatomic, assign) int cmGameId;
@property(nonatomic, assign) BOOL socketGameBack;

@property(nonatomic, strong) NSString* gameSocketHostStr;
@property(nonatomic, assign) int gameSocketPort;

- (void)connectToServer;

- (void)logoutSocket:(BOOL)isClosed;

- (void)disconnectNetWorkToSocket;

- (void)gameBack;

- (void)selectiveConnectToServerForIsImmediately:(BOOL)isImmediately;

- (void)bettingSocketForGameId:(int)gameId
                      forCarId:(int)carId
                     forAmount:(unsigned long long)amount;

@end
