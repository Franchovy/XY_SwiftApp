//
//  LaunchScreenViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 01/01/2021.
//

import UIKit

class xy_profiles_controller_launch: UIViewController {

    @IBOutlet weak var noConnectionWarning: UILabel!

    @IBOutlet weak var loginView: xy_profiles_view_login!
    
    @IBOutlet weak var xyLogoVerticalAlignmentConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginViewVerticalAlignmentConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If first time logging in -> display Signup
        // if no login session -> display Login

        // Load persistent auth token if available
            // Request to backend auth token login
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.xyLogoVerticalAlignmentConstraint.constant = 0
        self.loginViewVerticalAlignmentConstraint.constant = 700

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [], animations: {
            self.xyLogoVerticalAlignmentConstraint.constant -= 200
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        // Animate login view
        loginView.isHidden = false
        UIView.animate(withDuration: 0.45, delay: 0.1, options: [], animations: {
            self.loginViewVerticalAlignmentConstraint.constant -= 500
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
