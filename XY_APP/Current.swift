//
//  init.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/12/2020.
//

import Foundation


class Current {
    var username: String = ""
    static var sharedCurrentData = Current()
    
    static func setUsername(_ username:String) {
        sharedCurrentData.username = username
    }
}
