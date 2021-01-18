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
        do {
            try? Auth.auth().signOut()
        } catch let error {
            print("Error signing out!")
        }
        
        let rootVC = navigationController?.popToRootViewController(animated: true)?.last
        let tabBarVC = rootVC?.tabBarController
        tabBarVC?.navigationController?.popToRootViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
