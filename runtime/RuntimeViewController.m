//
//  RuntimeViewController.m
//  Yddworkspace
//
//  Created by ydd on 2018/8/14.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "RuntimeViewController.h"
#import <objc/runtime.h>
#import "NSObject+AddAttribute.h"
#import "RuntimeLibrary.h"
#import "UIButtonCount.h"
#import "MyCoderModel.h"
#import "NSObject+KeyValue.h"

/*
runtime 简称运行时，是系统在运行的时候的一些机制，其中最主要的是消息机制。它是一套比较底层的纯 C 语言 API, 属于一个 C 语言库，包含了很多底层的 C 语言 API。我们平时编写的 OC 代码，在程序运行过程时，其实最终都是转成了 runtime 的 C 语言代码。如下所示:
 // OC代码:
 [Person coding];
 //运行时 runtime 会将它转化成 C 语言的代码:
 objc_msgSend(Person, @selector(coding));
 
 ********************* 相关函数 *************************
 
 // 遍历某个类所有的成员变量
 class_copyIvarList
 
 // 遍历某个类所有的方法
 class_copyMethodList
 
 // 获取指定名称的成员变量
 class_getInstanceVariable
 
 // 获取成员变量名
 ivar_getName
 
 // 获取成员变量类型编码
 ivar_getTypeEncoding
 
 // 获取某个对象成员变量的值
 object_getIvar
 
 // 设置某个对象成员变量的值
 object_setIvar
 
 // 给对象发送消息
 objc_msgSend
 
*/

@interface Person : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) NSInteger age;

@end

@implementation Person

- (instancetype)init
{
  self = [super init];
  if (self) {
    _name = @"";
    _age = 0;
  }
  return self;
}

- (void)eatActive
{
  NSLog(@"person %@ is eat", self.name);
}

- (void)danceAction
{
  NSLog(@"person %@ is dance", self.name);
}


@end


@interface RuntimeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSMutableArray *dataArr;
@property(nonatomic, strong) Person *person;
@property(nonatomic, strong) RuntimeLibrary *library;
@property(nonatomic, strong) UIButtonCount *buttonCount;
@property(nonatomic, strong) NSMutableArray *modelArray;


@end

@implementation RuntimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.navigationController.navigationBar.translucent = NO;
  [self.view addSubview:self.tableView];

  _person = [[Person alloc] init];
  _person.name = @"魏英英";
  _person.age = 16;
  
  [self.tableView reloadData];
  
  [self createCoderData];
  [self createKeyValueModelData];
}

- (void)createKeyValueModelData
{
  self.modelArray = [NSMutableArray array];
  NSDictionary *library = @{@"project":@"******",
                           @"author": @"魏英英"};
  NSDictionary *dict = @{@"coderID":@"100",
                         @"nickName": @"以梦为马",
                         @"phoneNumber": @"110",
                         @"library" : library};
  NSArray *addarr = @[dict ,dict, dict];
  NSMutableDictionary *mudict = [NSMutableDictionary dictionaryWithDictionary:dict];
  [mudict setObject:library forKey:@"library"];
  
  for (NSDictionary *item in addarr) {
    MyCoderModel *coding = [MyCoderModel modelWithDict:item];
    [self.modelArray addObject:coding];
  }
  if (self.modelArray.count) {
    NSLog(@"字典转模型成功, 点击查看对应的值");
  }
}

- (void)createCoderData
{
  MyCoderModel *coding = [[MyCoderModel alloc] init];
  coding.coderID = @"100";
  coding.nickName = @"以梦为马";
  coding.phoneNumber = @"110";
  
  NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
  path = [path stringByAppendingPathComponent:@"123"];
  [NSKeyedArchiver archiveRootObject:coding toFile:path];
  NSLog(@"归档成功, 点击按钮取出模型中对应的值");
}

- (NSMutableArray *)dataArr
{
  if (!_dataArr) {
    _dataArr = [NSMutableArray arrayWithArray:@[@"更改属性值", @"动态添加属性", @"动态添加方法", @"交换方法实现", @"拦截并替换方法",@"在方法上增加额外功能", @"归档解档", @"字典转模型"]];
  }
  return _dataArr;
}

- (UIButtonCount *)buttonCount
{
  if (!_buttonCount) {
    _buttonCount = [UIButtonCount buttonWithType:UIButtonTypeSystem];
    [_buttonCount setTitle:@"点击次数0" forState:UIControlStateNormal];
    [_buttonCount addTarget:self action:@selector(buttonCountAction) forControlEvents:UIControlEventTouchUpInside];
    _buttonCount.count = 0;
  }
  return _buttonCount;
}

- (void)buttonCountAction
{
  [_buttonCount setTitle:[NSString stringWithFormat:@"点击次数%d", _buttonCount.count] forState:UIControlStateNormal];
}

