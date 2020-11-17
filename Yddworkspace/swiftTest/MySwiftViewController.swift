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
        viewButton.setTitle("点击", for: UIControl.State.normal)
        viewButton.backgroundColor = UIColor.yellow
        viewButton.addTarget(self, action: #selector(viewButtonClick), for: UIControl.Event.touchUpInside)
        self.view.addSubview(viewButton)
        
        do {
            let data = try Data(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "bikaqiu", ofType: "gif") ?? ""))
            let gitView = UIImageView(frame: CGRect(x: 20, y: 400, width: 100, height: 100))
//            gitView.image = UIImage.init(data: data)
            gitView.gifData = data
            self.view.addSubview(gitView)
            gitView.startGIF()
            
            let gitView2 = UIImageView(frame: CGRect(x: 20, y: 510, width: 100, height: 100))
            let data2 = UIImage.scalGIFWithData(gitData: data, scalSize: CGSize(width: 100, height: 100))
            gitView2.gifData = data2
            self.view.addSubview(gitView2)
            gitView2.startGIF()
            
            
            print("data size \(data.count) , data2 size \((data2?.count ?? 0))")
            
        } catch {
            print("读取gif失败")
        }
        
        
        
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
