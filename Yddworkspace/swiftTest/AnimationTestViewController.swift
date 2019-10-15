//
//  AnimationTestViewController.swift
//  Yddworkspace
//
//  Created by ydd on 2019/10/10.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class AnimationTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        // Do any additional setup after loading the view.
        
        for i in 0..<4 {
            var widget:AnimationWidget
            
            if i == 0 {
                widget = AnimationWidget.init(frame: CGRect(x: 20, y: 100, width: 40, height: 40))
            } else if i == 1 {
                widget = AnimationWidget.init(frame: CGRect(x:self.view.frame.size.width - 20 - 40, y: 100, width: 40, height: 40))
            } else if i == 2 {
                widget = AnimationWidget.init(frame: CGRect(x: 20, y: self.view.frame.size.height - 140, width: 40, height: 40))
            } else {
                widget = AnimationWidget.init(frame: CGRect(x: self.view.frame.size.width - 20 - 40, y: self.view.frame.size.height - 140, width: 40, height: 40))
            }
            
            self.view.addSubview(widget)
            widget.mainImageView.image = UIImage.init(named: "0.jpg")
            widget.addVerticalItem(arr: ["0.jpg", "0.jpg"])
            widget.addHorizontalArr(arr: ["0.jpg", "0.jpg"])
        }
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
