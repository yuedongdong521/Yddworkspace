//
//  SelecteToolsViewController.swift
//  Yddworkspace
//
//  Created by ydd on 2019/9/2.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class PickerItems: UIView {
    
    lazy var titleLabel: UILabel = {
       let label = UILabel.init()
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.titleLabel)
        self.titleLabel.mas_makeConstraints { (make: MASConstraintMaker?) in
            make?.edges.mas_equalTo()(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        self.backgroundColor = UIColor.cyan
    }
    
 
    
    func updateTitle(title: String?) {
        self.titleLabel.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SelecteToolsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var years: Array<Int>!
    var mouths: Array<Int>!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        years = getYears()
        mouths = getMouths()
        
        let seleteTools = UIPickerView.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300))
        seleteTools.delegate = self
        seleteTools.dataSource = self
        seleteTools.showsSelectionIndicator = true
        self.view.addSubview(seleteTools)
        
        for view in seleteTools.subviews {
            print(NSStringFromClass(view.classForCoder))
            view.backgroundColor = UIColor.clear
        }
        
        
    }
    
    func getYears() -> Array<Int> {
        var arr = Array<Int>.init()
        for i in 0..<10 {
            arr.append(i + 2010)
        }
        return arr
    }
    
    func getMouths() -> Array<Int> {
        var arr = Array<Int>.init()
        for i in 0..<12 {
            arr.append(i + 1)
        }
        return arr
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return self.view.frame.size.width / 2
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return component == 0 ? String(years[row]) : String(mouths[row])
//    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? years.count : mouths.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleStr = component == 0 ? String(years[row]) : String(mouths[row])
        
        var item = view as? PickerItems
        if item == nil {
            item = PickerItems.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 2, height: 44))
            
            for lineView in pickerView.subviews {
                if !lineView.isKind(of: PickerItems.classForCoder()) {
                    lineView.backgroundColor = UIColor.clear
                }
            }
        }
        item!.updateTitle(title: titleStr)
        
        
        return item!
    }
    

}

