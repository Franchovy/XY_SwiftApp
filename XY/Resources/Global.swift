//
//  Global.swift
//  XY
//
//  Created by Maxime Franchot on 01/03/2021.
//

import UIKit

class Global {
    static let xyGradient:[UIColor] = [UIColor(0xFF0062), UIColor(0x0C98F6)]
    
    static var isLightMode: Bool = false
    static var lightModeBackgroundGradient:[UIColor] {
        get {
            if isLightMode {
                return [UIColor(0xD9D9D9), UIColor(0xCBCBCB), UIColor(0xF2F2F2)]
            } else {
                return [UIColor(0x141516), UIColor(0x1C1D1E), UIColor(0x333333)]
            }
        }
    }
}
