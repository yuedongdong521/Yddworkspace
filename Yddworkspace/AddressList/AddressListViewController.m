//
//  AddressListViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/2/14.
//  Copyright © 2019 QH. All rights reserved.
//

#import "AddressListViewController.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

@interface AddressListViewController ()

@property(nonatomic, strong) NSMutableDictionary *contactsDic;

@end

@implementation AddressListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [self requestContactAuthorAfterSystemVersion9];
//  [self requestContactAuthor];
  
}

- (BOOL)isMobile:(NSString*)mobileNumbel {
  mobileNumbel =
  [mobileNumbel stringByReplacingOccurrencesOfString:@" " withString:@""];
  if (mobileNumbel.length != 11) {
    return NO;
  }
  
  /**
   * 手机号码:
   * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
   * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
   * 联通号段: 130,131,132,155,156,185,186,145,176,1709
   * 电信号段: 133,153,180,181,189,177,1700
   */
  NSString* MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[03678])\\d{8}$";
  NSPredicate* regextestMobile =
  [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
  return [regextestMobile evaluateWithObject:mobileNumbel];
  /**
   * 中国移动：China Mobile
   * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
   */
  // NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
  /**
   * 中国联通：China Unicom
   * 130,131,132,155,156,185,186,145,176,173,1709
   */
  // NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
  /**
   * 中国电信：China Telecom
   * 133,153,180,181,189,177,1700
   */
  // NSString *CT = @"(^1(33|53|7[37]|8[019])\\d{8}$)|(^1700\\d{7}$)";
  /**
   25     * 大陆地区固话及小灵通
   26     * 区号：010,020,021,022,023,024,025,027,028,029
   27     * 号码：七位或八位
   28     */
  //  NSString * PHS = @"^(0[0-9]{2})\\d{8}$|^(0[0-9]{3}(\\d{7,8}))$";
  /*NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
   NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
   NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
   NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
   if (([regextestmobile evaluateWithObject:mobileNumbel] == YES)
   || ([regextestcm evaluateWithObject:mobileNumbel] == YES)
   || ([regextestct evaluateWithObject:mobileNumbel] == YES)
   || ([regextestcu evaluateWithObject:mobileNumbel] == YES))
   {
   return YES;
   }
   else
   {
   return NO;
   }
   */
}
//提示没有通讯录权限
- (void)showAlertViewAboutNotAuthorAccessContact{
  
  UIAlertController *alertController = [UIAlertController
                                        alertControllerWithTitle:@"请授权通讯录权限"
                                        message:@"请在iPhone的\"设置-隐私-通讯录\"选项中,允许ydd访问你的通讯录"
                                        preferredStyle: UIAlertControllerStyleAlert];
  
  UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
  [alertController addAction:OKAction];
  [self presentViewController:alertController animated:YES completion:nil];
}

- (void)requestContactAuthorAfterSystemVersion9{
  
  CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
  if (status == CNAuthorizationStatusNotDetermined) {
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
      if (error) {
        NSLog(@"授权失败");
      }else {
        NSLog(@"成功授权");
        [self requestContactAuthor];
      }
    }];
  }
  else if(status == CNAuthorizationStatusRestricted)
  {
    NSLog(@"用户拒绝");
    [self showAlertViewAboutNotAuthorAccessContact];
  }
  else if (status == CNAuthorizationStatusDenied)
  {
    NSLog(@"用户拒绝");
    [self showAlertViewAboutNotAuthorAccessContact];
  }
  else if (status == CNAuthorizationStatusAuthorized)//已经授权
  {
    //有通讯录权限-- 进行下一步操作
    [self requestContactAuthor];

  }
}

- (void)requestContactAuthorAfterSystemVersion8
{
  ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
  //如果用户没决定过，请求授权
  if (status == kABAuthorizationStatusNotDetermined) {
    //创建通讯录
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    //请求授权
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
      if (granted) {//请求授权页面用户同意授权
        //读取通讯录人员数量,此处不可使用上面请求授权的通讯录对象,会崩溃
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_async(dispatch_get_main_queue(), ^{
          //xxx
          [self requestContactAuthor];
        });
        CFRelease(addressBook);
      }
      CFRelease(addressBookRef);
    });
  //如果是已授权状态
  } else if (status == kABAuthorizationStatusAuthorized) {
      //创建通讯录
      //读取通讯录人员数量
    [self requestContactAuthor];
  } else {

  }
}

