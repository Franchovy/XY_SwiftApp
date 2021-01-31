//
//  ProfileHeaderSettingsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 30/01/2021.
//

import UIKit

class ProfileHeaderSettingsViewController: UIViewController {

    private let settingsLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        let tintColor = UIColor(0xFF4D4D)
        button.setTitle("Log out", for: .normal)
        button.setTitleColor(tintColor, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        button.setBackgroundColor(color: UIColor(0xC6C6C6), forState: .normal)
        button.tintAdjustmentMode = .dimmed
        button.layer.cornerRadius = 15
        button.setImage(UIImage(systemName: "return")?.withTintColor(tintColor, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    
    private let oldPasswordField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(0xC6C6C6)
        textField.layer.cornerRadius = 15
        textField.textColor = .gray
        textField.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        textField.placeholder = "Current Password"
        textField.alpha = 0.0
        return textField
    }()
    
    private let changePasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change Password", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        button.setBackgroundColor(color: UIColor(0xC6C6C6), forState: .normal)
        button.tintAdjustmentMode = .dimmed
        button.layer.cornerRadius = 15
        button.setImage(UIImage(systemName: "return")?.withTintColor(.white, renderingMode: .alwaysTemplate), for: .normal)
        return button
    }()
    
    private let changeEmailButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change Email", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        button.setBackgroundColor(color: UIColor(0xC6C6C6), forState: .normal)
        button.tintAdjustmentMode = .dimmed
        button.layer.cornerRadius = 15
        button.setImage(UIImage(systemName: "return")?.withTintColor(.white, renderingMode: .alwaysTemplate), for: .normal)
        return button
    }()
    
    private let lightModeGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(0xF2F2F2).cgColor,
            UIColor(0xFFFFFF).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)
        return gradientLayer
    }()
    
    private let lightModeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("Light Mode", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        button.tintAdjustmentMode = .dimmed
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let darkModeGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(0x141516).cgColor,
            UIColor(0x626263).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)
        return gradientLayer
    }()
    
    private let darkModeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Dark Mode", for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        button.tintAdjustmentMode = .dimmed
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "Black")
        view.layer.cornerRadius = 15
        
        view.addSubview(settingsLabel)
        view.addSubview(logoutButton)
        view.addSubview(oldPasswordField)
        view.addSubview(changePasswordButton)
        view.addSubview(changeEmailButton)
        
        changePasswordButton.addTarget(self, action: #selector(changePasswordPressed), for: .touchUpInside)
        
        view.addSubview(lightModeButton)
        lightModeButton.layer.insertSublayer(lightModeGradient, below: nil)
        view.addSubview(darkModeButton)
        darkModeButton.layer.insertSublayer(darkModeGradient, below: nil)
        
        lightModeButton.addTarget(self, action: #selector(touchUpOnLightMode), for: .touchUpInside)
        darkModeButton.addTarget(self, action: #selector(touchUpOnDarkMode), for: .touchUpInside)
        
        let holdLightModePreviewGesture = UILongPressGestureRecognizer(target: self, action: #selector(previewLightMode(gestureRecognizer:)))
        holdLightModePreviewGesture.minimumPressDuration = 0.5
        lightModeButton.addGestureRecognizer(holdLightModePreviewGesture)
        
        let holdDarkModePreviewGesture = UILongPressGestureRecognizer(target: self, action: #selector(previewDarkMode(gestureRecognizer:)))
        holdDarkModePreviewGesture.minimumPressDuration = 0.5
        darkModeButton.addGestureRecognizer(holdDarkModePreviewGesture)
    }
    
    override func viewDidLayoutSubviews() {
        
        settingsLabel.sizeToFit()
        settingsLabel.frame = CGRect(
            x: 10,
            y: 30,
            width: settingsLabel.width,
            height: settingsLabel.height
        )
        
        changePasswordButton.frame = CGRect(
            x: 10,
            y: settingsLabel.bottom + 10,
            width: view.width - 20,
            height: 44
        )
        
        if let buttonTitle = changePasswordButton.titleLabel, let buttonImage = changePasswordButton.imageView {
            changePasswordButton.imageEdgeInsets = UIEdgeInsets(
                top: 11.83,
                left: 9.16,
                bottom: 12.63,
                right: buttonTitle.left + view.width/3
            )
            changePasswordButton.titleEdgeInsets = UIEdgeInsets(
                top: 11.83,
                left: view.width / 2 - buttonTitle.width - buttonImage.width,
                bottom: 12.63,
                right: view.width / 2 - buttonTitle.width
            )
        }
        
        changeEmailButton.frame = CGRect(
            x: 10,
            y: changePasswordButton.bottom + 10,
            width: view.width - 20,
            height: 44
        )
        
        if let buttonTitle = changeEmailButton.titleLabel, let buttonImage = changeEmailButton.imageView {
            changeEmailButton.imageEdgeInsets = UIEdgeInsets(
                top: 11.83,
                left: 9.16,
                bottom: 12.63,
                right: buttonTitle.left + view.width/3
            )
            changeEmailButton.titleEdgeInsets = UIEdgeInsets(
                top: 11.83,
                left: view.width / 2 - buttonTitle.width - buttonImage.width,
                bottom: 12.63,
                right: view.width / 2 - buttonTitle.width
            )
        }
        
        lightModeButton.frame = CGRect(
            x: 10,
            y: changeEmailButton.bottom + 10,
            width: 160,
            height: 65
        )
        lightModeGradient.frame = lightModeButton.bounds
        
        darkModeButton.frame = CGRect(
            x: lightModeButton.right + 28,
            y: changeEmailButton.bottom + 10,
            width: 160,
            height: 65
        )
        darkModeGradient.frame = darkModeButton.bounds
        
        logoutButton.frame = CGRect(
            x: 10,
            y: lightModeButton.bottom + 10,
            width: view.width - 20,
            height: 44
        )
        
        if let buttonTitle = logoutButton.titleLabel, let buttonImage = logoutButton.imageView {
            logoutButton.imageEdgeInsets = UIEdgeInsets(
                top: 11.83,
                left: 9.16,
                bottom: 12.63,
                right: buttonTitle.left + view.width/3
            )
            logoutButton.titleEdgeInsets = UIEdgeInsets(
                top: 11.83,
                left: view.width / 2 - buttonTitle.width - buttonImage.width,
                bottom: 12.63,
                right: view.width / 2 - buttonTitle.width
            )
        }
    }
    
    @objc private func changePasswordPressed() {
        
    }
    
    private func animateSpace(view: UIView) {
        
    }
    
    @objc private func previewLightMode(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            displayLightMode()
        } else if gestureRecognizer.state == .ended {
            displayDarkMode()
        }
    }
    
    @objc private func previewDarkMode(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            displayDarkMode()
        } else if gestureRecognizer.state == .ended {
            displayLightMode()
        }
    }
    
    @objc private func touchUpOnLightMode() {
        displayLightMode()
    }
    
    @objc private func touchUpOnDarkMode() {
        displayDarkMode()
    }
    
    private func displayLightMode() {
        if let window = UIApplication.shared.windows.first {
            UIView.transition (with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.overrideUserInterfaceStyle = .light
            }, completion: nil)
        }
    }
    
    private func displayDarkMode() {
        if let window = UIApplication.shared.windows.first {
            UIView.transition (with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.overrideUserInterfaceStyle = .dark
            }, completion: nil)
        }
    }
}

