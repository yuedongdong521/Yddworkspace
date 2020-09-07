//
//  ShowViewAnimation.swift
//  Yddworkspace
//
//  Created by ydd on 2019/10/15.
//  Copyright © 2019 QH. All rights reserved.
//

import Foundation

extension UIView {
    func showCenterView(Completed completed:((_ finish:Bool) ->Void)?) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.identity
         }) { (finish) in
            if completed != nil {
                completed!(finish)
            }
         }
    }
    
    func dismissCenter(Completed completed:((_ finished:Bool) -> Void)?) {
        UIView.animate(withDuration: 0.3, delay: 2, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        }) { (finished) in
            self.removeFromSuperview()
            if completed != nil {
                completed!(finished)
            }
        }
    }
}

private let _muteLayer = malloc(4)
private let _animationCompleted = malloc(4)
private let _orignPoint = malloc(4)
private let kMuteAnimationKey = "muteAnimationKey"

extension UIView {
    var muteLayer:CAShapeLayer? {
        get {
           let layer = objc_getAssociatedObject(self, _muteLayer!)
            return layer == nil ? nil : (layer as! CAShapeLayer)
        }
        set {
            objc_setAssociatedObject(self, _muteLayer!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var animationCompleted :((_ finished:Bool)->Void)? {
        get {
            let completed = objc_getAssociatedObject(self, _animationCompleted!)
            return completed == nil ? nil : (completed as! ((_ finished:Bool)->Void))
        }
        set {
            objc_setAssociatedObject(self, _muteLayer!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var orignPoint :CGPoint {
        get {
            let orignPoint = objc_getAssociatedObject(self, _orignPoint!)
            return orignPoint == nil ? CGPoint.zero : (orignPoint as! CGPoint)
        }
        set {
            objc_setAssociatedObject(self, _orignPoint!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func showView(TopPoint topPoint:CGPoint, IsLeft isLeft:Bool, Space space:CGFloat, Radius radius:CGFloat, Animation animation:Bool, Completed completed:((_ finished:Bool) -> Void)?) {
        
        if animation {
            self.alpha = 0
        }
        if muteLayer != nil {
            muteLayer?.removeFromSuperlayer()
            muteLayer = nil
        }
        
        animationCompleted = completed
        
        orignPoint = topPoint
       self.backgroundColor = UIColor.clear
       let width = self.bounds.size.width
       let height = self.bounds.size.height
       let size:CGFloat = 10
       var x = topPoint.x
       let y = topPoint.y + size
       
       let path = UIBezierPath.init()
       path.move(to: CGPoint(x: radius, y: 0))
       
      
       if isLeft {
                  
           path.addLine(to: CGPoint(x: radius + space, y: 0))
           
           path.addLine(to: CGPoint(x: radius + space + size / 2, y: -size))
           
           path.addLine(to: CGPoint(x: radius + space + size, y: 0))
           
           x = x - (space + size / 2 + radius)
           
       } else {
       
           path.addLine(to: CGPoint(x: width - radius - space - size, y: 0))
           
           path.addLine(to: CGPoint(x: width - radius - space - size / 2, y: -size))
           
           path.addLine(to: CGPoint(x: width - radius - space, y: 0))
           
           x = x - (width - radius - size / 2 - space)
       }
       
       path.addLine(to: CGPoint(x: width - radius, y: 0))
       path.addArc(withCenter: CGPoint(x: width - radius, y: radius), radius: radius, startAngle: -CGFloat(Double.pi) / 2 , endAngle: 0, clockwise: true)
       
       path.addLine(to: CGPoint(x: width, y: height - radius))
       
       path.addArc(withCenter: CGPoint(x: width - radius, y: height - radius), radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi) / 2.0, clockwise: true)
       
       path.addLine(to: CGPoint(x: radius, y: height))
       
       path.addArc(withCenter: CGPoint(x: radius, y: height - radius), radius: radius, startAngle: CGFloat(Double.pi) / 2, endAngle: CGFloat(Double.pi), clockwise: true)
       
       path.addLine(to: CGPoint(x: 0, y: radius))
       
       path.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat(Double.pi), endAngle: -CGFloat(Double.pi) / 2, clockwise: true)
       
       
       path.close()
       
       muteLayer = CAShapeLayer.init()
       muteLayer!.backgroundColor = UIColor.gray.cgColor
       muteLayer!.fillColor = UIColor.clear.cgColor
       muteLayer!.strokeColor = UIColor.blue.cgColor
       muteLayer!.path = path.cgPath
       self.layer.insertSublayer(muteLayer!, at: 0)
       self.frame = CGRect(x: x, y: y, width: width, height: height)
        if animation {
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.alpha = 1
            }) { (finished) in
                completed?(finished)
                self.dismissMute(animation: true)
            }
            
        } else {
            self.isHidden = false
            self.animationCompleted?(true)
        }
   }
    
    func dismissMute(animation :Bool) {
        let x = (orignPoint.x - self.center.x) * 0.5
        let y = (orignPoint.y - self.center.y) * 0.5
        
        UIView.animate(withDuration: 0.3, delay: 1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.transform = CGAffineTransform.init(a: 0.5, b: 0.0, c: 0.0, d: 0.5, tx: x, ty: y)
            self.alpha = 0.5
        }) { (finished) in
            self.alpha = 0
            self.transform = CGAffineTransform.identity
            self.animationCompleted?(finished)
        }
        
        
    }
    
    
}

