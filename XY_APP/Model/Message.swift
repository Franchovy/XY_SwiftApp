//
//  Message.swift
//  Flash Chat iOS13
//
//  Created by Simone on 07/12/2020.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import Foundation

struct Conversation {
    let username: String
    let message: String
    
    init(username: String, message: String) {
        self.username = username
        self.message = message
    }
}
