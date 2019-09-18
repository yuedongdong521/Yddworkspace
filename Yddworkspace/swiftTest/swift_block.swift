//
//  swift_block.swift
//  Yddworkspace
//
//  Created by ispeak on 2017/7/31.
//  Copyright © 2017年 QH. All rights reserved.
//

import Foundation
import AVFoundation

typealias TestAddBlock = (Int, Int)->Int

public class ClosureViewController : UIViewController {

  var swiftObj = SwiftClass2()
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        //闭包一般形式
//        {
//            (参数) -> 返回值类型 in
//            statements
//        }
        //1.一般形式
        let calAdd:(Int,Int)->(Int) = {
            (a:Int, b:Int) -> Int in
            return a + b
        }
        print("calAdd:\(calAdd(100, 150))")
        
        //2.推断参数类型、返回值类型
        let calAddTow:(Int, Int)->(Int) = {
            (a, b) in //也可以省略括号  a, b in
            return a + b
        }
        print("calAddTow: \(calAddTow(100, 150))")
        
        //3.单行表达式闭包（省略return）
        let calAddSecond:(Int, Int)->(Int) = {(a, b) in a + b}
        print("calAddSecond: \(calAddSecond(100, 150))")
        
        //4.如果闭包没有参数，可以直接省略in
        let calAddThird:()->(Int) = {return 100 + 150}
        print("calAddThird:\(calAddThird())")

        //5.没有返回值
        let calAddFour:(Int, Int) ->Void = {
            (a, b) in
            print("calAddFour \(a + b)")
        }
        calAddFour(100, 150)
       /*
        归纳
        闭包类型是由参数类型和返回值类型决定，和函数是一样的。比如上面前三种写法的闭包的闭包类型就是(Int,Int)->(Int),后面的类型分别是()->Int和()->Void。分析下上面的代码：let calAdd：(add类型)。这里的add类型就是闭包类型 (Int,Int)->(Int)。意思就是声明一个calAdd常量，其类型是个闭包类型。
        "="右边是一个代码块，即闭包的具体实现，相当于给左边的add常量赋值。兄弟们，是不是感觉很熟悉了，有点像OC中的block代码块。
        */
        
        //使用typealias重命名
        let addBlock :TestAddBlock = {
            (a, b) in
            return a + b
        }
        print("typealias \(addBlock(100, 150))")
        
        /*
        逃逸闭包
        当一个闭包作为参数传到一个函数中，需要这个闭包在函数返回之后才被执行，我们就称该闭包从函数种逃逸。一般如果闭包在函数体内涉及到异步操作，但函数却是很快就会执行完毕并返回的，闭包必须要逃逸掉，以便异步操作的回调。
        逃逸闭包一般用于异步函数的回调，比如网络请求成功的回调和失败的回调。语法：在函数的闭包行参前加关键字“@escaping”。
        */
        
        //栗子
        doSomething { (a, b) in
            print("逃逸闭包测试： \(a + b)")
        }
        
        
        view.backgroundColor = UIColor.white
        let button = UIButton.init(type: UIButtonType.system)
        button.frame = CGRect(x:20, y:100, width:50, height:40)
        button.setTitle("闭包测试", for: UIControlState.normal)
        button.backgroundColor = UIColor.blue
        button.addTarget(self, action: #selector(ajaxToolTow), for: UIControlEvents.touchUpInside)
        view.addSubview(button)
      
      view.addSubview(testButton!);
      
      var className:String = "类名为:"
      testBlockClassName { (name) in
        className.append(name)
        print(className)
      }
//      requestAVAuthority();

      self.swiftObj.testBlock()
        
    }
  
