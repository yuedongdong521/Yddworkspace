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
    
    func showView(TopPoint topPoint:CGPoint, IsLeft isLeft:Bool, Space space:CGFloat, Radius radius:CGFloat, Completed completed:((_ finished:Bool) -> Void)?) {
        /*
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: width - 2 * radius, y: 0))
        path.addArc(withCenter: CGPoint(x: width - 2 * radius, y: radius), radius: radius, startAngle: <#T##CGFloat#>, endAngle: <#T##CGFloat#>, clockwise: <#T##Bool#>)
        
        
        */
        
    }
    
    
}

