//
//  ViewController.swift
//  YddAppClip
//
//  Created by ydd on 2020/9/23.
//  Copyright © 2020 QH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let label = UILabel.init(frame: CGRect(x: 20, y: 100, width: 100, height: 50))
        label.text = "hollo world !"
        self.view.addSubview(label)
        
        let btn = UIButton.init(type: .custom)
        btn.setTitle("点击", for: .normal)
        btn.setTitleColor(.green, for: .normal)
        btn.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        self.view.addSubview(btn)
        btn.frame = CGRect(x: 20, y: 200, width: 100, height: 50)
        
        let arr = ["a", "b", "c", "d"]
        
        for (x, y) in arr.enumerated() {
            print("测试函数 ：enumerated: \(x), \(y) ")
        }
        
        for m in arr.enumerated() {
            print("测试1： \(m.0) \(m.1)")
            print("测试2： \(m.offset) \(m.element)")
        }
        
        
    }
    
    @objc func clickAction(_ btn:UIButton) {
        let test = TestIOS14ViewController.init()
//        self.present(test, animated: true, completion: nil)
        self.navigationController?.pushViewController(test, animated: true)
    }


}

