//
//  MyURLTools.m
//  iShow
//
//  Created by ydd on 2018/8/29.
//

#import "MyURLTools.h"
#import "TFHpple.h"

typedef BOOL (^FilterBlock)(NSString*);

@implementation MyURLTools

+ (NSData*)getHtmlDataWithUrlString:(NSString*)urlString {
  if ([urlString containsString:@"ispeak.cn"]) {
    NSString* newAgent =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"];
    NSMutableURLRequest* request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setValue:newAgent forHTTPHeaderField:@"User-Agent"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:nil
                                                     error:nil];
    NSString* returnData =
        [[NSString alloc] initWithBytes:[data bytes]
                                 length:[data length]
                               encoding:NSUTF8StringEncoding];
    return [returnData dataUsingEncoding:NSUTF8StringEncoding];
  }
  NSString* utfString =
      [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString]
                               encoding:NSUTF8StringEncoding
                                  error:nil];
  if (utfString) {
    return [utfString dataUsingEncoding:NSUTF8StringEncoding];
  }
  NSString* htmlString = [NSString
      stringWithContentsOfURL:[NSURL URLWithString:urlString]
                     encoding:CFStringConvertEncodingToNSStringEncoding(
                                  kCFStringEncodingGB_18030_2000)
                        error:nil];
  if (htmlString) {
    NSString* newHTML =
        [htmlString stringByReplacingOccurrencesOfString:@"gb2312"
                                              withString:@"utf-8"];
    return [newHTML dataUsingEncoding:NSUTF8StringEncoding];
  }
  return [[NSData alloc] init];
}

+ (void)getUrlInfomationWithUrlString:(NSString*)urlString
                           completion:
                               (ISURLInfomationHandler)completionHandler {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
                   NSData* htmlData = [self getHtmlDataWithUrlString:urlString];
                   [self getUrlInfomationWithHtmlData:htmlData
                                           completion:completionHandler];
                 });
}

+ (void)getUrlInfomationSyncWithUrlString:(NSString*)urlString
                               completion:(ISURLShareInfomationHandler)
                                              completionHandler {
  NSData* htmlData = [self getHtmlDataWithUrlString:urlString];
  TFHpple* hppleParser = [[TFHpple alloc] initWithHTMLData:htmlData];

  NSString* iconImageStr = [self getImageUrlStringWithHpple:hppleParser];
  NSString* desc =
      [self getContentStringWithHpple:hppleParser
                 searchWithXpathQuery:@"//meta[@name='description']"
                               filter:nil];
  completionHandler(iconImageStr, desc);
}

+ (void)getUrlInfomationWithHtmlData:(NSData*)htmlData
                          completion:(ISURLInfomationHandler)completionHandler {
  TFHpple* hppleParser = [[TFHpple alloc] initWithHTMLData:htmlData];

  NSString* iconImageStr = [self getImageUrlStringWithHpple:hppleParser];
  NSString* contentStr =
      [self getContentStringWithHpple:hppleParser
                 searchWithXpathQuery:@"//meta[@name='description']"
                               filter:nil];

  NSString* titleStr = [self getTextWithHpple:hppleParser
                         searchWithXpathQuery:@"//title"
                                       filter:nil];

  dispatch_async(dispatch_get_main_queue(), ^{
    completionHandler(titleStr, contentStr, iconImageStr);
  });
}

+ (BOOL)isWebsiteURLStrWithString:(NSString*)string {
  NSError* error;
  NSString* regulaStr =
      @"((http[s]{0,1}|ftp)://"
      @"((\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|"
      @"25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2["
      @"0-4]\\d|25[0-5])|[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4}))(:\\d+)?(/"
      @"[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/"
      @"=<>]*)?)|(www.((\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|"
      @"1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])\\.("
      @"\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])|[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,"
      @"4}))(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
  NSRegularExpression* regex = [NSRegularExpression
      regularExpressionWithPattern:regulaStr
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];
  NSRange stringRange = NSMakeRange(0, [string length]);
  NSArray* arrayOfAllMatches =
      [regex matchesInString:string options:0 range:stringRange];
  if ([arrayOfAllMatches count] > 0) {
    NSTextCheckingResult* match = [arrayOfAllMatches objectAtIndex:0];
    if (match.range.location == 0 && match.range.length == [string length]) {
      return YES;
    }
  }
  return NO;
}



