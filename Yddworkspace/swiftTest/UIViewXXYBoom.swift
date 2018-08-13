//
//  UIView+XXYBang.swift
//  XXYBang~
//
//  Created by Xiaoxueyuan on 15/10/1.
//  Copyright (c) 2015年 Xiaoxueyuan. All rights reserved.
//

import UIKit
//扩展
extension UIView{
    
    fileprivate struct AssociatedKeys {
        static var BoomCellsName = "XXYBoomCells"
        static var ScaleSnapshotName = "XXYBoomScaleSnapshot"
    }
    //MARK: - 私有方法
    fileprivate var boomCells:[CALayer]?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.BoomCellsName) as? [CALayer]
        }
        set{
            if let newValue = newValue{
                willChangeValue(forKey: AssociatedKeys.BoomCellsName)
                objc_setAssociatedObject(self, &AssociatedKeys.BoomCellsName, newValue as [CALayer], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                didChangeValue(forKey: AssociatedKeys.BoomCellsName)
            }
        }
    }
    //截图
    fileprivate var scaleSnapshot:UIImage?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.ScaleSnapshotName) as? UIImage
        }
        set{
            if let newValue = newValue{
                willChangeValue(forKey: AssociatedKeys.ScaleSnapshotName)
                objc_setAssociatedObject(self, &AssociatedKeys.ScaleSnapshotName, newValue as UIImage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                didChangeValue(forKey: AssociatedKeys.ScaleSnapshotName)
            }
        }
    }
    
    func animateWhenClicked() {
        self.backgroundColor = UIColor(white:0.9,alpha:0.5)
        self.layer.transform = CATransform3DMakeScale(1, 1, 0)
        UIView.animate(withDuration: 1.9) {
            self.backgroundColor = UIColor.white
            self.layer.transform = CATransform3DMakeTranslation(1, 1, 1)
        }
    }
    
    
    //view的缩放和透明度动画
    @objc fileprivate func scaleOpacityAnimations(){
        
        let duration = 0.2
        
        //缩放
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.toValue = 0.01
        scaleAnimation.duration = duration//0.15
        scaleAnimation.fillMode = kCAFillModeForwards
        
        //透明度
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = duration//0.15
        opacityAnimation.fillMode = kCAFillModeForwards
        
        layer.add(scaleAnimation, forKey: "lscale")
        layer.add(opacityAnimation, forKey: "lopacity")
        layer.opacity = 0
    }
    
    //粒子动画
    @objc fileprivate func cellAnimations(){
        for shape in boomCells!{
            shape.position = center
            shape.opacity = Float(arc4random()%5 + 6) * 0.1
            //路径
            let moveAnimation = CAKeyframeAnimation(keyPath: "position")
            moveAnimation.path = makeRandomPath(shape).cgPath
            moveAnimation.isRemovedOnCompletion = false
            moveAnimation.fillMode = kCAFillModeForwards
            moveAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.240000, 0.590000, 0.506667, 0.026667)
            moveAnimation.duration = TimeInterval(arc4random()%10) * 0.05 + 0.3
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.toValue = makeScaleValue()
            scaleAnimation.duration = moveAnimation.duration
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = kCAFillModeForwards
            
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = shape.opacity//1
            opacityAnimation.toValue = 0
            opacityAnimation.duration = moveAnimation.duration
            opacityAnimation.delegate = nil
            opacityAnimation.isRemovedOnCompletion = true
            opacityAnimation.fillMode = kCAFillModeForwards
            opacityAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.380000, 0.033333, 0.963333, 0.260000)
            
            shape.opacity = 0
            shape.add(scaleAnimation, forKey: "scaleAnimation")
            shape.add(moveAnimation, forKey: "moveAnimation")
            shape.add(opacityAnimation, forKey: "opacityAnimation")
        }
    }
    
    //随机产生震动值
    fileprivate func makeShakeValue(_ p:CGFloat) -> CGFloat{
        let basicOrigin = -CGFloat(10)
        let maxOffset = -2 * basicOrigin
        return basicOrigin + maxOffset * (CGFloat(arc4random()%101)/CGFloat(100)) + p
    }
    
    //随机产生缩放数值
    fileprivate func makeScaleValue() -> CGFloat{
        let a = arc4random()%101
        var b:UInt32 = 0
        if (a > 50) {
            b = a - 50
        }
        
        return 1 - 0.7 * (CGFloat(b)/CGFloat(50))
    }
    
    //随机产生粒子路径
    fileprivate func makeRandomPath(_ aLayer:CALayer) -> UIBezierPath{
        let particlePath = UIBezierPath()
        particlePath.move(to: layer.position)
        let basicLeft = -CGFloat(1.3 * layer.frame.size.width)
        let maxOffset = 2 * abs(basicLeft)
        let randomNumber = arc4random()%101
        let endPointX = basicLeft + maxOffset * (CGFloat(randomNumber)/CGFloat(100)) + aLayer.position.x
        let controlPointOffSetX = (endPointX - aLayer.position.x)/2  + aLayer.position.x
        let controlPointOffSetY = layer.position.y - 0.2 * layer.frame.size.height - CGFloat(arc4random()%UInt32(1.2 * layer.frame.size.height))
        let endPointY = layer.position.y + layer.frame.size.height/2 + CGFloat(arc4random()%UInt32(layer.frame.size.height/2))
        particlePath.addQuadCurve(to: CGPoint.init(x: endPointX, y: endPointY), controlPoint: CGPoint.init(x: controlPointOffSetX, y: controlPointOffSetY))
        return particlePath
    }
    
    fileprivate func colorWithPoint(_ x:Int,y:Int,image:UIImage) -> UIColor{
        let pixelData = image.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(image.size.width) * y) + x) * 4
        
        let a = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let r = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    //移除粒子
    fileprivate func removeBoomCells(){
        if boomCells == nil {
            return
        }
        for item in boomCells!{
            item.removeFromSuperlayer()
        }
        boomCells?.removeAll(keepingCapacity: false)
        boomCells = nil
    }
    
    //MARK: - 公开方法
    //从layer获取View的截图
    func snapshot() -> UIImage{
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func boom(){
        //摇摆~ 摇摆~ 震动~ 震动~
        let shakeXAnimation = CAKeyframeAnimation(keyPath: "position.x")
        shakeXAnimation.duration = 0.2
        shakeXAnimation.values = [makeShakeValue(layer.position.x),makeShakeValue(layer.position.x),makeShakeValue(layer.position.x),makeShakeValue(layer.position.x),makeShakeValue(layer.position.x)]
        let shakeYAnimation = CAKeyframeAnimation(keyPath: "position.y")
        shakeYAnimation.duration = shakeXAnimation.duration
        shakeYAnimation.values = [makeShakeValue(layer.position.y),makeShakeValue(layer.position.y),makeShakeValue(layer.position.y),makeShakeValue(layer.position.y),makeShakeValue(layer.position.y)]
        
        
        layer.add(shakeXAnimation, forKey: "shakeXAnimation")
        layer.add(shakeYAnimation, forKey: "shakeYAnimation")
        
        _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(UIView.scaleOpacityAnimations), userInfo: nil, repeats: false)
        
        if boomCells == nil{
            boomCells = [CALayer]()
            for i in 0...16{
                for j in 0...16{
                    if scaleSnapshot == nil{
                        scaleSnapshot = snapshot().scaleImageToSize(CGSize.init(width: 34, height: 34))
                    }
                    let pWidth = min(frame.size.width,frame.size.height)/17
                    let color = scaleSnapshot!.getPixelColorAtLocation(CGPoint.init(x: CGFloat(i * 2), y: CGFloat(j * 2)))
                    let shape = CALayer()
                    shape.backgroundColor = color.cgColor
                    shape.opacity = 0
                    shape.cornerRadius = pWidth/2
                    shape.frame = CGRect.init(x: CGFloat(i) * pWidth, y: CGFloat(j) * pWidth, width: pWidth, height: pWidth)
                    layer.superlayer?.addSublayer(shape)
                    boomCells?.append(shape)
                }
            }
        }
        
        _ = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(UIView.cellAnimations), userInfo: nil, repeats: false)
    }
    
    //重置状态
    func reset(){
        layer.opacity = 1
    }
    
  @objc func XXY_willMoveToSuperview(_ newSuperView:UIView){
        removeBoomCells()
        //XXY_willMoveToSuperview(newSuperView)
    }
    
    //MARK: - 生命周期相关，在从父View移除的时候释放粒子
  static open func myInitialize() {
        struct Static {
            static var token: Int = 0
        }
        
        if (Static.token == 0) {
            let originalSelector = #selector(willMove(toSuperview:))
            let swizzledSelector = #selector(XXY_willMoveToSuperview)
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
          let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
            
            if didAddMethod {
              class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
              method_exchangeImplementations(originalMethod!, swizzledMethod!);
            }
        }
        Static.token = 1
    }
    
    
    
    
}
extension UIImage{
    
