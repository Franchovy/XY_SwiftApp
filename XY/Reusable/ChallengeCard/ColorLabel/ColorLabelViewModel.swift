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
    
    static var accepted: ColorLabelViewModel {
        get {
            ColorLabelViewModel(colorLabelText: "Accepted", colorLabelColor: .XYGreen)
        }
    }
    
    static var rejected: ColorLabelViewModel {
        get {
            ColorLabelViewModel(colorLabelText: "Rejected", colorLabelColor: .XYRed)
        }
    }
    
    static var complete: ColorLabelViewModel {
        get {
            ColorLabelViewModel(colorLabelText: "Complete", colorLabelColor: .XYBlue)
        }
    }
}
