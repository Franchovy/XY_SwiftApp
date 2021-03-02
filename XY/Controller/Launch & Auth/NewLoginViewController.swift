//
//  NewLoginViewController.swift
//  XY
//
//  Created by Maxime Franchot on 01/03/2021.
//

import UIKit
import Firebase


class NewLoginViewController : UIViewController {
    
    private let logo = UIImageView(image: UIImage(named: "XYnavbarlogo"))
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create account"
        label.font = UIFont(name: "Raleway-Heavy", size: 40)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    
    private let emailTextField: GradientBorderTextField = {
        let textField = GradientBorderTextField()
        textField.textColor = UIColor(named: "tintColor")?.withAlphaComponent(0.5)
        textField.font = UIFont(name: "Raleway-Heavy", size: 20)
        let attributes = [
            NSAttributedString.Key.font : UIFont(name: "Raleway-Heavy", size: 26)!
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes:attributes)
        textField.textAlignment = .center
        return textField
    }()
    
    private let passwordTextField: GradientBorderTextField = {
        let textField = GradientBorderTextField()
        textField.textColor = UIColor(named: "tintColor")?.withAlphaComponent(0.5)
        textField.font = UIFont(name: "Raleway-Heavy", size: 26)
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.textAlignment = .center
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: "tintColor"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 32)
        button.setTitle("Log in", for: .normal)
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 16)
        label.textColor = UIColor(named: "tintColor")
        label.text = " "
        return label
    }()
    
    private var gradientLayer: CAGradientLayer
    private let loadingIcon = UIActivityIndicatorView()
    
    init() {
        gradientLayer = Gradient.createGradientLayer(gradientColours: Global.lightModeBackgroundGradient, angle: 270)
        
        super.init(nibName: nil, bundle: nil)
        
//        view.layer.insertSublayer(gradientLayer, at: 0)
        view.backgroundColor = UIColor(named: "Black")
        
        isHeroEnabled = true
        
        view.layer.cornerRadius = 15
        
        loadingIcon.color = UIColor(named: "tintColor")
        
        emailTextField.setGradient(Global.xyGradient)
        emailTextField.setBackgroundColor(color: UIColor(named:"Black")!)
        passwordTextField.setGradient(Global.xyGradient)
        passwordTextField.setBackgroundColor(color: UIColor(named:"Black")!)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logo)
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loadingIcon)
        view.addSubview(errorLabel)
        view.addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        
        let tapAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tapAnywhereGesture)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = view.bounds
        
        logo.frame = CGRect(
            x: (view.width - 50.95)/2,
            y: view.safeAreaInsets.top,
            width: 50.95,
            height: 27
        )
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: (view.width - titleLabel.width)/2,
            y: view.height / 4 - titleLabel.height,
            width: titleLabel.width,
            height: titleLabel.height
        )
        
        let textFieldWidth:CGFloat = 281
        let textFieldHeight:CGFloat = 50
        let marginFromCenter:CGFloat = 12
        
        emailTextField.frame = CGRect(
            x: (view.width - textFieldWidth)/2,
            y: view.height/2 - textFieldHeight - marginFromCenter,
            width: textFieldWidth,
            height: textFieldHeight
        )
        
        passwordTextField.frame = CGRect(
            x: (view.width - textFieldWidth)/2,
            y: view.height/2 + marginFromCenter,
            width: textFieldWidth,
            height: textFieldHeight
        )
        
        loadingIcon.frame = CGRect(
            x: view.width/2 - 15,
            y: passwordTextField.bottom + 10,
            width: 30,
            height: 30
        )
        
        errorLabel.sizeToFit()
        errorLabel.frame = CGRect(
            x: (view.width - errorLabel.width)/2,
            y: loadingIcon.bottom + 10,
            width: errorLabel.width,
            height: errorLabel.height
        )
        
        loginButton.frame = CGRect(
            x: (view.width - 115)/2,
            y: errorLabel.bottom + 15,
            width: 115,
            height: 38
        )
    }
    
    @objc private func tappedAnywhere() {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    @objc private func loginPressed() {
        tappedAnywhere()
    
        guard let identifier = emailTextField.text, identifier != "" else {
            displayError(errorText: "Please enter an email")
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            displayError(errorText: "Please enter your password")
            return
        }
        
        loadingIcon.isHidden = false
        loadingIcon.startAnimating()
        
        AuthManager.shared.login(withEmail: identifier, password: password) { result in
            self.loadingIcon.isHidden = true
            self.loadingIcon.stopAnimating()
            
            switch result {
            case .success(let _):
                // Segue to main
                fatalError()
            //                    self.performSegue(withIdentifier: "LoginToProfile", sender: self)
            case .failure(let error):
                print("Error logging in: \(error)")
                
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    // Error handling
                    if errCode == .userNotFound || errCode == .wrongPassword {
                        self.displayError(errorText: "Please check your username or password.")
                    } else if errCode == .invalidEmail {
                        self.displayError(errorText: "Email is invalid.")
                    } else {
                        self.displayError(errorText: "Login failed")
                    }
                }
            }
        }
    
    }

    private func displayError(errorText: String) {
        errorLabel.isHidden = false
        errorLabel.text = "⚠️ " + errorText
        view.setNeedsLayout()
    }
}
