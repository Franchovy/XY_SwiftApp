//
//  Segue.swift
//  XY_APP
//
//  Created by Maxime Franchot on 13/12/2020.
//

import Foundation
import UIKit

enum Scenes {
    case LoginScreen
}

class Segue {
    struct SceneData {
        let identifier: String
        // type: ViewControllerType
        init(_ scene: Scenes) {
            switch scene {
            case Scenes.LoginScreen:
                identifier = "LoginViewController"
            }
        }
    }
    
    // TODO - func Segue to profile(username/profile)
    // TODO - segue to (scene)
    static func segueTo(_ scene: Scenes) -> UIViewController {
        // Get scene data
        let sceneData = SceneData(scene)
        
        if #available(iOS 13.0, *) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            return storyboard.instantiateViewController(identifier: sceneData.identifier)
        } else {
            // Fallback on earlier versions
            fatalError()
        }
    }
}
