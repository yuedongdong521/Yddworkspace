//
//  CalendarYearSelectedView.swift
//  Yddworkspace
//
//  Created by ydd on 2019/9/17.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class CalendarYearSelectedView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var dateArr = Array<Int>()
    var curYear:Int = 0
    var didselected:((_ selectedIndex:Int)->Void)?
    
    init(frame: CGRect, year:Int, selectedBlock:@escaping (_ selectedIndex:Int)->Void) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        let bgView = UIView.init(frame: frame)
        bgView.backgroundColor = ColorHexRGBA(rgb: 0x000000, a: 0.3)
        self.addSubview(bgView)
        bgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hidSelectedView)))
        
        
        self.curYear = year
        self.didselected = selectedBlock
        let beforYear = curYear - 10
        for year in 0..<20 {
            self.dateArr.append(beforYear + year)
        }
        self.addSubview(self.pickerView)
        self.pickerView.backgroundColor = UIColor.white
        DispatchQueue.main.async {
            self.pickerView.selectRow(10, inComponent: 0, animated: true)
        }

    }
    
    @objc func hidSelectedView() {
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dateArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var cell = view as? UILabel
        if cell == nil {
            cell = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.size.width, height: 40))
            cell?.textAlignment = .center
        }
        cell!.text = String(self.dateArr[row])
        return cell!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.didselected != nil {
            self.didselected!(self.dateArr[row])
        }
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    lazy var pickerView :UIPickerView = {
        let view = UIPickerView(frame: CGRect(x: self.bounds.midX - 100, y: self.bounds.midY - 50, width: 200, height: 200))
        view.dataSource = self
        view.delegate = self
        for subView in view.subviews {
            subView.backgroundColor = UIColor.clear
        }
        view.backgroundColor = UIColor.white
        return view
    }()
    
//    picker
}
