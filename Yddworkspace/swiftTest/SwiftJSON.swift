//
//  SwiftJSON.swift
//  Yddworkspace
//
//  Created by ydd on 2018/10/31.
//  Copyright © 2018 QH. All rights reserved.
//

import Foundation

struct Person : Codable {
  let name : String?
  let sex : String?
  let job : String?
  let number : Int?
}

struct PersionList : Codable {
  let persionList : [Person]
}



class SwiftJSONViewController: UIViewController {
  
  lazy var label : UILabel = {
    let label = UILabel.init(frame: CGRect(x: 20, y: 80, width: self.view.bounds.size.width, height: 400))
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .center
    label.backgroundColor = UIColor.gray
    return label
  }()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    
    self.view.addSubview(self.label)
    var y = self.label.frame.origin.y + self.label.frame.size.height
    y += 20
    var x = 20
    let btnW = 60
    let btnH = 40
    
    let btn1 = createButton(btnFrame: CGRect(x: 20, y: Int(y), width: btnW, height: btnH), btnTitle: "简单格式", btnTag: 1001)
    self.view.addSubview(btn1)
    
    x += btnW + 20
    let btn2 = createButton(btnFrame: CGRect(x: x, y: Int(y), width: btnW, height: btnH), btnTitle: "正常", btnTag: 1002)
    self.view.addSubview(btn2)
    
    
  }
  
  func createButton(btnFrame frame:CGRect, btnTitle title:String, btnTag tag:Int) -> UIButton {
    let btn = UIButton.init(type: .system)
    btn.frame = frame;
    btn.setTitle(title, for: .normal)
    btn.tag = tag
    btn.addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside)
    return btn
  }
  
  @objc func buttonAction(btn:UIButton) {
    switch btn.tag {
    case 1001:
      eazyJSON()
      break
    case 1002:
      normalJSON()
      break
    default:
      break
    }
  }
  
  func eazyJSON() {
    
    let jsonStr = ["name":"ydd", "sex":"男", "job":"Programmer", "number":927] as [String : Any]
    let arr = [1,2,3]
    let data = try! JSONSerialization.data(withJSONObject: jsonStr, options: .prettyPrinted)
    
    do {
       let dic = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
      print(dic)
    } catch  {
      print("解析失败")
    }
   
    
    let decode = JSONDecoder.init()
    decode.dataDecodingStrategy = .deferredToData
    
    
    do {
      let personInfo = try decode.decode(Person.self, from: data ?? Data.init())
      
      print("eazyJSON 解析成功" + personInfo.name!)
      
    } catch {
      print("eazyJSON 解析失败")
    }
//
//    let listStr = "[" + jsonStr + "]"
//    let listData = listStr.data(using: .utf8)
//
//    do {
//      let persinList =  try decode.decode([Person].self, from: listData ?? Data.init())
//      let person = persinList.first
//      if (person?.name != nil) {
//         print("persionList 解析成功" + person!.name!)
//      }
//    } catch  {
//      print("personList 解析失败");
//    }
    
  }
  
  func normalJSON() {
   
    
    
  }
  
  
  
}