    fileprivate struct AssociatedKeys {
        static var aRGBBitmapContextName = "aRGBBitmapContext"
    }
    
    fileprivate var aRGBBitmapContext:CGContext?{
        get{
            return (objc_getAssociatedObject(self, &AssociatedKeys.aRGBBitmapContextName) as! CGContext?)
        }
        set{
            if let newValue = newValue{
                willChangeValue(forKey: AssociatedKeys.aRGBBitmapContextName)
                objc_setAssociatedObject(self, &AssociatedKeys.aRGBBitmapContextName, newValue as CGContext, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                didChangeValue(forKey: AssociatedKeys.aRGBBitmapContextName)
            }
        }
    }
    
    func createARGBBitmapContextFromImage() -> CGContext{
        if aRGBBitmapContext != nil{
            return aRGBBitmapContext!
        }else{
            let pixelsWidth = self.cgImage!.width
            let pixelsHeitht = self.cgImage!.height
            let bitmapBytesPerRow = pixelsWidth * 4
            let bitmapByteCount = bitmapBytesPerRow * pixelsHeitht
            let colorSpace = CGColorSpaceCreateDeviceRGB()
          let bitmapData = UnsafeMutableRawPointer.allocate(byteCount: bitmapByteCount, alignment: 0)
            let context = CGContext(data: bitmapData,width: pixelsWidth,height: pixelsHeitht,bitsPerComponent: 8,bytesPerRow: bitmapBytesPerRow,space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)!
            aRGBBitmapContext = context
            return context
        }
    }
    
    func getPixelColorAtLocation(_ point:CGPoint) -> UIColor{
        let inImage = self.cgImage
        let cgctx = createARGBBitmapContextFromImage()

        let w = CGFloat(inImage!.width)
        let h = CGFloat(inImage!.height)
        let rect = CGRect.init(x: 0, y: 0, width: w, height: h)
        cgctx.draw(inImage!, in: rect)
        //let resData = UnsafePointer<UInt8>(CGBitmapContextGetData(cgctx))
        
        let image = cgctx.makeImage();
        let pixelData = image!.dataProvider!.data
        let resData:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = 4*((Int(w*round(point.y)))+Int(round(point.x)))
        
        let a = CGFloat(resData[pixelInfo]) / CGFloat(255.0)
        let r = CGFloat(resData[pixelInfo+1]) / CGFloat(255.0)
        let g = CGFloat(resData[pixelInfo+2]) / CGFloat(255.0)
        let b = CGFloat(resData[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)

        //return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    //缩放图片
    func scaleImageToSize(_ size:CGSize) -> UIImage{
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let res = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return res!
    }
    
}
