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
        
        let p = touches.first?.location(in: self.view) ?? CGPoint.zero
//        self.showMuteView(p)
//        self.showLabel(p)
        self.showCenterMuteView(p)
        
     
    }
    
    
    func showMuteView(_ p: CGPoint) {
        let muteView = UIView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        self.view.addSubview(muteView)
        muteView.showView(TopPoint: p, IsLeft: p.x < self.view.center.x, Space: 10, Radius: 20, Animation: true) { (finished) in
            print("mute \(finished)")
            muteView.removeFromSuperview()
        }
    }
    
    func showLabel(_ p : CGPoint) {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "菜单"
        label.textAlignment = .center
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.view.addSubview(label)
        label.showView(TopPoint: p, IsLeft: p.x < self.view.center.x, Space: 10, Radius: 5, Animation: true) { (finished) in
            label.removeFromSuperview()
        }
    }
    
    func showCenterMuteView(_ p : CGPoint) {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "菜单"
        label.textAlignment = .center
        label.sizeToFit()
        label.frame = CGRect(x: p.x, y: p.y, width: 40, height: 40)
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.blue.cgColor
        label.layer.borderWidth = 1
        self.view.addSubview(label)
        
        label.showCenterView { (finish) in
        
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                label.dismissCenter { (finished) in
                    
                }
            }
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
