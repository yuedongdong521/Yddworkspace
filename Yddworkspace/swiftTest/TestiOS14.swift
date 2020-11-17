//
//  TestiOS14.swift
//  Yddworkspace
//
//  Created by ydd on 2020/9/23.
//  Copyright © 2020 QH. All rights reserved.
//

import Foundation
import UIKit

class TestIOS14ViewController : UIViewController {
    
    var timer:Timer? = nil
    
    lazy var pageControll :UIPageControl = {
        let controll = UIPageControl.init()
        controll.numberOfPages = 10;
        controll.pageIndicatorTintColor = .gray
        controll.currentPageIndicatorTintColor = .green
        controll.backgroundColor = .red
        if #available(iOS 14.0, *) {
            controll.backgroundStyle = .minimal
//            controll.all
        } else {
            // Fallback on earlier versions
        }
        return controll
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.pageControll.currentPage = 0
        testPageControll()
        
        testUI()
        
        testClick()
    }
    
    
    func testPageControll() {
        
        self.view.addSubview(self.pageControll)
        self.pageControll.frame = CGRect(x: 20, y: 100, width: 100, height: 50)
        if #available(iOS 10.0, *) {
            var count:Int = 0
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (t) in
                count += 1
                self.pageControll.currentPage = count % 3
            })
            
            if let timer = self.timer {
                RunLoop.init().add(timer, forMode: .common)
                timer.fire()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func testUI() {
        
        let label = UILabel.init(frame: CGRect(x: 20, y: 200, width: 100, height: 50))
        label.text = "hello world"
        label.font = UIFont.systemFont(ofSize: 14)
        self.view.addSubview(label)
        
        
    }
    
    func testClick() {
        let view = UIView.init(frame: CGRect(x: 20, y: 300, width: 100, height: 50))
        view.backgroundColor = .red
        self.view.addSubview(view)
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(jumpBtn)))
    }
    
    @objc func jumpBtn() {
        guard let url = URL.init(string: "ydd://") else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
        
    }
    
}