- (void)requestContactAuthor
{
  if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
    // 1.获取授权状态
    // 3.创建通信录对象
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    // 4.获取所有的联系人
    CFArrayRef peopleArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex peopleCount = CFArrayGetCount(peopleArray);
    NSString* detailLabel = @"";
    
    NSMutableDictionary* mobilePhoneNumberDic =
    [[NSMutableDictionary alloc] init];
    // 5.遍历所有的联系人
    for (int i = 0; i < peopleCount; i++) {
      // 5.1.获取某一个联系人
      ABRecordRef person = CFArrayGetValueAtIndex(peopleArray, i);
      // 5.2.获取联系人的姓名
      NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(
                                                                          person, kABPersonLastNameProperty);
      NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(
                                                                           person, kABPersonFirstNameProperty);
      BOOL correctPhoneNum = YES;
      NSString* phoneNameStr = @"";
      if (lastName.length > 0) {
        phoneNameStr = [phoneNameStr stringByAppendingString:lastName];
      }
      if (firstName.length > 0) {
        phoneNameStr = [phoneNameStr stringByAppendingString:firstName];
      }
      if (phoneNameStr.length == 0) {
        correctPhoneNum = NO;
      }
      
      // 5.3.获取电话号码
      // 5.3.1.获取所有的电话号码
      ABMultiValueRef phones =
      ABRecordCopyValue(person, kABPersonPhoneProperty);
      CFIndex phoneCount = ABMultiValueGetCount(phones);
      
      // 5.3.2.遍历拿到每一个电话号码
      for (int i = 0; i < phoneCount; i++) {
        // 1.获取电话对应的key
        //                NSString *phoneLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phones, i);
        // 2.获取电话号码
        NSString* phoneValue =
        (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phones,
                                                                  i);
        phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@"-"
                                                           withString:@""];
        phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@" "
                                                           withString:@""];
        if ([phoneValue hasPrefix:@"+86"]) {
          phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@"+86"
                                                             withString:@""];
        }
        if ([self isMobile:phoneValue]) {
          [mobilePhoneNumberDic setObject:phoneNameStr forKey:phoneValue];
          if ([detailLabel rangeOfString:phoneValue].location == NSNotFound) {
            detailLabel = [detailLabel stringByAppendingString:phoneValue];
            detailLabel = [detailLabel stringByAppendingString:@"-"];
          }
        }
      }
      CFRelease(phones);
    }
    CFRelease(addressBook);
    CFRelease(peopleArray);

  } else {
    // 1.获取授权状态
    CNAuthorizationStatus status =
    [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    NSString __block* detailLabel = @"";
    
    // 2.判断授权状态,如果不是已经授权,则直接返回
    if (status != CNAuthorizationStatusAuthorized) return;
    
    // 3.创建通信录对象
    CNContactStore* contactStore = [[CNContactStore alloc] init];
    
    // 4.创建获取通信录的请求对象
    // 4.1.拿到所有打算获取的属性对应的key
    NSArray* keys = @[
                      CNContactNamePrefixKey, CNContactGivenNameKey, CNContactFamilyNameKey,
                      CNContactPhoneNumbersKey
                      ];
    
    // 4.2.创建CNContactFetchRequest对象
    CNContactFetchRequest* request =
    [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    
    NSMutableDictionary* mobilePhoneNumberDic =
    [[NSMutableDictionary alloc] init];
    // 5.遍历所有的联系人
    [contactStore
     enumerateContactsWithFetchRequest:request
     error:nil
     usingBlock:^(CNContact* _Nonnull contact,
                  BOOL* _Nonnull stop) {
       // 2.获取联系人的电话号码
       NSArray* phoneNums = contact.phoneNumbers;
       
       for (CNLabeledValue* labeledValue in
            phoneNums) {
         // 1.获取联系人的姓名
         NSString* lastName = contact.familyName;
         NSString* firstName = contact.givenName;
         //                personStruc.contactName = [NSString stringWithFormat:@"%@%@",lastName,firstName];
         BOOL correctPhoneNum = YES;
         NSString* phoneNameStr = @"";
         if (lastName.length > 0) {
           phoneNameStr = [phoneNameStr
                           stringByAppendingString:lastName];
         }
         if (firstName.length > 0) {
           phoneNameStr = [phoneNameStr
                           stringByAppendingString:firstName];
         }
         if (phoneNameStr.length == 0) {
           correctPhoneNum = NO;
         }
         
         // 2.获取电话号码
         CNPhoneNumber* phoneNumer =
         labeledValue.value;
         NSString* phoneValue =
         phoneNumer.stringValue;
         phoneValue = [phoneValue
                       stringByReplacingOccurrencesOfString:@"-"
                       withString:
                       @""];
         phoneValue = [phoneValue
                       stringByReplacingOccurrencesOfString:@" "
                       withString:
                       @""];
         if ([phoneValue hasPrefix:@"+86"]) {
           phoneValue = [phoneValue
                         stringByReplacingOccurrencesOfString:
                         @"+86"
                         withString:
                         @""];
         }
         if ([self
              isMobile:phoneValue]) {
           [mobilePhoneNumberDic
            setObject:phoneNameStr
            forKey:phoneValue];
           if (correctPhoneNum) {
           } else {
           }

           if ([detailLabel rangeOfString:phoneValue]
               .location == NSNotFound) {
             detailLabel = [detailLabel
                            stringByAppendingString:phoneValue];
             detailLabel = [detailLabel
                            stringByAppendingString:@"-"];
           }
         }
       }
     }];
  }
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