#pragma mark - private -
+ (NSString*)getImageUrlStringWithHpple:(TFHpple*)hppleParser {
  NSString* iconImageStr =
      [self getTextWithHpple:hppleParser
          searchWithXpathQuery:@"//link/@href"
                        filter:^BOOL(NSString* text) {
                          return [self isImageUrlWithElementText:text];
                        }];

  if (iconImageStr.length == 0) {
    iconImageStr = [self
        getContentStringWithHpple:hppleParser
             searchWithXpathQuery:@"//meta[@itemprop='image']"
                           filter:^BOOL(NSString* content) {
                             return [self isImageUrlWithElementText:content];
                           }];
  }
  if (iconImageStr.length == 0) {
    iconImageStr =
        [self getTextWithHpple:hppleParser
            searchWithXpathQuery:@"//img/@data-src"
                          filter:^BOOL(NSString* text) {
                            return [self isImageUrlWithElementText:text];
                          }];
  }
  if (iconImageStr.length == 0) {
    iconImageStr =
        [self getTextWithHpple:hppleParser
            searchWithXpathQuery:@"//img/@src"
                          filter:^BOOL(NSString* text) {
                            return [self isImageUrlWithElementText:text];
                          }];
  }
  if (iconImageStr.length == 0) {
    iconImageStr = [self getContentStringWithHpple:hppleParser
                              searchWithXpathQuery:@"//meta[@itemprop='image']"
                                            filter:nil];
    if ([iconImageStr hasPrefix:@"//"]) {
      iconImageStr = [NSString stringWithFormat:@"http:%@", iconImageStr];
    } else if ([iconImageStr hasPrefix:@"http://"] ||
               [iconImageStr hasPrefix:@"https://"]) {
      iconImageStr = iconImageStr;
    } else if (iconImageStr.length > 0) {
      iconImageStr = [NSString stringWithFormat:@"http://%@", iconImageStr];
    }
  }
  return iconImageStr;
}

+ (NSString*)getContentStringWithHpple:(TFHpple*)hppleParser
                  searchWithXpathQuery:(NSString*)xPathOrCSS
                                filter:(FilterBlock)filterBlock {
  NSArray* contentElements = [hppleParser searchWithXPathQuery:xPathOrCSS];
  for (TFHppleElement* element in contentElements) {
    NSString* content = [element objectForKey:@"content"];
    if ([content isKindOfClass:[NSString class]] && content.length > 0 &&
        (!filterBlock || filterBlock(element.text))) {
      return content;
      break;
    }
  }
  return @"";
}

+ (NSString*)getTextWithHpple:(TFHpple*)hppleParser
         searchWithXpathQuery:(NSString*)xPathOrCSS
                       filter:(FilterBlock)filterBlock {
  NSArray* elements = [hppleParser searchWithXPathQuery:xPathOrCSS];
  for (TFHppleElement* element in elements) {
    if ([element.text isKindOfClass:[NSString class]] &&
        element.text.length > 0 &&
        (!filterBlock || filterBlock(element.text))) {
      return element.text;
      break;
    }
  }
  return @"";
}

+ (BOOL)isImageUrlWithElementText:(NSString*)elementText {
  if (([elementText hasPrefix:@"http://"] ||
       [elementText hasPrefix:@"https://"]) &&
      ([elementText hasSuffix:@"png"] || [elementText hasSuffix:@"jpg"] ||
       [elementText hasSuffix:@"jpeg"] || [elementText hasSuffix:@"ico"] ||
       [elementText hasSuffix:@"res"] || [elementText hasSuffix:@"resnw"])) {
    return YES;
  }
  return NO;
}

@end
