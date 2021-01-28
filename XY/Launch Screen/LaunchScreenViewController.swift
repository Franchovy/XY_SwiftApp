//
//  LaunchScreenViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 01/01/2021.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    @IBOutlet weak var noConnectionWarning: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !API.shared.hasConnection {
            noConnectionWarning.isHidden = false
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
