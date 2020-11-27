//
//  Profile.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import Foundation

struct Profile {
var name : String
var response : [String:Int]
var message : [String : Int]

    
    init(profileName : String, answer : [String:Int], xymessage : [String : Int]) {
        
        self.name = profileName
        self.response = answer
        self.message = xymessage
     }
}
