//
//  DataModel.swift
//  Yddworkspace
//
//  Created by ydd on 2018/8/8.
//  Copyright © 2018年 QH. All rights reserved.
//

import Foundation

@objcMembers class DataModel: NSObject {
  
  override init() {
    
    
    
  }
  
 func dateString() {
    var str:String?
    let lastStr = "古来征战几人回."
    str = "醉卧沙场君莫笑,"
    str?.append(lastStr)
    print("append str " + str!)
    let subStr = str?[...lastStr.index(before: lastStr.endIndex)]
    let sub = String(describing: subStr)
    print("subStr : \(sub)")
  }
  
  
}
