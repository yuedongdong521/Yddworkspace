//
//  CustomNavigationBarView.swift
//  Yddworkspace
//
//  Created by ydd on 2019/7/5.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

@objcMembers class CustomNavigationBarView: UIView {
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    typealias NavigationAction = () -> Void
    
    @objc var leftAction: NavigationAction?
    @objc var rightAction: NavigationAction?
    
    
    
    lazy var leftBtn :UIButton = {
       let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "nav_back"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        button.addTarget(self, action: #selector(leftBtnAction(button:)), for: .touchUpInside)
        
       return button
    }()
    
    @objc func leftBtnAction(button:UIButton?) {
        if leftAction != nil {
            leftAction!()
        }
    }
    
    @objc lazy var rightBtn: UIButton = {
    
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(rightBtnAction(button:)), for: .touchUpInside)
         button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        self.addSubview(button)
        button.mas_makeConstraints({ (make: MASConstraintMaker?) in
            make?.right.equalTo()(0)
            make?.bottom.equalTo()(0)
            make?.height.width().equalTo()(44)
        })
        return button
    }()
    
    @objc lazy var titleLabel: UILabel = {
       let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(label)
        label.mas_makeConstraints({ (make: MASConstraintMaker?) in
            make?.left.equalTo()(44)
            make?.right.equalTo()(-44)
            make?.bottom.equalTo()(0)
            make?.height.equalTo()(44)
        })
        return label
    }()
    
    @objc func rightBtnAction(button:UIButton?) {
        if rightAction != nil {
             rightAction!()
        }
    }
    
    @objc func setTitle(title:String?) {
        guard title?.count == 0  else {
            self.titleLabel.text = title
            return
        }
    }
    @objc func setRightBtnTitle(title:String?, image:UIImage?) {
        guard title?.count == 0 else {
            self.rightBtn.setTitle(title, for: .normal)
            return
        }
        guard image == nil else {
            self.rightBtn.setImage(image, for: .normal)
            return
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setLeftBackBtn()
    }
    
    func setLeftBackBtn() {
        self.addSubview(self.leftBtn)
        self.leftBtn.mas_makeConstraints({ (make: MASConstraintMaker?) in
            make?.left.bottom().equalTo()(0)
            make?.height.width().equalTo()(44)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
