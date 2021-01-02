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
        
        // Load persistent auth token if available
            // Request to backend auth token login
        // else
            // Prompt login
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.xyLogoVerticalAlignmentConstraint.constant = 0
        self.loginViewVerticalAlignmentConstraint.constant = 0

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
            self.xyLogoVerticalAlignmentConstraint.constant -= 200
            self.view.layoutIfNeeded()
        }, completion: { _ in self.loginAppear() })
    
    }
    
    override func viewWillLayoutSubviews() {
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Custom methods
    
    func loginAppear() {
        loginView.isHidden = false
        
        // THIS ANIMATION IS NOT WORKING
        UIView.animate(withDuration: 0.7, delay: 0.2, options: [], animations: {
            self.loginViewVerticalAlignmentConstraint.constant += 200
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
