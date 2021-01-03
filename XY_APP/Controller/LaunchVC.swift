//
//  LaunchVC.swift
//  XY_APP
//
//  Created by Maxime Franchot on 03/01/2021.
//

import UIKit

class LaunchVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Check if this is the first time
        // -> segue to signup
        
        // Check for authentication status
        // no auth -> segue to login
        // auth -> segue to main
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        performSegue(withIdentifier: "segueToLogin", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
