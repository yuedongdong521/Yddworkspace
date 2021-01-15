//
//  RuntimeTestModel.m
//  Yddworkspace
//
//  Created by ydd on 2020/12/30.
//  Copyright © 2020 QH. All rights reserved.
//


/**
类型编码字符串形式的文档说明在这里:
https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html

|Code|Meaning|
|c|A char|
|i|An int|
|s|A short|
|l|A long，l is treated as a 32-bit quantity on 64-bit programs.|
|q|A long long|
|C|An unsigned char|
|I|An unsigned int|
|S|An unsigned short|
|L|An unsigned long|
|Q|An unsigned long long|
|f|A float|
|d|A double|
|B|A C++ bool or a C99 _Bool|
|v|A void|
|*|A character string (char *)|
|@|An object (whether statically typed or typed id)|
|#|A class object (Class)|
|:|A method selector (SEL)|
|[array type]|An array|
|{name=type...}|A structure|
|(name=type...)|A union|
|bnum|A bit field of num bits|
|^type|A pointer to type|
|?|An unknown type (among other things, this code is used for function pointers)|
|r|const|
|n|in|
|N|inout|
|o|out|
|O|bycopy|
|R|byref|
|V|oneway|

*/

/**
 
 消息传递（Messaging）
 在很多语言，比如 C ，调用一个方法其实就是跳到内存中的某一点并开始执行一段代码。没有任何动态的特性，因为这在编译时就已经确定了。而在 Objective-C 中，执行 [object foo] 语句并不会立即执行 foo 这个方法的代码。它是在运行时给 object 发送一条叫 foo 的消息。这个消息，也许会由 object 来处理，也许会被转发给另一个对象，或者不予理睬假装没收到这个消息。多条不同的消息也可以对应同一个方法实现。这些都是在程序运行的时候决定的。
 事实上，在编译时你写的 Objective-C 函数调用的语法都会被翻译成一个 C 的函数调用 - objc_msgSend()。比如，下面两行代码就是等价的：
 [object foo];

 objc_msgSend(object, @selector(foo));
 消息传递过程：
 首先，找到 object 的 class;
 通过 class 找到 foo 对应的方法实现;
 如果 class 中没到 foo，继续往它的 superclass 中找;
 一旦找到 foo 这个函数，就去执行它的实现.
 
 没有找到会抛出异常“ unrecognized selector sent to instance 0x600002a6d590'，”
 但在异常抛出前，Objective-C 的运行时会给你三次拯救程序的机会：
 Method resolution （方法解析）
 Fast forwarding （转发）
 Normal forwarding
 
 第一次 ： Method Resolution
 首先，Objective-C 运行时会调用 +resolveInstanceMethod: 或者 +resolveClassMethod:，让你有机会提供一个函数实现。如果你添加了函数并返回 YES， 那运行时系统就会重新启动一次消息发送的过程。
 
 
 */


#import "RuntimeTestModel.h"

/// 针对id类型属性getter的实现
void dynamicSetter(RuntimeTestModel *obj, SEL sel, id value) {
    objc_property_t prop = [[obj class] parseSelector:sel isGetter:NULL isSetter:NULL];
    NSString *propName = [NSString stringWithFormat:@"%s", property_getName(prop)];
    if (value) {
        obj.dictionary[propName] = value;
    } else {
        [obj.dictionary removeObjectForKey:propName];
    }
    
}

/// 针对id类型属性setter的实现
id dynamicGetter(RuntimeTestModel *obj, SEL sel) {
    objc_property_t prop = [[obj class] parseSelector:sel isGetter:NULL isSetter:NULL];
    NSString *propName = [NSString stringWithFormat:@"%s", property_getName(prop)];
    return obj.dictionary[propName];
}


@implementation RuntimeTestModel

/// 声明这两个属性的setter和getter是动态创建的,系统不会自动添加set/get方法，使用.调用会崩溃
@dynamic prop1, prop2;

// 判断是否是 setter 或 getter， 返回属性名
+ (objc_property_t)parseSelector:(SEL)selector isGetter:(BOOL *)isGetter isSetter:(BOOL *)isSetter
{
    NSString *selStr = NSStringFromSelector(selector);
    char propName[selStr.length + 1];
    memset(propName, 0, selStr.length + 1);
    
    if ([selStr hasPrefix:@"set"]) {
        strncpy(propName, selStr.UTF8String + 3, selStr.length - 4);
        propName[0] += ('a' - 'A');
        if (isSetter != NULL) {
            *isSetter = YES;
        }
    } else {
        strncpy(propName, selStr.UTF8String, selStr.length);
        if (isGetter != NULL) {
            *isGetter = YES;
        }
    }
    
    objc_property_t prop = class_getProperty([self class], propName);
    
    if (!prop) {
        if (isSetter != NULL) {
            *isSetter = NO;
        }
        if (isGetter != NULL) {
            *isGetter = NO;
        }
    }
    return prop;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    BOOL isGetter, isSetter;
    
    objc_property_t prop = [self parseSelector:sel isGetter:&isGetter isSetter:&isSetter];
    const char *typeEncoding = property_copyAttributeValue(prop, "T");
    
    if (typeEncoding != NULL) {
        if (typeEncoding[0] == '@') {
            // '@' 仅支持 OC 对象类型的属性，对于 int, float 和结构体等类型的属性，需要实现特别的 setter 和 getter
            
            if (isGetter) {
                class_addMethod([self class], sel, (IMP)dynamicGetter, "@@:");
                return YES;
            }
            if (isSetter) {
                class_addMethod([self class], sel, (IMP)dynamicSetter, "v@:@");
                return YES;
            }
            
        } else {
            // 这里可以添加一些setter和getter实现以支持int， float等基本类型的属性
        }
    }
    
    
    return NO;
    
    
}


- (NSMutableDictionary *)dictionary
{
    if (!_dictionary) {
        _dictionary = [NSMutableDictionary dictionary];
    }
    return _dictionary;
}


@end
