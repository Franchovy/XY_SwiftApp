//
//  WeakListenerClass.swift
//  XY
//
//  Created by Maxime Franchot on 03/05/2021.
//

import Foundation

final class WeakListenerClass {
    init(_ listener: ListenerClass) {
        reference = listener
    }
    
    weak var reference: ListenerClass?
}


protocol ListenerClass: NSObject {
    
}
