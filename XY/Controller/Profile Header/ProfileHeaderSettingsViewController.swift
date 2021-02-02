//
//  ProfileHeaderSettingsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 30/01/2021.
//

import UIKit
import FirebaseAuth

protocol ProfileHeaderSettingsViewControllerDelegate {
    func didLogOut()
}

class ProfileHeaderSettingsViewController: UIViewController {
    
    var delegate: ProfileHeaderSettingsViewControllerDelegate?

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
    
    // MARK: - Change password fields
    
    private let newPasswordField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(0xC6C6C6)
        textField.layer.cornerRadius = 15
        textField.textColor = .gray
        textField.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        textField.placeholder = "New Password"
        textField.isSecureTextEntry = true
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        textField.rightView = button
        textField.rightViewMode = .always
        return textField
    }()
    
    private let oldPasswordField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(0xC6C6C6)
        textField.layer.cornerRadius = 15
        textField.textColor = .gray
        textField.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        textField.placeholder = "Current Password"
        textField.isSecureTextEntry = true
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        textField.rightView = button
        textField.rightViewMode = .always
        return textField
    }()
    
    private let changePasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change Password", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        button.setBackgroundColor(color: UIColor(0xC6C6C6), forState: .normal)
        button.tintAdjustmentMode = .dimmed
        button.layer.cornerRadius = 15
        button.setImage(UIImage(systemName: "key.fill")?.withTintColor(.white, renderingMode: .alwaysTemplate), for: .normal)
        return button
    }()
    
    private var changePasswordCurrentlyAnimated = false
    
    // MARK: - Change Email Fields
    
    private let changeEmailButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change Email", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        button.setBackgroundColor(color: UIColor(0xC6C6C6), forState: .normal)
        button.tintAdjustmentMode = .dimmed
        button.layer.cornerRadius = 15
        button.setImage(UIImage(systemName: "envelope.fill")?.withTintColor(.white, renderingMode: .alwaysTemplate), for: .normal)
        return button
    }()
    
    // MARK: - Light and Dark Mode Fields
    
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
    
    // MARK: - Lifecycle, ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        view.backgroundColor = UIColor(named: "Black")
        view.layer.cornerRadius = 15
        
        view.addSubview(settingsLabel)
        view.addSubview(logoutButton)
        
        view.addSubview(newPasswordField)
        view.addSubview(oldPasswordField)
        view.addSubview(changePasswordButton)
        
        if let rightButton = oldPasswordField.rightView as? UIButton {
            rightButton.addTarget(self, action: #selector(oldPasswordSubmitted), for: .touchUpInside)
        }
        if let rightButton = newPasswordField.rightView as? UIButton {
            rightButton.addTarget(self, action: #selector(newPasswordSubmitted), for: .touchUpInside)
        }
        
        view.addSubview(changeEmailButton)
        
        changePasswordButton.addTarget(self, action: #selector(changePasswordPressed), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
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
    
    // MARK: - ViewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        
        settingsLabel.sizeToFit()
        settingsLabel.frame = CGRect(
            x: 10,
            y: 30,
            width: settingsLabel.width,
            height: settingsLabel.height
        )
        
        if !changePasswordCurrentlyAnimated {
            
            changePasswordButton.frame = CGRect(
                x: 10,
                y: settingsLabel.bottom + 10,
                width: view.width - 20,
                height: 44
            )
            
            oldPasswordField.frame = changePasswordButton.frame.applying(CGAffineTransform(translationX: view.width, y: 0))
            newPasswordField.frame = changePasswordButton.frame.applying(CGAffineTransform(translationX: view.width, y: 0))
            
            oldPasswordField.rightView?.frame = CGRect(
                x: CGFloat(oldPasswordField.frame.size.width - 25),
                y: CGFloat(5),
                width: CGFloat(25),
                height: CGFloat(25)
            )
            newPasswordField.rightView?.frame = CGRect(x: CGFloat(oldPasswordField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
            
            if let buttonTitle = changePasswordButton.titleLabel, let buttonImage = changePasswordButton.imageView {
                changePasswordButton.imageEdgeInsets = UIEdgeInsets(
                    top: 11.83,
                    left: 9.16,
                    bottom: 12.63,
                    right: buttonTitle.left + view.width/3
                )
                changePasswordButton.titleEdgeInsets = UIEdgeInsets(
                    top: 11.83,
                    left: view.width / 2 - buttonTitle.width - buttonImage.width + 5,
                    bottom: 12.63,
                    right: view.width / 2 - buttonTitle.width
                )
            }
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
            x: (view.width/2 - 160)/2,
            y: changeEmailButton.bottom + 10,
            width: 160,
            height: 65
        )
        lightModeGradient.frame = lightModeButton.bounds
        
        darkModeButton.frame = CGRect(
            x: (view.width*3/2 - 160)/2,
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
    
    // MARK: - Obj-C Private Functions
    
    @objc private func logout() {
        do {
            try Auth.auth().signOut()
            
            delegate?.didLogOut()
        } catch let error {
            print("Error logging out: \(error)")
        }
        
    }
    
    @objc private func changePasswordPressed() {
        
        changePasswordCurrentlyAnimated = true
        
        let outOfViewLeftX = changePasswordButton.frame.origin.x - view.width
        let outOfViewRightX = changePasswordButton.frame.origin.x + view.width
        let inScreenPosX = changePasswordButton.frame.origin.x
        
        // Show old password text field
        UIView.animate(withDuration: 0.3) {
            self.changePasswordButton.frame.origin.x = outOfViewLeftX
            self.oldPasswordField.frame.origin.x = inScreenPosX
        } completion: { (done) in
            // Show next
            if done {
                self.oldPasswordField.becomeFirstResponder()
            }
        }
        
        // Animate the button to the left
        // make visible the text field, animate it from the right
        // old password entered, click next
        // animate it to left, make next visible and animate it
        // confirm
        // Send firebase request
        // bring button back
        
    }
    
    @objc private func oldPasswordSubmitted() {
        
        guard let passwordEntry = oldPasswordField.text,
              let button = oldPasswordField.rightView as? UIButton else {
            return
        }
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        oldPasswordField.rightView = activityIndicator
        
        let outOfViewLeftX = oldPasswordField.frame.origin.x - view.width
        let outOfViewRightX = oldPasswordField.frame.origin.x + view.width
        let inScreenPosX = oldPasswordField.frame.origin.x
        
        AuthManager.shared.verifyPassword(password: passwordEntry) { (passwordCorrect, error) in
            if let error = error {
                print("Error verifying password: \(error.localizedDescription)")
            } else if let passwordCorrect = passwordCorrect {
                self.oldPasswordField.rightView = button
                
                if passwordCorrect {
                    // Proceed
                    UIView.animate(withDuration: 0.3) {
                        self.oldPasswordField.frame.origin.x = outOfViewLeftX
                        self.newPasswordField.frame.origin.x = inScreenPosX
                    } completion: { (done) in
                        self.oldPasswordField.frame.origin.x = outOfViewRightX
                    }
                } else {
                    // Invalid password
                    self.oldPasswordField.shake()
                    self.oldPasswordField.text = ""
                }
            }
        }
    }
    
    @objc private func newPasswordSubmitted() {
        let outOfViewRightX = newPasswordField.frame.origin.x + view.width
        let inScreenPosX = newPasswordField.frame.origin.x
        
        guard let newPassword = newPasswordField.text,
              let button = oldPasswordField.rightView as? UIButton else {
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        oldPasswordField.rightView = activityIndicator
        
        AuthManager.shared.changePassword(newPassword: newPassword) { (error) in
            if let error = error {
                print("Error changing to new password: \(error)")
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.newPasswordField.frame.origin.x = outOfViewRightX
                    self.changePasswordButton.frame.origin.x = inScreenPosX
                } completion: { done in
                    if done {
                        self.newPasswordField.rightView = button
                        self.changePasswordCurrentlyAnimated = false
                    }
                }
            }
        }
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

