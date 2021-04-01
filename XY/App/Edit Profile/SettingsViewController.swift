//
//  SettingsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let changeEmailButton = FlatButton(text: "Change Email", icon: UIImage(systemName: "envelope.fill")!)
    private let changePasswordButton = FlatButton(text: "Change Password", icon: UIImage(systemName: "lock.fill")!)
    private let darkModeButton = GradientButton(text: "Light Mode", textColor: .black, gradient: [UIColor(0xFFFFFF), UIColor(0xF2F2F2)], style: .basic)
    private let lightModeButton = GradientButton(text: "Dark Mode", textColor: .white, gradient: [UIColor(0x626263), UIColor(0x141516)], style: .basic)
    private let logoutButton = FlatButton(text: "Log out", icon: UIImage(named: "settings_logout_icon")!, tintColor: UIColor(0xEF3A30))

    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "XYBackground")
        
        view.addSubview(changePasswordButton)
        view.addSubview(changeEmailButton)
        view.addSubview(darkModeButton)
        view.addSubview(lightModeButton)
        view.addSubview(logoutButton)
        
        darkModeButton.layer.cornerRadius = 15
        lightModeButton.layer.cornerRadius = 15
        
        changePasswordButton.addTarget(self, action: #selector(didPressChangePassword), for: .touchUpInside)
        changeEmailButton.addTarget(self, action: #selector(didPressChangeEmail), for: .touchUpInside)
        darkModeButton.addTarget(self, action: #selector(didPressDarkMode), for: .touchUpInside)
        lightModeButton.addTarget(self, action: #selector(didPressLightMode), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didPressLogout), for: .touchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        changePasswordButton.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: 51.95
        )
        
        changeEmailButton.frame = CGRect(
            x: 0,
            y: changePasswordButton.bottom,
            width: view.width,
            height: 51.95
        )
        
        lightModeButton.frame = CGRect(
            x: 14,
            y: changeEmailButton.bottom + 16.05,
            width: view.width/2 - 14 * 2,
            height: 65
        )
        
        darkModeButton.frame = CGRect(
            x: view.width/2 + 14,
            y: changeEmailButton.bottom + 16.05,
            width: view.width/2 - 14 * 2,
            height: 65
        )

        logoutButton.frame = CGRect(
            x: 0,
            y: darkModeButton.bottom + 15.95,
            width: view.width,
            height: 51.95
        )
    }
    
    @objc private func didPressChangePassword() {
        let vc = EditPasswordViewController()
        NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didPressChangeEmail() {
        let vc = EditEmailViewController()
        NavigationControlManager.mainViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didPressDarkMode() {
        
    }
    
    @objc private func didPressLightMode() {
        
    }
    
    @objc private func didPressLogout() {
        NavigationControlManager.performLogout()
    }
}
