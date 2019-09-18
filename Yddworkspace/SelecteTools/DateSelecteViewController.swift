//
//  DateSelecteViewController.swift
//  Yddworkspace
//
//  Created by ydd on 2019/9/2.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class DateSelecteViewController: UIViewController {

    lazy var griadLayer: CAGradientLayer = {
       let layer = CAGradientLayer.init()
        layer.colors = [ColorHexRGBA(rgb: 0xFFA692, a: 1).cgColor, ColorHexRGBA(rgb: 0xD15FFF, a: 1).cgColor]
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.locations = [0, 1]
        return layer
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        let dateSelecte = UIDatePicker.init(frame: CGRect(x: 0, y: self.view.frame.size.height - 300, width: self.view.frame.size.width, height: 300))
        self.view.addSubview(dateSelecte)
        
        let progressView = UIView.init(frame: CGRect(x: 20, y: 100, width: 300, height: 20));
        progressView.backgroundColor = UIColor.gray
        self.view.addSubview(progressView)
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 10
        
        self.griadLayer.frame = progressView.bounds
        progressView.layer.addSublayer(self.griadLayer)
        
        let path = UIBezierPath.init()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: 50, y: 0))
        path.addArc(withCenter: CGPoint(x: 50, y: 10), radius: 10, startAngle: CGFloat(3.0 / 2 * Double.pi), endAngle: CGFloat(1.0 / 2 * Double.pi), clockwise: true)
        path.addLine(to: CGPoint(x: 0, y: 20))
        path.close()
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = self.griadLayer.bounds
        maskLayer.path = path.cgPath
        self.griadLayer.mask = maskLayer
        
        let manager = DateManager.shareManager()
        let curTime = manager.getCurTime()
        print("curtime = \(curTime)")
        let curDate = manager.getDate(time: curTime)
        print("curdate = \(curDate)")
        let dateStr = manager.dateStr(date: curDate)
        print("dateStr = \(dateStr)")
        
        let week = manager.getWeekForDate(date: curDate)
        print("week \(week?.chineseWeek() ?? "获取周失败")")
        
        let days = manager.getCurMonthDays(date: curDate)
        print("days = \(days)")
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
