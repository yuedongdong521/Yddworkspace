//
//  UserInfoTableCell.swift
//  Yddworkspace
//
//  Created by ydd on 2018/8/3.
//  Copyright © 2018年 QH. All rights reserved.
//

import Foundation

public protocol UserinfoCellDelegate : NSObjectProtocol {
    
    func chooseBtnDeleagte(title:String?)
    func commitDelegate()
}

class UserInfoTabBaseCell: UITableViewCell {
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        
        label.frame = CGRect(x: 10, y: 0, width: 100, height: self.frame.size.height)
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var contentTextView : UITextField = {
        let textView = UITextField()
        textView.textAlignment = .right
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.black
        textView.frame = CGRect(x: 100 + 10 + 10, y: 0, width: UIScreen.main.bounds.size.width - 20 - 100 - 10, height: self.frame.size.height)
        self.contentView.addSubview(textView)
        return textView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserInfoChooseCell: UserInfoTabBaseCell {
    open weak var cellDeleagte : UserinfoCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.tureBtn)
        self.contentView.addSubview(self.falseBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tureBtn : UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.system)
        btn.setTitle("是", for: .normal)
        btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 60 - 60 - 20, y: 0, width: 60, height: self.frame.size.height)
        btn.setTitleColor(UIColor.blue, for: .selected)
        btn.setTitleColor(UIColor.gray, for: .normal)
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var falseBtn : UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.system)
        btn.setTitle("否", for: .normal)
        btn.frame = CGRect(x: UIScreen.main.bounds.size.width - 60 - 20, y: 0, width: 60, height: self.frame.size.height)
        btn.setTitleColor(UIColor.blue, for: .selected)
        btn.setTitleColor(UIColor.gray, for: .normal)
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        return btn
    }()
    
    @objc func btnAction(btn:UIButton?) {
        if (btn?.isEqual(self.tureBtn))! {
            self.tureBtn.isSelected = !self.tureBtn.isSelected
            self.falseBtn.isSelected = false
        } else {
            self.falseBtn.isSelected = !self.falseBtn.isSelected
            self.tureBtn.isSelected = false
        }
        
        if cellDeleagte != nil {
            
        }
        //    if cellDeleagte?.responds(to: #selector(chooseBtnDeleagte(title:))) {
        //      <#code#>
        //    }
        cellDeleagte?.chooseBtnDeleagte(title: btn?.currentTitle)
    }
}

class UserInfoTabFootView: UITableViewHeaderFooterView {
    
    open weak var delegate : UserinfoCellDelegate?
    
    lazy var commitBtn : UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.system)
        btn.setTitle("提交", for: .normal)
        btn.frame = CGRect(x: 30, y: 25, width: UIScreen.main.bounds.size.width - 40, height: 50)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.blue
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(commitAction), for: .touchUpInside)
        return btn
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.gray
        self.addSubview(self.commitBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func commitAction() {
        if (delegate?.responds(to: #selector(commitAction)))! {
            delegate?.commitDelegate()
        }
    }
    
}





