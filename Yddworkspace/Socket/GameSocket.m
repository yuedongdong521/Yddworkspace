//
//  GameSocket.m
//  LiveGameSDK
//
//  Created by ywx on 2017/9/7.
//  Copyright © 2017年 ywx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameSocket.h"
#import "GCDAsyncSocket.h"
#import "JSONKit.h"
#import "CmCMethod.h"


@interface GameSocket () <GCDAsyncSocketDelegate> {
  // {
  // socket
  GCDAsyncSocket* asynSocket;
  NSTimer* timerSocket;  // 心跳-1
  int timerCountSeconds;  // 心跳-2
  int gameTimerCount;  // 游戏里的时间
  BOOL gameTimerContrls;  // 防止游戏到0秒后通知多次
  int socketReconnectCount;  // socket非正常断开，重连的次数，一般是3次
  int leaveTimeCount;  // 暂时离开游戏的时间，2分钟内没回来就断开socket
  BOOL socketStop;  // 正常socket断开
  int gameLoginCount;  // 登录次数，每次连接超过3次就认为登录失败关闭socket
  BOOL isGameLogin;
  unsigned long long msgid;  // 用于标记每次的下注请求，服务端原样返回
  unsigned long long recordMsgid;  // 用于记录服务端原样返回的下注标记
}

@property(nonatomic, assign) int addFriendVerifyType;

@property(nonatomic, assign) unsigned long long msgid;
@property(nonatomic, assign) unsigned long long recordMsgid;

@end

@implementation GameSocket
@synthesize _delegate;
@synthesize cmGameId;
@synthesize socketGameBack;
@synthesize userId, appid, appkey, partnerId, subPartnerId, cSecurityCodeString;
@synthesize msgid, recordMsgid;

- (id)init {
  self = [super init];
  if (self) {
    // {
    timerCountSeconds = 0;
    gameTimerCount = 0;
    socketReconnectCount = 0;
    gameTimerContrls = NO;
    leaveTimeCount = 0;
    socketStop = NO;
    cmGameId = 0;
    gameLoginCount = 0;
    socketGameBack = YES;
    isGameLogin = NO;
    msgid = 0;
    recordMsgid = 0;
    // }
    //
    userId = 0;
    self.appid = @"";
    self.appkey = @"";
    partnerId = 0;
    subPartnerId = 0;
    self.cSecurityCodeString = @"00000000";
    //
    self.gameSocketHostStr = kSocketHost;
    self.gameSocketPort = kSocketPort;
  }
  return self;
}
- (void)gameDataReset {
  cmGameId = 0;
  gameTimerCount = 0;
  leaveTimeCount = 0;
  socketGameBack = NO;
  gameTimerContrls = NO;
}
#pragma mark GCDAsyncSocket {
- (void)timerSocketStart {
  if (timerSocket == nil) {
    timerSocket = [NSTimer
        scheduledTimerWithTimeInterval:1
                                target:self
                              selector:@selector(timerToSocketheartbeat)
                              userInfo:nil
                               repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timerSocket
                                 forMode:NSRunLoopCommonModes];
  }
}
- (void)timerSocketStop {
  if (timerSocket) {
    if ([timerSocket isValid]) {
      [timerSocket invalidate];
    }
    timerSocket = nil;
  }
}
- (void)timerToSocketheartbeat {
  // 心跳
  timerCountSeconds++;
  if (timerCountSeconds >= 29) {
    timerCountSeconds = 0;
    [self longConnectToSocket];
  }
  // 时刻读取
  if (asynSocket) {
    [asynSocket readDataWithTimeout:-1 tag:0];
  }
  //    // 游戏返回不进入
  //    if (socketGameBack == NO) {
  if (gameTimerContrls) {
    if (gameTimerCount == 0) {
      gameTimerContrls = NO;
    }
    NSLog(@"cm_game_time_changed:%d", gameTimerCount);
    // .

    // .更新游戏时间
    if (gameTimerCount > 0) {
      gameTimerCount--;
    }
  }
  //    }
  // .离开时间
  if (socketGameBack) {
    leaveTimeCount++;
    if (leaveTimeCount >= 120) {
      leaveTimeCount = 0;
      [self logoutSocket:YES];
      return;
    }
  }
}
/*1.Error Domain=GCDAsyncSocketErrorDomain Code=4 "Read operation timed out"
 UserInfo=0xa8db6a0 {NSLocalizedDescription=Read operation timed out}
 scoket读取数据超时，当网络不怎么稳定通信方给发送消息的时候时不时的会冒一个这个错误，而且Socket也会自动断开连接。一直跟踪GCDAsyncSocket.m的代码5068行<可能代码有更新的会有点差异>有一个方法
 - (void)setupReadTimerWithTimeout:(NSTimeInterval)timeout
 这个方法是就是专门监听socket读取数据是否有超时的现象的方法,源代码设置成if(timeout
 >= 0.0)即检测到超时就抛异常 这样很容易导致socket连接异常。
 处理方式：你可以打印一下这个timeout值，就会大概知道你的socket读取数据超时的范围，在项目允许的范围内设置这个值的大小，因为我的项目总是在10以内，所以我设置成if(timeout
 >
 10.0)之后，基本运行的时候就很少抛这个异常了。你也可以再接收到这个异常的时候重新连接一次。
 2.Error Domain=GCDAsyncSocketErrorDomain Code=3 "Attempt to connect to host
 timed out" UserInfo=0x7bd14f40 {NSLocalizedDescription=Attempt to connect to
 host timed out}
 socket连接的时候超时，一般发生在你向服务端发送一条连接消息的时候，服务端无响应，一般是由于服务端没有开启服务，也有可能是设置响应时间的timeout值过小，在GCDAsyncSocket.m的代码1938行的位置有一个设置timeout的地方
 你可以设置一个稍微比较长的响应时间
 - (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError
 **)errPtr
 {
 return [self connectToHost:host onPort:port withTimeout:5 error:errPtr];
 }
 3.Error Domain=GCDAsyncSocketErrorDomain
 Code=51，网络断开，可以检查一下网络连接状态
 4.Error Domain=NSPOSIXErrorDomain Code=61 "Connection refused"
 UserInfo=0x7b288750 {NSLocalizedFailureReason=Error in connect() function,
 NSLocalizedDescription=Connection refused}
 服务器没启动，或者端口没开启。
 */
