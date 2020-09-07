//
//  DeviceInfoManger.m
//  Demo
//
//  Created by luming on 2019/11/5.
//  Copyright © 2019年 user. All rights reserved.
//

#import "DeviceInfoManger.h"

#import "sys/utsname.h"
#include <net/if.h>
#include <net/if_dl.h>
#import <sys/ioctl.h>
#import <arpa/inet.h>
#import <AdSupport/AdSupport.h>
#include <sys/sysctl.h>
#import <ifaddrs.h>
#import <resolv.h>

#import <sys/sysctl.h>
#import <mach/mach.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
static DeviceInfoManger *shareInstance;

@implementation DeviceInfoManger

+ (instancetype)manger{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[DeviceInfoManger alloc] init];
    });
    return shareInstance;
}

#pragma mark - setter and getter
- (NSString *)deviceName{
    if (nil == _deviceName) {
        _deviceName = [self getDeviceName];
    }
    return _deviceName;
}

- (NSString *)systemName{
    
    if (nil == _systemName) {
        _systemName = [UIDevice currentDevice].systemName;
    }
    return _systemName;
}

- (NSString *)appVersion{
    
    if (nil == _appVersion) {
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return _appVersion;
}

- (NSString *)batteryLevel{
    
    if (nil == _batteryLevel) {
        _batteryLevel = [NSString stringWithFormat:@"%f",[[UIDevice currentDevice] batteryLevel]];
    }
    
    return _batteryLevel;
}

- (NSString *)iPhoneName{
    
    if (nil == _iPhoneName) {
        _iPhoneName = [UIDevice currentDevice].name;
    }
    return _iPhoneName;
}

-(NSString *)systemVersion{
    
    if (nil == _systemVersion) {
        _systemVersion = [UIDevice currentDevice].systemVersion;
    }
    return _systemVersion;
}

- (NSString *)strUuid{
    
    if (nil == _strUuid) {
        _strUuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return _strUuid;
}

- (NSString *)ipAddress{
    
    if (nil == _ipAddress) {
        _ipAddress = [self getDeviceIPAddresses];
//        _ipAddress = [self getIPAddress:YES];
    }
    return _ipAddress;
}

- (NSString *)ipv4Address
{
    if (nil == _ipv4Address) {
//        _ipv4Address = [self getDeviceIPAddresses];
        _ipv4Address = [self getIPAddress:YES];
    }
    return _ipv4Address;
}

-(NSString *)idfa{
    
    if (nil == _idfa) {
        _idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return _idfa;
}

-(NSString *)idfv{
    
    if (nil == _idfv) {
        _idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return _idfv;
}

-(NSString *)macAddress{
    
    if (nil == _macAddress) {
        _macAddress = [self getMacAddress];
    }
    return _macAddress;
}

#pragma mark -
//mac
- (NSString *)getMacAddress {
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return [outstring uppercaseString];
}

- (NSString *) getDeviceString{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];;
}

// 获取设备型号
- (NSString *)getDeviceName
{
    NSString *deviceString = [self getDeviceString];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"国行(A1863)、日行(A1906)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"美版(Global/A1905)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"国行(A1864)、日行(A1898)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"美版(Global/A1897)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"国行(A1865)、日行(A1902)iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"美版(Global/A1901)iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceString isEqualToString:@"iPod7,1"])      return @"iPod Touch 6";
    if ([deviceString isEqualToString:@"iPod9,1"])      return @"iPod Touch 7";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])     return @"iPad 5";
    if ([deviceString isEqualToString:@"iPad6,12"])     return @"iPad 5";
    if ([deviceString isEqualToString:@"iPad7,1"])      return @"iPad Pro 2(12.9-inch)";
    if ([deviceString isEqualToString:@"iPad7,2"])      return @"iPad Pro 2(12.9-inch)";
    if ([deviceString isEqualToString:@"iPad7,3"])      return @"iPad Pro (10.5-inch)";
    if ([deviceString isEqualToString:@"iPad7,4"])      return @"iPad Pro (10.5-inch)";
    if ([deviceString isEqualToString:@"iPad7,5"])      return @"iPad 6";
    if ([deviceString isEqualToString:@"iPad7,6"])      return @"iPad 6";
    if ([deviceString isEqualToString:@"iPad7,11"])     return @"iPad 7";
    if ([deviceString isEqualToString:@"iPad7,12"])     return @"iPad 7";
    if ([deviceString isEqualToString:@"iPad8,1"])      return @"iPad Pro (11-inch) ";
    if ([deviceString isEqualToString:@"iPad8,2"])      return @"iPad Pro (11-inch) ";
    if ([deviceString isEqualToString:@"iPad8,3"])      return @"iPad Pro (11-inch) ";
    if ([deviceString isEqualToString:@"iPad8,4"])      return @"iPad Pro (11-inch) ";
    if ([deviceString isEqualToString:@"iPad8,5"])      return @"iPad Pro 3 (12.9-inch) ";
    if ([deviceString isEqualToString:@"iPad8,6"])      return @"iPad Pro 3 (12.9-inch) ";
    if ([deviceString isEqualToString:@"iPad8,7"])      return @"iPad Pro 3 (12.9-inch) ";
    if ([deviceString isEqualToString:@"iPad8,8"])      return @"iPad Pro 3 (12.9-inch) ";
    if ([deviceString isEqualToString:@"iPad11,1"])     return @"iPad mini 5";
    if ([deviceString isEqualToString:@"iPad11,2"])     return @"iPad mini 5";
    if ([deviceString isEqualToString:@"iPad11,3"])     return @"iPad Air 3";
    if ([deviceString isEqualToString:@"iPad11,4"])     return @"iPad Air 3";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}

