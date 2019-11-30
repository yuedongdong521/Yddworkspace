//
//  ExtensionViewController.swift
//  Yddworkspace
//
//  Created by ydd on 2019/10/15.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class ExtensionViewController: UIViewController {

    lazy var muteView: UIView = {
        let view = UIView.init()
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 300)
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        
        
        
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.muteView.removeFromSuperview()
        
        
        let p = touches.first?.location(in: self.view) ?? CGPoint.zero
  
        self.view.addSubview(self.muteView)
        self.muteView.showView(TopPoint: p, IsLeft: p.x < self.view.center.x, Space: 10, Radius: 20, Animation: true) { (finished) in
            print("mute \(finished)")
        }
    }
    
    deinit {
        print("deinit ExtensionViewController")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
