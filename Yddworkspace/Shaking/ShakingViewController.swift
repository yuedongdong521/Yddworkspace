//
//  ShakingViewController.swift
//  Yddworkspace
//
//  Created by ydd on 2020/9/28.
//  Copyright © 2020 QH. All rights reserved.
//

import Foundation


class ShakingImageView: UIImageView {
    
    private var displayLink : CADisplayLink?
    private var count : Int = 0
    private var startDate = Date()
    
    private let loop : Int = 12
    
    var num : Int = 1
    var duration : Double = 3.0
    
    func startAnimation() {
        cancelDisplayLink()
        startDate = Date()
        count = count % loop
        displayLink = CADisplayLink.init(target: self, selector: #selector(displayAction))
        displayLink?.frameInterval = 4
        displayLink?.add(to: RunLoop.current, forMode: .common)
    }
    
    func stopAnimation() {
        cancelDisplayLink()
    }
    
    private func cancelDisplayLink() {
        if displayLink != nil {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    @objc private func displayAction() {
        
        count += 1
        let index = count % loop + 1
        let time = Date().timeIntervalSince(startDate)
        if time > duration {
            if 2 * num - 1 == index {
                cancelDisplayLink()
                self.image = UIImage(named: "shaking\(index)")
                return
            }
        }
        self.image = UIImage(named: "shaking\(index)")
    }
}


class ShakingVC: UIViewController {
    
    lazy var imageView:ShakingImageView = {
        let imageView = ShakingImageView()
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
       
        self.view.addSubview(imageView)
        
        imageView.mas_makeConstraints { (make) in
            make?.size.mas_equalTo()(CGSize(width: 60, height: 60))
            make?.center.equalTo()(self.view)
        }
        
        imageView.image = UIImage(named: "shaking1")
        
        
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(UIImage(named: "ShakePoint"), for: .normal)
        btn.addTarget(self, action: #selector(clicked), for: .touchUpInside)
        self.view.addSubview(btn)
        
        btn.mas_makeConstraints { (make) in
            make?.width.mas_equalTo()(60)
            make?.height.mas_equalTo()(60)
            make?.bottom.mas_equalTo()(-100)
            make?.centerX.mas_equalTo()(self.view.mas_centerX)
        }
        
        
    }
    
    @objc private func clicked() {
        imageView.num = Int(arc4random() % 6 + 1)
        imageView.startAnimation()
    }
    
}
