//
//  MyLabelViewController.swift
//  Yddworkspace
//
//  Created by ispeak on 2017/1/5.
//  Copyright © 2017年 QH. All rights reserved.
//

import Foundation

class MyLabelViewController: UIViewController {
    
    
    override func viewDidLoad() {
        
        let myLabel = UILabel.init(frame: CGRect(x:20, y:100, width:100, height:30))
        myLabel.font = UIFont.systemFont(ofSize: 20)
        myLabel.textColor = UIColor.blue
        myLabel.backgroundColor = UIColor.green
        myLabel.textAlignment = NSTextAlignment.left
        myLabel.text = "123456"
        myLabel.tag = 1000
        self.view.addSubview(myLabel)
        
        let myButton = UIButton.init(frame: CGRect(x:20, y:200, width:100, height:30))
        myButton.backgroundColor = UIColor.red
        myButton.setTitle("myButton", for: UIControl.State.normal)
        myButton.setTitleColor(UIColor.green, for: UIControl.State.normal)
        myButton.addTarget(self, action: #selector(buttonClick(button:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(myButton)
        
    }
    
  @objc func buttonClick(button:UIButton) {
        let myLabel:UILabel = self.view.viewWithTag(1000) as! UILabel
        myLabel.text = "dhakdjslaydoqskdksh大手大脚阿里的深刻的hi请多喝水，打快点回收款打款单不上课都十点半"
        myLabel.numberOfLines = 0
        //字体自适应label大小
//        myLabel.adjustsFontSizeToFitWidth = true
    //
        if #available(iOS 10.0, *) {
            myLabel.adjustsFontForContentSizeCategory = true
        } else {
            // Fallback on earlier versions
        }
        
        let labelSize = self.getLabelSize(labelStr: myLabel.text!, font: UIFont.systemFont(ofSize: 20), maxSize: CGSize(width:100, height:1000))
        myLabel.frame = CGRect(x:myLabel.frame.origin.x, y:myLabel.frame.origin.y, width:labelSize.width, height:labelSize.height)
        
    }
    
    
    func getLabelSize(labelStr:String, font:UIFont, maxSize:CGSize) -> CGSize {
        let tmpstr :NSString = labelStr as NSString
      let dic = NSDictionary.init(object: font, forKey: kCTFontAttributeName as! NSCopying)
        let returnSize = tmpstr.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context: nil).size
        return returnSize
        
    }
    
    
    
}
