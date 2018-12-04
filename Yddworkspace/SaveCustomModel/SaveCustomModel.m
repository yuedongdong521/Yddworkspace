//
//  SaveCustomModel.m
//  Yddworkspace
//
//  Created by ydd on 2018/12/3.
//  Copyright © 2018 QH. All rights reserved.
//

#import "SaveCustomModel.h"
#import <objc/runtime.h>

#define KSaveCustomModelKey @"SaveCustomModelKey"

@interface SaveCustomModel ()<NSCoding>


@end

@implementation SaveCustomModel

+(SaveCustomModel *)createCustomModel
{
  id modelId = [[NSUserDefaults standardUserDefaults] objectForKey:KSaveCustomModelKey];
  if (modelId && [modelId isKindOfClass:[NSData class]]) {
    id model = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)modelId];
    if (model && [model isKindOfClass:[SaveCustomModel class]]) {
      return (SaveCustomModel *)model;
    }
  }
  return [[SaveCustomModel alloc] init];
}

- (void)saveCustomModel
{
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
  if (data) {
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:KSaveCustomModelKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _name = @"";
    _num = 0;
    _sex = 0;
  }
  return self;
}


+ (void)getAllMethodsFromClass:(id)object
{
  u_int count;
  // 获取类的所有方法列表
  Method *methodList = class_copyMethodList([object class], &count);
  for (int i = 0; i < count; i++) {
    Method temp_f = methodList[i];
    // 过去方法的 IMP 函数指针
    IMP imp_f = method_getImplementation(temp_f);
    // method_getName由Method得到SEL
    SEL name_f = method_getName(temp_f);
    const char *name_s = sel_getName(name_f);
    // method_getNumberOfArguments  由Method得到参数个数
    int arguments = method_getNumberOfArguments(temp_f);
    const char *encoding = method_getTypeEncoding(temp_f);
    
    NSLog(@" 方法名：%@，\n 参数个数：%d,\n 编码方式: %@\n", [NSString stringWithUTF8String:name_s], arguments, [NSString stringWithUTF8String:encoding]);
  }
  free(methodList);
}

+(NSArray *)getAllProperty:(id)object
{
  u_int count;
  objc_property_t *propertyList = class_copyPropertyList([object class], &count);
  NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    const char* propertyNameChar = property_getName(propertyList[i]);
    NSString *propertyName = [NSString stringWithUTF8String:propertyNameChar];
    [propertyArr addObject:propertyName];
  }
  free(propertyList);
  return propertyArr;
}

+ (void)goThroughAllProperty:(id)object propertyBlock:(void(^)(NSString *propertyName))propertyBlcok {
  u_int count;
  objc_property_t *propertyList = class_copyPropertyList([object class], &count);
  for (int i = 0; i < count; i++) {
    const char *propertyChar = property_getName(propertyList[i]);
    NSString *propertyName = [NSString stringWithUTF8String:propertyChar];
    if (propertyBlcok) {
      propertyBlcok(propertyName);
    }
  }
  free(propertyList);
}



#pragma mark NSCoding protocol
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//  [aCoder encodeObject:_name forKey:@"name"];
//  [aCoder encodeObject:@(_num) forKey:@"num"];
//  [aCoder encodeObject:@(_sex) forKey:@"sex"];
  
  /*
  u_int count;
  objc_property_t *propertyList = class_copyPropertyList([self class], &count);
  for (int i = 0; i < count; i++) {
    const char* propertyNameChar = property_getName(propertyList[i]);
    NSString *propertyName = [NSString stringWithUTF8String:propertyNameChar];
    //      [propertyArr addObject:propertyName];
    id value = [self valueForKey:propertyName];
    [aCoder encodeObject:value forKey:propertyName];
  }
  free(propertyList);
  */
  __weak typeof(self) weakself = self;
  [[self class] goThroughAllProperty:self propertyBlock:^(NSString *propertyName) {
    id value = [weakself valueForKey:propertyName];
    if (value) {
      [aCoder encodeObject:value forKey:propertyName];
    }
  }];
  
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
  self = [super init];
  if (self) {
//    _name = [aDecoder decodeObjectForKey:@"name"];
//    _num = [[aDecoder decodeObjectForKey:@"num"] intValue];
//    _sex = [[aDecoder decodeObjectForKey:@"sex"] intValue];
    /*
    u_int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
      const char* propertyNameChar = property_getName(propertyList[i]);
      NSString *propertyName = [NSString stringWithUTF8String:propertyNameChar];
//      [propertyArr addObject:propertyName];
      id value = [aDecoder decodeObjectForKey:propertyName];
      [self setValue:value forKey:propertyName];
    }
    free(propertyList);
     */
    __weak typeof(self) weakself = self;
    [[self class] goThroughAllProperty:self propertyBlock:^(NSString *propertyName) {
      id value = [aDecoder decodeObjectForKey:propertyName];
      [weakself setValue:value forKey:propertyName];
    }];
    
  }
  return self;
}





@end
