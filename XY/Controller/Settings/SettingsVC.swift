//
//  SettingsVC.swift
//  XY_APP
//
//  Created by Maxime Franchot on 15/01/2021.
//

import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        guard let navVC  = tabBarController?.navigationController else {
            print("Could not access tab bar controller!")
            return
        }
        
        
        navVC.popToRootViewController(animated: true)
        
        do {
            try? Auth.auth().signOut()
            print("Successfully signed out.")
        } catch let error {
            print("Error signing out!")
        }
    }

}
