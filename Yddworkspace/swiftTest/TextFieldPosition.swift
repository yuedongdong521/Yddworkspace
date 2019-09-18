//
//  TextFieldPosition.swift
//  Yddworkspace
//
//  Created by ydd on 2019/9/12.
//  Copyright © 2019 QH. All rights reserved.
//

import Foundation

extension UITextField {
    func selectedRange() -> NSRange? {
        let beginning = self.beginningOfDocument
        let selectedRange = self.selectedTextRange
        guard let selectionStart = selectedRange?.start else { return nil }
        guard let selectionEnd = selectedRange?.end else { return nil }
        let location = self.offset(from: beginning, to: selectionStart)
        let length = self.offset(from: selectionStart, to: selectionEnd)
        return NSRange(location: location, length: length)
    }
    
    func setSelectedRange(range :NSRange) {
        let beginning = self.beginningOfDocument
        let startPosition = self.position(from: beginning, offset: range.location)
        let endPostion = self.position(from: beginning, offset: NSMaxRange(range))
        if startPosition == nil || endPostion == nil {
            return
        }
        let selectionRange = self.textRange(from: startPosition!, to: endPostion!)
        self.selectedTextRange = selectionRange
    }
    
    
}
