//
//  ErrorHandlingManager.swift
//  XY
//
//  Created by Maxime Franchot on 06/04/2021.
//

import UIKit

final class ErrorHandlingManager {
    static func handleError(_ error: Error, message: String?, debugOnly: Bool) {
        #if DEBUG
        guard debugOnly == false else {
            return
        }
        #endif
        
        print("Error: \(error)")
        guard let mainVC = NavigationControlManager.mainViewController else {
            return
        }
        
        let prompt = Prompt()
        prompt.setTitle(text: "Error")
        if let message = message {
            prompt.addText(text: message)
        }
        
        prompt.addText(text: error.localizedDescription, font: UIFont(name: "Raleway-Bold", size: 12)!)
        
        mainVC.view.addSubview(prompt)
        prompt.appear()
    }
}
