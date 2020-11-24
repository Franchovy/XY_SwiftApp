//
//  File.swift
//  XY_APP
//
//  Created by Maxime Franchot on 24/11/2020.
//

import Foundation

final class Message: Codable {
    var id:Int?
    var message:String
    
    init(message: String) {
        self.message = message
    }
}
