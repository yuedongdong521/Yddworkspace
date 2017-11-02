//
//  File.swift
//  Yddworkspace
//
//  Created by ispeak on 2016/12/7.
//  Copyright © 2016年 QH. All rights reserved.
//

import Foundation

/*
 如果Swift类想要被OC发现，必须继承自NSObject并且使用public标记，并且该类中想要被OC访问的方法也必须使用public标记，具体知识可以去看Swift的访问控制
 原因：Swift的代码对于OC来说是作为一个module存在的
 
 当然全局的Swift函数，我还没发现怎么在OC中访问，如果哪位清楚还请告诉一下，谢谢！
 */


public class MyModule : NSObject {
    
    //必须保证init方法的私有性，只有这样，才能保证单例是真正唯一的，避免外部对象通过访问init方法创建单例类的其他实例。由于Swift中的所有对象都是由公共的初始化方法创建的，我们需要重写自己的init方法，并设置其为私有的。这很简单，而且不会破坏到我们优雅的单行单例方法。
    static let mymodule = MyModule()
    private override init(){}
    
    
    
    class func shareMyModelLikeOC()->MyModule {
        struct Static {
           static let instance = MyModule()
        }
        return Static.instance
    }
   
    
   func getMyModuleType(tag:Int) -> String {
        switch tag {
        case 1:
            return "array"
        case 2:
            return "dic"
        case 3:
            return "string"
        default:
            return "number"
        }
    }
    
    func getCurrentTime() -> String {
        let date = NSDate()
        let time = date.timeIntervalSince1970
        let intTime = Int(time)
        return String(intTime)
    }
    
}
