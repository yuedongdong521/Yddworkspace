//
//  DeviceTools.swift
//  Yddworkspace
//
//  Created by ydd on 2019/7/8.
//  Copyright © 2019 QH. All rights reserved.
//

import Foundation

class DeviceTools : NSObject {
    
}

let IS_IPHONE: Bool = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)

/*iPhone X
 2436×1125
 {375, 812}
 @3x
 
 iPhone XR
 1792x828
 {414, 896}
 @2x
 
 iPhone XS
 2436×1125
 {375, 812}
 @3x
 
 iPhone XS Max
 2688x1242
 {414, 896}
 @3x*/
let IS_STANDARD_IPHONE_X: Bool = (IS_IPHONE && UIScreen.main.bounds.size.height == 812.0 || UIScreen.main.bounds.size.height == 896 )

let IPHONE_X_SAFE_BOTTOM: CGFloat = IS_STANDARD_IPHONE_X ? 34 : 0

let IPHONE_X_SAFE_TOP: CGFloat = IS_STANDARD_IPHONE_X ? 44 : 0

func ColorHexRGBA(rgb:UInt32,a:CGFloat)->UIColor {
   return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat((rgb & 0x0000FF)) / 255.0, alpha: a)
}
