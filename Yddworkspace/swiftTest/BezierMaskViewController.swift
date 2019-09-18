//
//  BezierMaskViewController.swift
//  Yddworkspace
//
//  Created by ydd on 2019/9/9.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit


extension UIView {
    func customDraw(bezierPath path: UIBezierPath) {
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.borderWidth = 1;
        layer.borderColor = UIColor.gray.cgColor
        self.layer.mask = layer
    }
}

class BezierMaskViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let testView1 = UILabel.init(frame: CGRect(x: 20, y: 100, width: 100, height: 40));
        testView1.backgroundColor = UIColor.red
        testView1.layer.borderColor = UIColor.gray.cgColor
        self.view.addSubview(testView1)
        let w = testView1.frame.size.width
        let h = testView1.frame.size.height
        
        let r = h * 0.5
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: r, y: 0))
        path.addLine(to: CGPoint(x: w - r, y: 0))
        path.addLine(to: CGPoint(x: w, y: r))
        path.addLine(to: CGPoint(x: w - r, y: h))
        path.addLine(to: CGPoint(x: r, y: h))
        path.addArc(withCenter: CGPoint(x: r, y: r), radius: r, startAngle: CGFloat(Double.pi * 0.5), endAngle: CGFloat(Double.pi * 1.5), clockwise: true)
        path.close()
        testView1.customDraw(bezierPath: path)
        
        
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
