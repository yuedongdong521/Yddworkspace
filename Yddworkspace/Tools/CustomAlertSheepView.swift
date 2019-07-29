//
//  CustomAlertSheepView.swift
//  Yddworkspace
//
//  Created by ydd on 2019/7/8.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class ItemView: UIView {
    var itemIndex = 0
    var tapBlock:((Int)->Void)?
    lazy var titleLabel :UILabel = {
        let label = UILabel.init(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height))
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    func getItemHeight() -> CGFloat {
        titleLabel.sizeToFit()
        let labelH = titleLabel.frame.size.height
        var itemH = labelH + 20
        itemH = itemH > 50 ? itemH : 50
        return itemH
    }
    
    func resetFrame(frame:CGRect) {
         titleLabel.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: frame.size.height)
        self.frame = frame;
    }
    
    convenience init(title:String) {
        self.init()
        titleLabel.text = title
        self.addSubview(titleLabel)
        self.backgroundColor = UIColor.init(red: 254 / 255.0, green: 254 / 255.0, blue: 254 / 255.0, alpha: 1)
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tapGesAction))
        self.addGestureRecognizer(tapGes)
    }
    
    @objc func tapGesAction() {
        if tapBlock != nil {
            tapBlock!(itemIndex)
        }
    }
    
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
}

@objcMembers class CustomAlertSheepView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let screenHeight = UIScreen.main.bounds.size.height
    let screenWidth =  UIScreen.main.bounds.size.width
    private var itemBlock:((Int)->Void)?
    private var cancelBlock:(()->Void)?
    private let itemBaseTag = 100
    private let cancelTag = 10
    var itemTop:CGFloat = 0
    
    lazy var contentView :UIView = {
       let view = UIView.init()
        view.backgroundColor = UIColor.white
        self.addSubview(view)
        return view
    }()
    
    
    @objc convenience init(contentItes items:[String], cancelTitle:String?, itemAction:((Int)->Void)?, cancelAction:(()->Void)?) {
        self.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        itemBlock = itemAction
        cancelBlock = cancelAction
        
        let count = items.count
        for index in 0..<count {
            let title = items[index]
            let item = ItemView.init(title: title)
            item.itemIndex = index
            item.tapBlock = itemTapAction
            item.tag = itemBaseTag + index
            contentView.addSubview(item)
            let itemH = item.getItemHeight()
            item.resetFrame(frame:CGRect(x: 0, y: itemTop, width: screenWidth, height: itemH))
            itemTop += itemH
            
            if index < count - 1 {
                let line = UIView.init(frame: CGRect(x: 0, y: itemH - 1, width: screenWidth, height: 1))
                line.backgroundColor = UIColor.init(red: 170.0 / 255, green: 170.0 / 255, blue: 170.0 / 255, alpha: 1)
                item .addSubview(line)
            }
        }
        
        if cancelTitle != nil {
            
            let cancelItem = ItemView.init(title: cancelTitle!)
            cancelItem.tapBlock = cancelTapAction
            cancelItem.tag = cancelTag
            contentView.addSubview(cancelItem)
            let itemH = cancelItem.getItemHeight()
            
            let canelHeader = UIView.init(frame: CGRect(x: 0, y: itemTop, width: screenWidth, height: 10))
            canelHeader.backgroundColor = UIColor.init(red: 170.0 / 255, green: 170.0 / 255, blue: 170.0 / 255, alpha: 1)
            contentView.addSubview(canelHeader)
            itemTop += 10
            cancelItem.resetFrame(frame: CGRect(x: 0, y: itemTop, width: screenWidth, height: itemH))
            itemTop += itemH
        }
        
        itemTop += IPHONE_X_SAFE_BOTTOM
        
        contentView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: itemTop)
        
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tapGes)
    }
    
    func itemTapAction(index:Int) {
        if itemBlock != nil {
            itemBlock!(index)
        }
        self.dismissAnimation(animation: true)
    }
    
    func cancelTapAction(index:Int) {
        if cancelBlock != nil {
            cancelBlock!()
        }
        self.dismissAnimation(animation: true)
    }
    
    @objc func getItemView(itemIndex index:Int) -> ItemView? {
        return self.contentView.viewWithTag(index + itemBaseTag) as? ItemView
    }
    
    @objc func getCanncel() -> ItemView? {
        return self.contentView.viewWithTag(cancelTag) as? ItemView
    }

    @objc func showAnimation(animation:Bool) {
        UIApplication.shared.keyWindow?.addSubview(self)
        let contentFrame = CGRect(x: 0, y: screenHeight - itemTop, width: screenWidth, height: itemTop)
        if animation {
            UIView.animate(withDuration: 0.3, animations: {
                self.contentView.frame = contentFrame
            }) { (finish: Bool) in
                
            }
        } else {
           contentView.frame = contentFrame
        }
    }
    
    @objc func dismissAnimation(animation:Bool) {
        if animation {
            var contentFrame = contentView.frame
            contentFrame.origin.y = screenHeight
            UIView.animate(withDuration: 0.3, animations: {
                self.contentView.frame = contentFrame
            }) { (finish:Bool) in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }
    
    func tapAction() {
        self.dismissAnimation(animation: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