- (UITableView *)tableView
{
  if (!_tableView) {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
  }
  return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  cell.textLabel.text = self.dataArr[indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.row) {
    case 0:
      [self changeObjectValue];
      break;
    case 1:
      [self addObjectAttribute];
      break;
    case 2:
      [self addMethod];
      break;
    case 3:
      [self exChangeMethod];
      break;
    case 4:
      [self interceptMethod];
      break;
    case 6:
      [self buttonClick];
      break;
    case 7:
      [self testKeyValueModel];
      break;
    default:
      break;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UITableViewHeaderFooterView *head = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
  head.textLabel.text = @"相关应用";
  
  if ([self.buttonCount superview]) {
    [self.buttonCount removeFromSuperview];
  }
  self.buttonCount.frame = CGRectMake(CGRectGetWidth(head.frame) - 100, 0, 80, CGRectGetHeight(head.frame));
  [head addSubview:self.buttonCount];
  
  return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 50;
}

// 改变对象属性的值
- (void)changeObjectValue
{
  unsigned int count = 0;
  Ivar *ivar = class_copyIvarList(_person.class, &count);
  for (int i = 0; i < count; i++) {
    Ivar tempIvar = ivar[i];
    const char *varChar = ivar_getName(tempIvar);
    NSString *varString = [NSString stringWithUTF8String:varChar];
    if ([varString isEqualToString:@"_name"]) {
      object_setIvar(_person, tempIvar, @"更改属性值成功");
      break;
                     
    }
  }
  NSLog(@"person name : %@", _person.name);
}

// 给类添加属性
- (void)addObjectAttribute
{
  NSObject *object = [[NSObject alloc] init];
  object.name = @"runtime";
  NSLog(@"add object attribute is name : %@", object.name);
}

// 动态添加方法
- (void)addMethod
{
  /*
   动态添加 coding 方法
   (IMP)codingOC 意思是 codingOC 的地址指针;
   "v@:" 意思是，v 代表无返回值 void，如果是 i 则代表 int；@代表 id sel; : 代表 SEL _cmd;
   “v@:@@” 意思是，两个参数的没有返回值。
   */
  class_addMethod([_person class], @selector(coding), (IMP)codingOC, "v@:");
  // 调用 coding方法响应事件
  if ([_person respondsToSelector:@selector(coding)]) {
    [_person performSelector:@selector(coding)];
    NSLog(@"添加方法成功");
  } else {
    NSLog(@"添加方法失败");
  }
}

void codingOC(id self, SEL _cmd) {
  NSLog(@"添加方法成功");
}

#pragma mark - 交换方法
- (void)exChangeMethod
{
  Method oriMethod = class_getInstanceMethod(_person.class, @selector(eatActive));
  Method curMethod = class_getInstanceMethod(_person.class, @selector(danceAction));
  method_exchangeImplementations(oriMethod, curMethod);
  
  [_person eatActive];
  NSLog(@"*********** exChangeMethod **************");
  [_person danceAction];
}

#pragma mark - 拦截替换方法
- (void)interceptMethod
{
  _person = [[Person alloc] init];
  _person.name = @"魏英英";
  _library = [[RuntimeLibrary alloc] init];
  _library.project = @"原来你还在这里";
  NSLog(@"library project : %@", [_library libraryMethod]);
  Method personMethod = class_getInstanceMethod(_person.class, @selector(eatActive));
  Method libararyMethod = class_getInstanceMethod(_library.class, @selector(libraryMethod));
  method_exchangeImplementations(personMethod, libararyMethod);
  
  NSLog(@"*********** interceptMethod **************");
  NSLog(@"library project : %@", [_library libraryMethod]);
}


- (void)buttonClick {
  static int count = 0;
  int tag = count % 3;
  count++;
  NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
  path = [path stringByAppendingPathComponent:@"123"];
  MyCoderModel *coding = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
  if (tag == 0) {
    NSLog(@"coderId : %@",coding.coderID);
  } else if (tag == 1) {
    NSLog(@"nickName : %@",coding.nickName);
  } else {
    NSLog(@"phoneNumber : %@",coding.phoneNumber);
  }
}

- (void)testKeyValueModel
{
  MyCoderModel *coding = self.modelArray.firstObject;
  static int modelcount = 0;
  modelcount %= 5;
  switch (modelcount) {
    case 0:
      NSLog(@"testKeyValueModel coderID : %@", coding.coderID);
      break;
    case 1:
      NSLog(@"testKeyValueModel nickName : %@", coding.nickName);
      break;
    case 2:
      NSLog(@"testKeyValueModel phoneNumber : %@", coding.phoneNumber);
      break;
    case 3:
       NSLog(@"testKeyValueModel library.project : %@", coding.library.project);
      break;
    case 4:
       NSLog(@"testKeyValueModel library.author : %@", coding.library.author);
      break;
    default:
      break;
  }
  modelcount++;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
