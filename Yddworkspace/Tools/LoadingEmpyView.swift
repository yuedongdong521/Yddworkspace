//
//  LoadingEmpyView.swift
//  Yddworkspace
//
//  Created by ydd on 2019/11/11.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class LoadingEmpyView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    lazy var maskLayer :CAShapeLayer = {
        let layer = CAShapeLayer.init();
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: 20, y: 0))
        path.addLine(to: CGPoint(x: 40, y: 0))
        path.addLine(to: CGPoint(x: 20, y: 30))
        path.addLine(to: CGPoint(x: 0, y: 30))
        path.addLine(to: CGPoint(x: 20, y: 0))
        path.close()
        layer.fillColor = UIColor.init(white: 1, alpha: 0.5).cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.init(white: 1, alpha: 0.5).cgColor
        layer.path = path.cgPath
        return layer;
    }()
    
    lazy var coverLayer :CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.backgroundColor = UIColor.init(white: 0.5, alpha: 1).cgColor
        return layer
    }()
    
    lazy var textLabel :UILabel = {
        let label = UILabel.init()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
//        label.backgroundColor = UIColor.gray
        return label;
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
      
        self.textLabel.text = "今日头条"
        self.addSubview(self.textLabel)
        self.textLabel.mas_makeConstraints { (make) in
            make?.center.equalTo()(self)
            make?.size.mas_equalTo()(CGSize(width: 100, height: 30))
        }
    }
    
    func startMaskLayerAncition() {
        let rect = self.textLabel.bounds
        self.coverLayer.frame = rect;
        self.textLabel.layer.addSublayer(self.coverLayer)
        self.maskLayer.frame = rect;
        self.coverLayer.mask = self.maskLayer
//        let animation = CABasicAnimation.init(keyPath: "locations")
//        animation.fromValue = 0
//        animation.toValue = 1
//        animation.duration = 1
//        animation.repeatCount = 5
//        animation.isRemovedOnCompletion = false
//        self.maskLayer.add(animation, forKey: "locations-maskLayer");
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
