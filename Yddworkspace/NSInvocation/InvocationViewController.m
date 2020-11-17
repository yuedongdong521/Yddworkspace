//
//  InvocationViewController.m
//  Yddworkspace
//
//  Created by ydd on 2020/9/28.
//  Copyright © 2020 QH. All rights reserved.
//

#import "InvocationViewController.h"

@interface InvocationViewController ()

@end

@implementation InvocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    
    [self invocation];
    
    NSLog(@"多参数函数： %@", [self addMoreArguments:@"hello", @"world", @"this", @"is", @"a", @"test", nil]);
    
}

- (void)invocation
{
    //NSInvocation;用来包装方法和对应的对象，它可以存储方法的名称，对应的对象，对应的参数,
    /*
     NSMethodSignature：签名：再创建NSMethodSignature的时候，必须传递一个签名对象，签名对象的作用：用于获取参数的个数和方法的返回值
     */
    //创建签名对象的时候不是使用NSMethodSignature这个类创建，而是方法属于谁就用谁来创建
    NSMethodSignature*signature = [InvocationViewController instanceMethodSignatureForSelector:@selector(sendMessageWithNumber:WithContent:)];
    //1、创建NSInvocation对象
    NSInvocation*invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    //invocation中的方法必须和签名中的方法一致。
    invocation.selector = @selector(sendMessageWithNumber:WithContent:);
    /*第一个参数：需要给指定方法传递的值
     第一个参数需要接收一个指针，也就是传递值的时候需要传递地址*/
    //第二个参数：需要给指定方法的第几个参数传值
    NSString*number = @"1111";
    //注意：设置参数的索引时不能从0开始，因为0已经被self占用，1已经被_cmd占用
    [invocation setArgument:&number atIndex:2];
    NSString*number2 = @"啊啊啊";
    [invocation setArgument:&number2 atIndex:3];
    //2、调用NSInvocation对象的invoke方法
    //只要调用invocation的invoke方法，就代表需要执行NSInvocation对象中制定对象的指定方法，并且传递指定的参数
    [invocation invoke];
}

- (void)sendMessageWithNumber:(NSInteger)number WithContent:(NSString *)content
{
    NSLog(@"number : %ld, content : %@", (long)number, content);
}


- (void)createUI
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(100, 50));
        make.top.mas_equalTo(80);
    }];
    
}

- (void)btnAction:(UIButton *)btn
{
    static BOOL isInvacation = NO;
    isInvacation = !isInvacation;
    
    NSInteger count = 1;
    NSString *name = @"测试数 :";
    
    if (isInvacation) {
        name = @"Invacation";
        count = 2;
        
        
        
//        NSMethodSignature *signature = [InvocationViewController methodSignatureForSelector:@selector(clickCount:name:)];
//        NSInvocation *invacation = [NSInvocation invocationWithMethodSignature:signature];
//        invacation.target = [InvocationViewController class];
//        invacation.selector = @selector(clickCount:name:);
//
//        [invacation setArgument:&count atIndex:2];
//        [invacation setArgument:&name atIndex:3];
//
//        [invacation invoke];
        
        [[self class] changeOverClass:self.class selector:@selector(classClickCount:name:) parameter:@[@(count), name]];
        
    } else {
//        [InvocationViewController clickCount:count name:name];
        [self changeOverObjectSelector:@selector(clickCount:name:) parameter:@[@(count), name]];
    }
    
}

+ (void)changeOverClass:(Class)class selector:(SEL)selector parameter:(NSArray *)parmeter
{
    NSMethodSignature *signature = [class methodSignatureForSelector:selector];
    NSInvocation *invacation = [NSInvocation invocationWithMethodSignature:signature];
    invacation.target = [class class];
    invacation.selector = selector;
   
    [parmeter enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id parme = obj;
        [invacation setArgument:&parme atIndex:2 + idx];
    }];

    [invacation invoke];
}

- (void)changeOverObjectSelector:(SEL)selector parameter:(NSArray *)parmeter
{
    
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invacation = [NSInvocation invocationWithMethodSignature:signature];
    invacation.target = self;
    invacation.selector = selector;
   
    [parmeter enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id parme = obj;
        [invacation setArgument:&parme atIndex:2 + idx];
    }];

    [invacation invoke];
}



+ (void)classClickCount:(NSInteger)count name:(NSString *)name
{
    NSLog(@"%@ ： %@", name, @(count));
}

- (void)clickCount:(NSInteger)count name:(NSString *)name
{
    NSLog(@"%@ ： %@", name, @(count));
}

- (NSString *)appendObjects:(id)firstObjects, ...NS_REQUIRES_NIL_TERMINATION
{
//    va_list args;
//    va_start(args, firstObjects);
//    NSMutableString *allStr = [NSMutableString string];
//    for (NSString *str = firstObjects; str != nil; str = va_arg(args, NSString *)) {
//        [allStr appendFormat:@"* %@", str];
//    }
//    va_end(args);
//    return allStr;
    
    NSMutableArray *arr = [NSMutableArray array];
    id enchObject;
    va_list argumentList;
    if (firstObjects) {
        [arr addObject:firstObjects];
        va_start(argumentList, firstObjects);
        while ((enchObject = va_arg(argumentList, id))) {
            [arr addObject:enchObject];
            va_end(argumentList);
        }
    }
    
    return [NSString stringWithFormat:@"%@", arr];
}

- (NSString *)addMoreArguments:(NSString *)firstStr,...
{
     va_list args;
     va_start(args, firstStr); // scan for arguments after firstObject.

    NSLog(@"args first: %@", firstStr);
    
     // get rest of the objects until nil is found
     NSMutableString *allStr = [[NSMutableString alloc] initWithCapacity:16];
     for (NSString *str = firstStr; str != nil; str = va_arg(args,NSString*)) {
         [allStr appendFormat:@"* %@ ",str];
     }

     va_end(args);
     return allStr;
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
