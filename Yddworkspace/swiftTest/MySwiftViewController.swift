//
//  MySwiftViewController.swift
//  Yddworkspace
//
//  Created by ispeak on 2016/12/30.
//  Copyright © 2016年 QH. All rights reserved.
//

import Foundation

struct RequestInfo : Codable {
  let code : Int
  let msg : String
}


class MySwiftViewController : UIViewController
{
    let myView = UIView()
 
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        myView.frame = CGRect(x:20, y:100, width:200, height:200)
        myView.backgroundColor = UIColor.green
        myView.boom()
        
        self.view.addSubview(myView)
        
        let viewButton = UIButton(frame:CGRect(x:20, y:320, width:100, height:50))
        viewButton.setTitle("点击", for: UIControlState.normal)
        viewButton.backgroundColor = UIColor.yellow
        viewButton.addTarget(self, action: #selector(viewButtonClick), for: UIControlEvents.touchUpInside)
        self.view.addSubview(viewButton)
        
    }
    
    
  @objc  func viewButtonClick(){
//        myView.reset()
//        myView.animateWhenClicked()
    NetWorkRequest().getNetworkRequest(requestUrlStr: "http://test.m.v.ishow.cn/verify/token") { (data, urlResponse, error) in
      let decode = JSONDecoder.init()
      decode.dataDecodingStrategy = .deferredToData
      let dic = try! decode.decode(RequestInfo.self, from: data ?? Data.init())
      
      print(dic)
    }
    
    }
    
}