// 建立socket连接
- (void)connectToServer {
  //
  [[self class]
      cancelPreviousPerformRequestsWithTarget:self
                                     selector:@selector(connectToServer)
                                       object:nil];
  //
  if (asynSocket) {
    if (asynSocket.isConnected) {
      socketGameBack = NO;
      leaveTimeCount = 0;
      return;
    }
  }
  // .与服务器通过三次握手建立连接
  NSString* host = self.gameSocketHostStr;
  int port = self.gameSocketPort;
  // .创建一个socket对象
  if (!asynSocket) {
    asynSocket = [[GCDAsyncSocket alloc]
        initWithDelegate:self
           delegateQueue:dispatch_get_global_queue(
                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
  }
  // .连接
  NSError* error = nil;
  [asynSocket connectToHost:host onPort:port error:&error];
  if (error) {
    NSLog(@"Socket连接错误%@", error);
  }
}
// 重连
- (void)reconnectToServer {
  [self performSelector:@selector(connectToServer) withObject:nil afterDelay:3];
}
// 断开socket连接
- (void)disconnectLongConnectToSocket {
  if (asynSocket) {
    socketStop = YES;
    if (asynSocket.isConnected) {
      [asynSocket disconnect];
    }
  }
}
// 断网重连
- (void)disconnectNetWorkToSocket {
  if (asynSocket) {
    if (cmGameId != 0) {
      [self selectiveConnectToServerForIsImmediately:NO];
    }
  }
}
// 选择性连接
- (void)selectiveConnectToServerForIsImmediately:(BOOL)isImmediately {
  if (asynSocket) {
    if (socketStop == NO || isImmediately == YES) {
      if (asynSocket.isConnected) {
        if (cmGameId != 0) {
          // .socket命令：获取正在进行中的游戏
          [self gameRunningSocket];
        }
      } else {
        //
        [self reconnectToServer];
      }
    }
  }
}
// 游戏返回
- (void)gameBack {
  if (asynSocket) {
    if (asynSocket.isConnected) {
      //      [self performSelector:@selector(logoutSocket_delay)
      //                 withObject:nil
      //                 afterDelay:gameTimerCount + 5];
    }
  }
}
// socket命令：登录
- (void)loginSocket {
  NSString* uidString = [NSString stringWithFormat:@"%d", self.userId];
  if (_delegate &&
      [_delegate respondsToSelector:@selector(backTimeOfGameSocket:)]) {
    [_delegate backTimeOfGameSocket:^(unsigned int timestamp) {
      NSNumber* loginNumber = [NSNumber numberWithInt:GAME_COMMANDS_TAG_SIGNIN];
      NSString* timestampStr = [NSString stringWithFormat:@"%u", timestamp];
      NSString* string1 = [NSString stringWithFormat:@"%@", self.appid];
      NSString* string2 = [NSString stringWithFormat:@"%d", partnerId];
      NSString* string3 = [NSString stringWithFormat:@"%d", subPartnerId];
      // @"command":loginNumber,
      NSDictionary* socketDict1 = @{
        @"appid" : string1,
        @"uid" : uidString,
        @"time" : timestampStr,
        @"sign_type" : @"md5",
        @"partnerid" : string2,
        @"sub_partnerid" : string3
      };
      [CmCMethod
          keyCompareToSignForDict:socketDict1
                     forParameter:@"/game/command/3"
                           forKey:self.appkey
                    forHTTPMethod:@"PIPE"
                  blockcompletion:^(NSString* bodyString) {
                    if (bodyString.length > 32) {
                      NSString* string = [bodyString
                          substringFromIndex:bodyString.length - 32];
                      NSDictionary* socketDict = @{
                        @"appid" : string1,
                        @"sign_type" : @"md5",
                        @"time" : timestampStr,
                        @"uid" : uidString,
                        @"sign" : string,
                        @"command" : loginNumber,
                        @"partnerid" : string2,
                        @"sub_partnerid" : string3
                      };
                      NSString* cjsonStirng = [NSString
                          stringWithFormat:@"%@%@", [socketDict JSONString],
                                           @"\n"];
                      NSData* dataStream =
                          [cjsonStirng dataUsingEncoding:NSUTF8StringEncoding];
                      [asynSocket writeData:dataStream withTimeout:-1 tag:1];
                    }
                  }];
    }];
  }
}
// socket命令：登出
- (void)logoutSocket_delay {
  // [self gameBackSocketForGameId:cmGameId];
}
- (void)logoutSocket:(BOOL)isClosed {
  if (asynSocket) {
    if (isClosed == NO) {
      socketGameBack = YES;
      //      [self performSelector:@selector(logoutSocket_delay)
      //                 withObject:nil
      //                 afterDelay:gameTimerCount + 5];
    } else {
      if (asynSocket.isConnected) {
        cmGameId = 0;
        isGameLogin = NO;
        NSString* longConnect =
            [NSString stringWithFormat:@"%ld", (long)GAME_COMMANDS_TAG_SIGNOUT];
        NSDictionary* socketDict = @{@"command" : longConnect};
        NSString* cjsonStirng =
            [NSString stringWithFormat:@"%@%@", [socketDict JSONString], @"\n"];
        NSData* dataStream =
            [cjsonStirng dataUsingEncoding:NSUTF8StringEncoding];
        [asynSocket writeData:dataStream withTimeout:-1 tag:1];
        //
        [self timerSocketStop];
        [self disconnectLongConnectToSocket];
      }
    }
  }
}
// socket命令：心跳
- (void)longConnectToSocket {
  if (asynSocket) {
    NSNumber* longConnectNumber =
        [NSNumber numberWithInt:GAME_COMMANDS_TAG_PING];
    NSDictionary* socketDict = @{@"command" : longConnectNumber};
    NSString* cjsonStirng =
        [NSString stringWithFormat:@"%@%@", [socketDict JSONString], @"\n"];
    NSData* dataStream = [cjsonStirng dataUsingEncoding:NSUTF8StringEncoding];
    [asynSocket writeData:dataStream withTimeout:-1 tag:1];
  }
}
// socket命令：游戏列表 // 废弃
- (void)gameListSocket {
  if (asynSocket) {
    //    NSNumber* gameListsNumber =
    //        [NSNumber numberWithInt:GAME_COMMANDS_TAG_GAME_LISTS];
    //    NSDictionary* socketDict = @{ @"command" : gameListsNumber };
    //    NSString* cjsonStirng =
    //        [NSString stringWithFormat:@"%@%@", [socketDict JSONString],
    //        @"\n"];
    //    NSData* dataStream = [cjsonStirng
    //    dataUsingEncoding:NSUTF8StringEncoding];
    //    [asynSocket writeData:dataStream withTimeout:-1 tag:1];
  }
}
// socket命令：获取所有游戏配置
- (void)gameInfosSocket {
  if (asynSocket) {
    NSNumber* gameInfosNumber =
        [NSNumber numberWithInt:GAME_COMMANDS_TAG_GAMES_INFO];
    NSDictionary* socketDict = @{@"command" : gameInfosNumber};
    NSString* cjsonStirng =
        [NSString stringWithFormat:@"%@%@", [socketDict JSONString], @"\n"];
    NSData* dataStream = [cjsonStirng dataUsingEncoding:NSUTF8StringEncoding];
    [asynSocket writeData:dataStream withTimeout:-1 tag:1];
  }
}
// socket命令：获取正在进行中的游戏;ID/下注金额列表/剩余时间，并自动加入游戏
- (void)gameRunningSocket {
  if (asynSocket) {
    //
    //    [[self class]
    //        cancelPreviousPerformRequestsWithTarget:self
    //                                       selector:@selector(logoutSocket_delay)
    //                                         object:nil];
    NSNumber* gameRunningNumber =
        [NSNumber numberWithInt:GAME_COMMANDS_TAG_RUNNING_GAME];
    NSDictionary* socketDict = @{@"command" : gameRunningNumber};
    NSString* cjsonStirng =
        [NSString stringWithFormat:@"%@%@", [socketDict JSONString], @"\n"];
    NSData* dataStream = [cjsonStirng dataUsingEncoding:NSUTF8StringEncoding];
    [asynSocket writeData:dataStream withTimeout:-1 tag:1];
  }
}
// socket命令：游戏配置 // 废弃
- (void)gameInfoSocketForGameId:(int)gameId {
  if (asynSocket) {
    //    //
    //    [[self class]
    //        cancelPreviousPerformRequestsWithTarget:self
    //                                       selector:@selector(logoutSocket_delay)
    //                                         object:nil];
    //    //
    //    cmGameId = gameId;
    //    NSNumber* gameInfoNumber =
    //        [NSNumber numberWithInt:GAME_COMMANDS_TAG_GAME_INFO];
    //    NSNumber* gameIdNumber = [NSNumber numberWithInt:gameId];
    //    NSDictionary* socketDict =
    //        @{ @"command" : gameInfoNumber,
    //           @"gameid" : gameIdNumber };
    //    NSString* cjsonStirng =
    //        [NSString stringWithFormat:@"%@%@", [socketDict JSONString],
    //        @"\n"];
    //    NSData* dataStream = [cjsonStirng
    //    dataUsingEncoding:NSUTF8StringEncoding];
    //    [asynSocket writeData:dataStream withTimeout:-1 tag:1];
  }
}
// socket命令：游戏返回
- (void)gameBackSocketForGameId:(int)gameId {
  NSNumber* gameInfoNumber =
      [NSNumber numberWithInt:GAME_COMMANDS_TAG_GAME_BACK];
  NSNumber* gameIdNumber = [NSNumber numberWithInt:gameId];
  NSDictionary* socketDict =
      @{@"command" : gameInfoNumber, @"gameid" : gameIdNumber};
  NSString* cjsonStirng =
      [NSString stringWithFormat:@"%@%@", [socketDict JSONString], @"\n"];
  NSData* dataStream = [cjsonStirng dataUsingEncoding:NSUTF8StringEncoding];
  [asynSocket writeData:dataStream withTimeout:-1 tag:1];
}
// socket命令：下注
- (void)bettingSocketForGameId:(int)gameId
                      forCarId:(int)carId
                     forAmount:(unsigned long long)amount {
  if (asynSocket) {
    msgid++;

    NSNumber* bettingNumber =
        [NSNumber numberWithInt:GAME_COMMANDS_TAG_BETTING];
    NSNumber* gameIdNumber = [NSNumber numberWithInt:gameId];
    NSNumber* caridNumber = [NSNumber numberWithInt:carId];
    NSNumber* amountNumber = [NSNumber numberWithUnsignedLongLong:amount];
    NSNumber* msgidNumber = [NSNumber numberWithUnsignedLongLong:msgid];
    NSLog(@"SecurityCode1:%@", self.cSecurityCodeString);
    NSDictionary* socketDict = @{
      @"command" : bettingNumber,
      @"gameid" : gameIdNumber,
      @"cardid" : caridNumber,
      @"amount" : amountNumber,
      @"passwd" : self.cSecurityCodeString,
      @"msgid" : msgidNumber
    };
    NSString* cjsonStirng =
        [NSString stringWithFormat:@"%@%@", [socketDict JSONString], @"\n"];
    NSData* dataStream = [cjsonStirng dataUsingEncoding:NSUTF8StringEncoding];
    [asynSocket writeData:dataStream withTimeout:-1 tag:1];
  }
}
// -socket的代理
// 连接成功
- (void)socket:(GCDAsyncSocket*)sock
    didConnectToHost:(NSString*)host
                port:(uint16_t)port {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"Socket连接成功");
    socketReconnectCount = 0;
    leaveTimeCount = 0;
    socketStop = NO;
    gameLoginCount = 0;
    socketGameBack = NO;
    // socket命令：登录
    [self loginSocket];
    // socket命令：心跳
    [self timerSocketStart];
  });
}
- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)err {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (err) {
      if (socketReconnectCount < 3) {
        socketReconnectCount++;
        if (err.code == 4) {
          NSLog(@"Socket读取超时(%@)", err);
          // 重连
          [self reconnectToServer];
        } else {
          NSLog(@"Socket连接失败(%@)", err);
          // 重连
          [self reconnectToServer];
        }
      } else {
        NSLog(@"Socket连接失败(%@)", err);
        [self timerSocketStop];
        [self disconnectLongConnectToSocket];
        //
      }
    } else {
      NSLog(@"Socket正常断开");
      [self timerSocketStop];
    }
  });
}
// 数据发送成功
- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag {
  //    // 发送完数据手动读取，-1不设置超时
  [sock readDataWithTimeout:-1 tag:tag];
}
// 读取数据
- (void)getSalesToAppdelegate_delay:(NSNumber*)amountNumber forCid:(int)cid {
  if (_delegate && [_delegate respondsToSelector:@selector
                              (gameWinningResultsMoney:forCid:)]) {
    [_delegate gameWinningResultsMoney:[amountNumber longLongValue] forCid:cid];
  }
}
- (void)gameDataClosed {
  [self gameDataReset];

}
- (BOOL)socketDataForData:(NSData*)data {
  if (data) {
    NSError* error = nil;
    id jsonObject =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingAllowFragments
                                          error:&error];
   
  }
  return NO;
}
// 比如对方写入2048 kb的数据，每次didReadData 可能才收到
// 1024的大小，你要收集至完整的一次包。
// 这方法里是子线程
- (void)socket:(GCDAsyncSocket*)sock
    didReadData:(NSData*)data
        withTag:(long)tag {
  dispatch_async(dispatch_get_main_queue(), ^{
    BOOL isNotRead = NO;
    if (data) {
      NSString* receiverStr =
          [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      NSLog(@"socket_content:%@", receiverStr);
      if (receiverStr && [receiverStr length] > 0) {
        NSString* cmstring0 =
            @"command\":16,\"timer\":0";  // @"command\":16,\"timer\":0";
        NSString* cmstring30 =
            @"command\":102";  // @"command\":16,\"timer\":30";
        NSString* cmstring31 = @"command\":103";
        NSArray* cmArray = [receiverStr componentsSeparatedByString:@"\n"];
        for (int i = 0; i < cmArray.count; i++) {
          NSString* cmString = [cmArray objectAtIndex:i];
          if (cmString && [cmString length] > 0) {
            if ([cmString containsString:cmstring0]) {
              if ([receiverStr containsString:cmstring30] ||
                  [receiverStr containsString:cmstring31]) {
                continue;
              }
            }
            //
            NSData* cmdata = [cmString dataUsingEncoding:NSUTF8StringEncoding];
            isNotRead = [self socketDataForData:cmdata];
          }
        }
      }
    }
    //
    if (isNotRead == NO) {
      [sock readDataWithTimeout:-1 tag:tag];
    }

    //
    //        BOOL isNotRead = NO;
    //        if (data) {
    //            int lengthInt = 4;
    //            NSString *receiverStr = [[NSString alloc] initWithData:data
    //            encoding:NSUTF8StringEncoding];
    //            NSLog(@"Socket接收数据：%@",receiverStr);
    //            if (receiverStr && [receiverStr length] > lengthInt) {
    //                NSString *newString = nil;
    //                while (1) {//看上去死循环
    //                    //.下一轮没有值了
    //                    if (newString && [newString length] < 1) {
    //                        break;
    //                    }
    //                    //.判断5位，匹配前4位是不是数字，最后一位是{，例如：0024{
    //                    NSString *zerostring = nil;
    //                    if (newString == nil) {
    //                        zerostring = [receiverStr
    //                        substringToIndex:lengthInt+1];
    //                    }
    //                    else {
    //                        zerostring = [newString
    //                        substringToIndex:lengthInt+1];
    //                    }
    //                    BOOL ismatch = [[AppDelegate
    //                    appDelegate].cmCommonMethod
    //                    cmPredicateStringForString:zerostring
    //                    forPredicateString:@"^[0-9]{4}[{]{1}"];
    //                    if (!ismatch) {
    //
    //                        NSArray *cmArray = [receiverStr
    //                        componentsSeparatedByString:@"\n"];
    //                        for (int i = 0; i < cmArray.count; i++) {
    //                            NSString *cmString = [cmArray
    //                            objectAtIndex:i];
    //                            if (cmString && [cmString length] > 0) {
    //                                NSData *cmdata = [cmString
    //                                dataUsingEncoding:NSUTF8StringEncoding];
    //                                isNotRead = [self
    //                                socketDataForData:cmdata];
    //                            }
    //                        }
    //
    //                        break;
    //                    }
    //                    //.json数据长度
    //                    NSString *onestring = nil;
    //                    if (newString == nil) {
    //                        onestring = [receiverStr
    //                        substringToIndex:lengthInt];
    //                    }
    //                    else {
    //                        onestring = [newString
    //                        substringToIndex:lengthInt];
    //                    }
    //                    int topInt = [onestring intValue];
    //                    //整个string长度要大于json数据长度
    //                    NSInteger datalength = 0;
    //                    if (newString == nil) {
    //                        datalength = [receiverStr length];
    //                    }
    //                    else {
    //                        datalength = [newString length];
    //                    }
    //                    if (datalength > topInt) {
    //                        //根据长度拿到json数据
    //                        NSString *twostring = nil;
    //                        if (newString == nil) {
    //                            twostring = [receiverStr
    //                            substringWithRange:NSMakeRange(lengthInt,topInt)];
    //                        }
    //                        else {
    //                            twostring = [newString
    //                            substringWithRange:NSMakeRange(lengthInt,topInt)];
    //                        }
    //                        NSData *cmdata = [twostring
    //                        dataUsingEncoding:NSUTF8StringEncoding];
    //                        isNotRead = [self socketDataForData:cmdata];
    //                        //
    //                        if (datalength > (lengthInt+topInt)) {
    //                            if (newString == nil) {
    //                                newString = [receiverStr
    //                                substringFromIndex:(lengthInt+topInt)];
    //                            }
    //                            else {
    //                                newString = [newString
    //                                substringFromIndex:(lengthInt+topInt)];
    //                            }
    //                        }
    //                        else {
    //                            newString = @"";
    //                        }
    //                    }
    //                    else {//暂不考虑断包
    //                        break;
    //                    }
    //                }
    //            }
    //            else {
    //                NSLog(@"Socket接收数据失败：%@(tag:%ld)",receiverStr,tag);
    //            }
    //        }
    //        else {
    //            NSLog(@"Socket接收数据失败：无data");
    //        }
    //
    //        if (isNotRead == NO) {
    //            [sock readDataWithTimeout:-1 tag:tag];
    //        }

    //
    //        BOOL isNotRead = NO;
    //        if (data) {
    //            int lengthInt = 4;
    //            NSString *receiverStr = [[NSString alloc] initWithData:data
    //            encoding:NSUTF8StringEncoding];
    //            NSLog(@"Socket接收数据：%@",receiverStr);
    //            if (receiverStr && [receiverStr length] > lengthInt) {
    //                NSString *newString = nil;
    //                while (1) {//看上去死循环
    //                    //.下一轮没有值了
    //                    if (newString && [newString length] < 1) {
    //                        break;
    //                    }
    //                    //.判断5位，匹配前4位是不是数字，最后一位是{，例如：0024{
    //                    NSString *zerostring = nil;
    //                    if (newString == nil) {
    //                        zerostring = [receiverStr
    //                        substringToIndex:lengthInt+1];
    //                    }
    //                    else {
    //                        zerostring = [newString
    //                        substringToIndex:lengthInt+1];
    //                    }
    //                    BOOL ismatch = [[AppDelegate
    //                    appDelegate].cmCommonMethod
    //                    cmPredicateStringForString:zerostring
    //                    forPredicateString:@"^[0-9]{4}[{]{1}"];
    //                    if (!ismatch) {
    //                        break;
    //                    }
    //                    //.json数据长度
    //                    NSString *onestring = nil;
    //                    if (newString == nil) {
    //                        onestring = [receiverStr
    //                        substringToIndex:lengthInt];
    //                    }
    //                    else {
    //                        onestring = [newString
    //                        substringToIndex:lengthInt];
    //                    }
    //                    int topInt = [onestring intValue];
    //                    //整个string长度要大于json数据长度
    //                    NSInteger datalength = 0;
    //                    if (newString == nil) {
    //                        datalength = [receiverStr length];
    //                    }
    //                    else {
    //                        datalength = [newString length];
    //                    }
    //                    if (datalength > topInt) {
    //                        //根据长度拿到json数据
    //                        NSString *twostring = nil;
    //                        if (newString == nil) {
    //                            twostring = [receiverStr
    //                            substringWithRange:NSMakeRange(lengthInt,topInt)];
    //                        }
    //                        else {
    //                            twostring = [newString
    //                            substringWithRange:NSMakeRange(lengthInt,topInt)];
    //                        }
    //                        NSData *cmdata = [twostring
    //                        dataUsingEncoding:NSUTF8StringEncoding];
    //                        isNotRead = [self socketDataForData:cmdata];
    //                        //
    //                        if (datalength > (lengthInt+topInt)) {
    //                            if (newString == nil) {
    //                                newString = [receiverStr
    //                                substringFromIndex:(lengthInt+topInt)];
    //                            }
    //                            else {
    //                                newString = [newString
    //                                substringFromIndex:(lengthInt+topInt)];
    //                            }
    //                        }
    //                        else {
    //                            newString = @"";
    //                        }
    //                    }
    //                    else {//暂不考虑断包
    //                        break;
    //                    }
    //                }
    //            }
    //            else {
    //                NSLog(@"Socket接收数据失败：%@(tag:%ld)",receiverStr,tag);
    //            }
    //        }
    //        else {
    //            NSLog(@"Socket接收数据失败：无data");
    //        }
    //        if (isNotRead == NO) {
    //
    //        [sock readDataWithTimeout:-1 tag:tag];
    //    }
  });
}
#pragma mark }

- (void)dealloc {
  //
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  //
  NSLog(@"GameSocket release");
}

@end
