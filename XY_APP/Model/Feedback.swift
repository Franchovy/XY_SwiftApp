//
//  FeedbackData.swift
//  XY_APP
//
//  Created by Maxime Franchot on 21/12/2020.
//

import Foundation


// Feedback data is initialised for all posts inside of the XY APP and collect viewtime and other feedback, to send as updates to the backend. 
struct Feedback : Encodable {
    var swipeRight: Int = 0
    var swipeLeft: Int = 0
    var viewTime: Float = 0
}