  fileprivate lazy var testButton:UIButton? = {
    let button = UIButton.init(type: UIButtonType.system);
    button.frame = CGRect(x:20, y:200, width:60, height:40)
    button.setTitle("textButton", for: UIControlState.normal)
    button.backgroundColor = UIColor.red;
    button.setTitleColor(UIColor.white, for: UIControlState.normal)
    button.addTarget(self, action: #selector(testButtonAction), for: UIControlEvents.touchUpInside)
    return button;
  }()
  
  @objc fileprivate func testButtonAction(button: UIButton)-> Void {
    let tmp:UIButton = button
    if tmp.backgroundColor == UIColor.cyan {
      print("testButtonAction ture ");
      tmp.backgroundColor = UIColor.red
    } else {
      print("testButtonAction false ");
      button.backgroundColor = UIColor.cyan
    }
  
  }
    
    func doSomething(some:@escaping (Int, Int) -> Void){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { 
            some(100, 150)
        }
    }
    
    
    func ajaxTools(name:String ,complated:(_ runStr: String,_ isStop:Bool) -> String) -> String {
       
        let resStr = name + "覆水难收"
         print(resStr + "1")
        let complatedStr = complated(resStr, true)
        
        return resStr + " - 内部函数返回" + complatedStr
    }
    
    @objc func ajaxToolTow() {
        let ajax = ajaxTools(name: "肖友") { (runStr:String, isStop:Bool) -> String in
            print(runStr + String(isStop) + "2")
            return runStr + String(isStop)
        }
        
        print(ajax + "3")
    }
  
  

}

fileprivate extension ClosureViewController {
  func testBlockClassName(blockClassName:@escaping(String)-> Void) -> Void {
    let nameCoder:String = NSStringFromClass(self.classForCoder)
    
    let name:String = NSStringFromClass(self.classForKeyedArchiver!)
    print("classForKeyedArchiver: " + name)
    blockClassName(nameCoder);
  }

  func requestAVAuthority(blockAuthor:@escaping(Bool)-> Void) {
    let statue:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    print("摄像头权限 statue: " + String(statue.rawValue))
    switch statue {
    case AVAuthorizationStatus.notDetermined:
//      AVCaptureDevice re
      break
    case AVAuthorizationStatus.restricted:
      blockAuthor(false);
      break
    case AVAuthorizationStatus.denied:
      blockAuthor(true);
      break
    default:

      break
    }
  }
  
}


class SwiftClass {
    typealias BlockType = (String)->Void
    
    lazy var blockList:Array<BlockType> = {
        let arr = Array<BlockType>()
        return arr
    }()
    
    func function1(str: String, block: @escaping (_ a:String)->Void) {
        self.blockList.append(block)
        self.function2(str: str)
    }
    
    func function2(str: String) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: 1)) {
            if self.blockList.count == 0 {
                return
            }
            let block = self.blockList.first
            if block == nil {
                return
            }
            block?(str)
            var tmpArr = Array<BlockType>.init()
            for a in 0..<self.blockList.count {
                if a != 0 {
                    tmpArr.append(self.blockList[a])
                }
            }
            self.blockList = tmpArr
        }
    }
    
    func function3(str: String, block:(_ a:String)->Void) {
        block(str)
    }
    
    func printAction(name:String) {
        print("my name is " + name)
    }
    
    deinit {
        print("SwiftClass 释放")
    }
}

class SwiftClass2 {
    
    lazy var obj: SwiftClass = {
        let sw = SwiftClass.init()
        return sw
    }()
    
    func testBlock() {
        
        // 逃逸闭包使用weak 修饰避免循环引用
        self.obj.function1(str: "ydd") { [weak self] (name) in
            let str1 = name + " 1"
            self?.printAction(name: str1)
        }
        // 非逃逸闭包不需要weak修饰
        self.obj.function3(str: "ydd") { (name) in
            let str1 = name + " 2"
            self.printAction(name: str1)
        }
        
        self.obj.function3(str: "ydd") { (name) in
            let str1 = name + " 3"
            self.obj.printAction(name: str1)
        }
        
        self.obj.function1(str: "ydd") { [weak self] (n) in
            let str1 = n + " 4"
            self?.obj.printAction(name: str1)
        }
    }
    
    func printAction(name:String) {
        print("my name is " + name)
    }
    
    deinit {
        print("SwiftClass2 释放")
    }
    
}

typealias Callback = (Any...)->Void
class Command {
    init(_ fn: @escaping Callback) {
        self.fn_ = fn
    }
    
    var exec : (_ args: Any...)->Void {
        get {
            return fn_
        }
    }
    var fn_ :Callback
}