- (BOOL)ipohne6PlusAndbelowWithDeviceStr:(NSString *)deviceStr {
    //    NSArray *array = [deviceString componentsSeparatedByString:@","];
    NSString *deviceString = nil;
    if (deviceStr) {
        deviceString = deviceStr;
    }
    else {
        deviceString = [self getDeviceString];
    }
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone3,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone3,3"])    return YES;
    if ([deviceString isEqualToString:@"iPhone4,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,3"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,4"])    return YES;
    if ([deviceString isEqualToString:@"iPhone6,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone6,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone7,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone7,2"])    return YES;
    
    return NO;
}

- (BOOL)ipohne6sPlusAndbelowWithDeviceStr:(NSString *)deviceStr {
    NSString *deviceString = nil;
    if (deviceStr) {
        deviceString = deviceStr;
    }
    else {
        deviceString = [self getDeviceString];
    }
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone3,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone3,3"])    return YES;
    if ([deviceString isEqualToString:@"iPhone4,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,3"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,4"])    return YES;
    if ([deviceString isEqualToString:@"iPhone6,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone6,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone7,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone7,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone8,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone8,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone8,4"])    return YES;
    
    return NO;
}

- (BOOL)ipohne7PlusAndbelowWithDeviceStr:(NSString *)deviceStr {
    NSString *deviceString = nil;
    if (deviceStr) {
        deviceString = deviceStr;
    }
    else {
        deviceString = [self getDeviceString];
    }
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone3,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone3,3"])    return YES;
    if ([deviceString isEqualToString:@"iPhone4,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,3"])    return YES;
    if ([deviceString isEqualToString:@"iPhone5,4"])    return YES;
    if ([deviceString isEqualToString:@"iPhone6,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone6,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone7,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone7,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone8,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone8,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone8,4"])    return YES;
    if ([deviceString isEqualToString:@"iPhone9,1"])    return YES;
    if ([deviceString isEqualToString:@"iPhone9,3"])    return YES;
    if ([deviceString isEqualToString:@"iPhone9,2"])    return YES;
    if ([deviceString isEqualToString:@"iPhone9,4"])    return YES;
    
    return NO;
}


- (NSString *)getDeviceIPAddresses {
    
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    
    NSMutableArray *ips = [NSMutableArray array];
    
    int BUFFERSIZE = 4096;
    
    struct ifconf ifc;
    
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    
    struct ifreq *ifr, ifrcopy;
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) >= 0){
        
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            
            ifr = (struct ifreq *)ptr;
            int len = sizeof(struct sockaddr);
            
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family != AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) continue;
            
            memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags & IFF_UP) == 0) continue;
            
            NSString *ip = [NSString  stringWithFormat:@"%s", inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    
    close(sockfd);
    NSString *deviceIP = @"";
    
    for (int i=0; i < ips.count; i++) {
        if (ips.count > 0) {
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
        }
    }
    return deviceIP;
}


#pragma mark - 获取ipv4地址
- (NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ? @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] : @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) { address = addresses[key];
        if(address) *stop = YES;
    } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP)
               /* || (interface->ifa_flags & IFF_LOOPBACK) */ )
            { continue; // deeply nested code harder to read
            } const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    } }
                else { const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    } }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                } } }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

// 获取本机DNS服务器
- (NSString *)dns
{
    res_state res = malloc(sizeof(struct __res_state));
    
    int result = res_ninit(res);
    
    NSMutableArray *dnsArray = @[].mutableCopy;
    
    if ( result == 0 )
    {
        for ( int i = 0; i < res->nscount; i++ )
        {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res->nsaddr_list[i].sin_addr)];
            
            [dnsArray addObject:s];
        }
    }
    else{
        NSLog(@"%@",@" res_init result != 0");
    }
    
    res_nclose(res);
    
    return dnsArray.firstObject;
}

- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return taskInfo.resident_size / 1024.0 / 1024.0;
}



@end
