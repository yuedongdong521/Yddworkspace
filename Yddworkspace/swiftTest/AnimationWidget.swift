//
//  AnimationWidget.swift
//  Yddworkspace
//
//  Created by ydd on 2019/10/10.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class Widget: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AnimationWidget: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var orginSize :CGFloat = 0
    private var orginFrame = CGRect.zero
    private var horizontalArr = Array<UIButton>()
    private var verticalArr = Array<UIButton>()
    
    private let margin:CGFloat = 20
    private let edge:CGFloat = 10
    private var switchStatus = false
    private var openWidth :CGFloat = 0
    private var openHeight :CGFloat = 0
    private var openFrame = CGRect.zero
    private var beganCenter = CGPoint.zero
    
    let horizontalTag = 1000
    let verticalTag = 2000
    var horizontalBlock:((_ tag:Int)->Void)?
    var verticalBlock:((_ tag:Int)->Void)?
    
    lazy var mainImageView :UIImageView = {
        let imageView = UIImageView.init()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(mainTapAction)))
        imageView.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(mainPanAction(pan:))))
        return imageView
    }()
    
    @objc func mainTapAction() -> Void {
        self.mainImageView.isUserInteractionEnabled = false
        switchStatus = !switchStatus
        if switchStatus {
            openWidgetAnimation {[weak self] (finished) in
                self?.mainImageView.isUserInteractionEnabled = true
            }
            
        } else {
            resetWidgetAnimation {[weak self] (finished) in
                self?.mainImageView.isUserInteractionEnabled = true
            }
        }
    }
    
    private func openWidgetAnimation(completed:@escaping(_ finished:Bool)->Void) {
        var frame = self.mainImageView.frame
        let superCenter = self.superview!.center
        let selfCenter = self.center
        var xDirect:Bool
        var yDirect:Bool
        
        if selfCenter.x > superCenter.x {
            if selfCenter.y  >  superCenter.y {
                self.frame = CGRect(x: self.orginFrame.maxX - self.openWidth, y: self.orginFrame.maxY - self.openHeight, width: self.openWidth, height: self.openHeight)
                frame.origin.y = self.openHeight - self.orginSize
                frame.origin.x = self.openWidth - self.orginSize
                xDirect = false
                yDirect = false
            } else {
                self.frame = CGRect(x: self.orginFrame.maxX - self.openWidth, y: self.orginFrame.origin.y, width: self.openWidth, height: self.openHeight)
                frame.origin.x = self.openWidth - self.orginSize
                xDirect = false
                yDirect = true
            }
        } else {
            if selfCenter.y  >  superCenter.y {
                self.frame = CGRect(x: self.orginFrame.origin.x, y: self.orginFrame.maxY - self.openHeight, width: self.openWidth, height: self.openHeight)
                frame.origin.y = self.openHeight - self.orginSize
                xDirect = true
                yDirect = false
            } else {
                self.frame = CGRect(x: self.orginFrame.origin.x, y: self.orginFrame.origin.y, width: self.openWidth, height: self.openHeight)
                xDirect = true
                yDirect = true
            }
        }
        
        self.mainImageView.frame = frame
        
        for i in 0..<self.horizontalArr.count {
            self.horizontalArr[i].frame = frame
        }

        for i in 0..<self.verticalArr.count {
            self.verticalArr[i].frame = frame
        }
    
        UIView.animate(withDuration: 0.3, animations: {
            for i in 0..<self.horizontalArr.count {
                let btn = self.horizontalArr[i]
                var x = (self.edge + self.orginSize) * CGFloat(1 + i)
                x = xDirect ? x : -x
                btn.transform = CGAffineTransform.identity.translatedBy(x: x, y: 0)
            }
            
            for i in 0..<self.verticalArr.count {
                let btn = self.verticalArr[i]
                var y = (self.edge +  self.orginSize) * CGFloat(1 + i)
                y = yDirect ? -y : y
                btn.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -y)
            }
        }) { (finshed) in
            completed(finshed)
        }
    }
    
    private func resetWidgetAnimation(completed:@escaping(_ finished:Bool)->Void) {
        UIView.animate(withDuration: 0.3, animations: {
           for i in 0..<self.horizontalArr.count {
               let btn = self.horizontalArr[i]
               btn.transform = CGAffineTransform.identity
           }
           for i in 0..<self.verticalArr.count {
               let btn = self.verticalArr[i]
               btn.transform = CGAffineTransform.identity
           }
        }) { (finshed) in
            self.resetWidget()
           completed(finshed)
        }
    }
    
    
    private func resetWidget() {
        self.frame = self.orginFrame
        self.mainImageView.frame = self.bounds
        
        for i in 0..<self.horizontalArr.count {
            let btn = self.horizontalArr[i]
            btn.frame = self.bounds
        }
        for i in 0..<self.verticalArr.count {
            let btn = self.verticalArr[i]
            btn.frame = self.bounds
        }
    }
    
    @objc func mainPanAction(pan:UIPanGestureRecognizer) -> Void {
        if self.switchStatus {
            return
        }
        switch pan.state {
        case UIGestureRecognizerState.began:
            self.beganCenter = self.center
            break
        case UIGestureRecognizerState.changed:
            let moveP = pan.translation(in: self.superview)
            print(moveP)
            var centX = self.beganCenter.x + moveP.x
            var centY = self.beganCenter.y + moveP.y
            
            if centX > self.superview!.frame.size.width - self.margin - self.orginSize * 0.5 {
                centX = self.superview!.frame.size.width - self.margin - self.orginSize * 0.5
            } else if centX < self.margin + self.orginSize * 0.5 {
                centX = self.margin + self.orginSize * 0.5
            }
            if centY > self.superview!.frame.size.height - self.margin - self.orginSize * 0.5 {
                centY = self.superview!.frame.size.height - self.margin - self.orginSize * 0.5
            } else if centY < self.margin + self.orginSize * 0.5 {
                centY = self.margin + self.orginSize * 0.5
            }
            self.center = CGPoint(x: centX, y: centY)
            break
        case UIGestureRecognizerState.ended:
            self.orginFrame.origin = self.frame.origin
            break
        case UIGestureRecognizerState.cancelled:
            self.orginFrame.origin = self.frame.origin
            break
            
            
        default:
            break
        }
        
    }
    
    @objc func verticalAction(btn:UIButton) {
        print("vertical btn tag \(btn.tag)")
        if verticalBlock != nil {
            verticalBlock!(btn.tag)
        }
    }
    
    @objc func horizontalAction(btn:UIButton) {
        print("horizontal btn tag \(btn.tag)")
        if horizontalBlock != nil {
            horizontalBlock!(btn.tag)
        }
    }
    
    func addVerticalItem(arr:Array<String>) -> Void {
        for i in 0..<arr.count {
            let btn = UIButton.init(type: .custom)
            btn.addTarget(self, action: #selector(verticalAction(btn:)), for: .touchUpInside)
            btn.frame = self.bounds;
            btn.layer.cornerRadius = self.orginSize * 0.5
            btn.layer.masksToBounds = true
            btn.setBackgroundImage(UIImage.init(named: arr[i]), for: .normal)
            btn.tag = self.verticalArr.count + self.verticalTag
            self.insertSubview(btn, at: 0)
            self.verticalArr.append(btn)
        }
        self.openHeight = (self.orginSize + self.edge) * CGFloat(self.verticalArr.count) + self.orginSize
        
    }
    
    func addHorizontalArr(arr:Array<String>) -> Void {
        for i in 0..<arr.count {
            let btn = UIButton.init(type: .custom)
            btn.addTarget(self, action: #selector(horizontalAction(btn:)), for: .touchUpInside)
            btn.frame = self.bounds;
            btn.layer.cornerRadius = self.orginSize * 0.5
            btn.layer.masksToBounds = true
            btn.setBackgroundImage(UIImage.init(named: arr[i]), for: .normal)
            btn.tag = self.horizontalArr.count + self.horizontalTag
            self.insertSubview(btn, at: 0)
            self.horizontalArr.append(btn)
        }
        self.openWidth = (self.orginSize + self.edge) * CGFloat(self.horizontalArr.count) + self.orginSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.mainImageView)
        self.mainImageView.frame = self.bounds
        self.mainImageView.layer.cornerRadius = self.bounds.size.width * 0.5
        self.mainImageView.layer.masksToBounds = true
        self.orginFrame = frame
        self.orginSize = self.bounds.size.width
        self.openHeight = frame.size.height
        self.openWidth = frame.size.width
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}
