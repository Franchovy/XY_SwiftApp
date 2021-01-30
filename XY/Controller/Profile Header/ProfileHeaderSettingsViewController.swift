//
//  ProfileHeaderSettingsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 30/01/2021.
//

import UIKit

class ProfileHeaderSettingsViewController: UIViewController {

    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log out", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        button.backgroundColor = UIColor(0xC6C6C6)
        button.layer.cornerRadius = 15
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 15
        view.backgroundColor = .red
        
        view.addSubview(logoutButton)
    }
    
    override func viewDidLayoutSubviews() {
        logoutButton.frame = CGRect(
            x: 27/2,
            y: 66,
            width: view.width - 27,
            height: 44
        )
    }
    
}
