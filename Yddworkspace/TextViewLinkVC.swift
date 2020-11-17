//
//  TextViewLinkVC.swift
//  Yddworkspace
//
//  Created by ydd on 2019/12/12.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class TextViewLinkVC: UIViewController, UITextViewDelegate {

    lazy var textView :UITextView = {
        let textView = UITextView.init()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.delegate = self
        
 
        let gesList = textView.gestureRecognizers ?? Array()
        for i in 0..<gesList.count {
            let ges = gesList[i]
            if !ges.isMember(of: UITapGestureRecognizer.classForCoder()) {
                view.removeGestureRecognizer(ges)
            }
        }
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.addSubview(self.textView)
        self.view.backgroundColor = UIColor.white
        
        self.textView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets(top: 100, left: 20, bottom: 100, right: 20))
        }
        
        let str = "UITextView 添加富文本点击事件，屏蔽UITextView其他多余手势事件"
        
        let mutAtt = NSMutableAttributedString.init(string: str)
        let range:Range! = str.range(of: "点击")
        
        
        mutAtt.addAttributes([NSAttributedString.Key.link : "click://", NSAttributedString.Key.foregroundColor : UIColor.red], range: str.nsRange(from: range))
        
        let paragraph = NSMutableParagraphStyle.init()
        paragraph.lineBreakMode = NSLineBreakMode.byCharWrapping
        mutAtt.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSMakeRange(0, mutAtt.length))
        self.textView.attributedText = mutAtt
        
    }
    

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "click" {
            print("点击")
            return false
        }
        
        
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

    
extension String {
     
    //Range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        if from == nil || to == nil {
            return NSRange()
        }
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from!),
                       length: utf16.distance(from: from!, to: to!))
    }
     
    //Range转换为NSRange
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location,
                                     limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length,
                                   limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}
