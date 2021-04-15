//
//  ColorLabelViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

struct ColorLabelViewModel {
    var colorLabelText: String
    var colorLabelColor: UIColor
    
    static var sentTo: ColorLabelViewModel {
        get {
            ColorLabelViewModel(colorLabelText: "Sent to", colorLabelColor: UIColor(0xFF0062))
        }
    }
    
    static var new: ColorLabelViewModel {
        get {
            ColorLabelViewModel(colorLabelText: "New", colorLabelColor: UIColor(0xCAF035))
        }
    }
    
    static var expiring: ColorLabelViewModel {
        get {
            ColorLabelViewModel(colorLabelText: "Expiring", colorLabelColor: UIColor(0xAAAAAA))
        }
    }
}
