//
//  NewSignupViewController.swift
//  XY
//
//  Created by Maxime Franchot on 01/03/2021.
//

import UIKit
import Firebase

class NewSignupViewController: UIViewController {
    
    private let logo = UIImageView(image: UIImage(named: "XYNavbarLogo"))
    
    private let titleLabel = GradientLabel(text: "Create Account", fontSize: 40, gradientColours: Global.darkModeBackgroundGradient)
    
    private let xynameTextField: GradientBorderTextField = {
        let textField = GradientBorderTextField()
        textField.textColor = UIColor(named: "tintColor")?.withAlphaComponent(0.5)
        textField.font = UIFont(name: "Raleway-Heavy", size: 20)
        let attributes = [
            NSAttributedString.Key.font : UIFont(name: "Raleway-Heavy", size: 26)!
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "XYName", attributes:attributes)
        textField.textAlignment = .center
        return textField
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
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let passwordTextField: GradientBorderTextField = {
        let textField = GradientBorderTextField()
        textField.textColor = UIColor(named: "tintColor")?.withAlphaComponent(0.5)
        textField.font = UIFont(name: "Raleway-Heavy", size: 26)
        textField.placeholder = "Password"
        textField.setManualSecureEntry()
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let checkPasswordTextField: GradientBorderTextField = {
        let textField = GradientBorderTextField()
        textField.textColor = UIColor(named: "tintColor")?.withAlphaComponent(0.5)
        textField.font = UIFont(name: "Raleway-Heavy", size: 26)
        textField.placeholder = "Repeat Password"
        textField.setManualSecureEntry()
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: "tintColor"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 32)
        button.setTitle("Sign Up", for: .normal)
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 16)
        label.textColor = UIColor(named: "tintColor")
        label.text = " "
        return label
    }()
    
    private let gradientLayer: CAGradientLayer
    private let loadingIcon = UIActivityIndicatorView()
    
    init() {
        gradientLayer = Gradient.createGradientLayer(gradientColours: Global.lightModeBackgroundGradient, angle: 206)
        
        super.init(nibName: nil, bundle: nil)

//        view.layer.insertSublayer(gradientLayer, at: 0)
        view.backgroundColor = UIColor(named: "Black")
        
        isHeroEnabled = true
        titleLabel.heroID = "titleLabel"
        
        view.layer.cornerRadius = 15
        
        loadingIcon.color = UIColor(named: "tintColor")
        
        xynameTextField.setGradient(Global.xyGradient)
        xynameTextField.setBackgroundColor(color: UIColor(named:"Black")!)
        emailTextField.setGradient(Global.xyGradient)
        emailTextField.setBackgroundColor(color: UIColor(named:"Black")!)
        passwordTextField.setGradient(Global.xyGradient)
        passwordTextField.setBackgroundColor(color: UIColor(named:"Black")!)
        checkPasswordTextField.setGradient(Global.xyGradient)
        checkPasswordTextField.setBackgroundColor(color: UIColor(named:"Black")!)
        
        xynameTextField.addTarget(self, action: #selector(xynameNext), for: .primaryActionTriggered)
        emailTextField.addTarget(self, action: #selector(emailNext), for: .primaryActionTriggered)
        passwordTextField.addTarget(self, action: #selector(passwordNext), for: .primaryActionTriggered)
        checkPasswordTextField.addTarget(self, action: #selector(checkPasswordNext), for: .primaryActionTriggered)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logo)
        view.addSubview(titleLabel)
        view.addSubview(xynameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(checkPasswordTextField)
        view.addSubview(loadingIcon)
        view.addSubview(errorLabel)
        view.addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        
        let tapAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tapAnywhereGesture)
        
        if #available(iOS 14.0, *) {
            navigationItem.backButtonDisplayMode = .minimal
        }
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
            y: view.height / 4 - 50,
            width: titleLabel.width,
            height: 50
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
        
        xynameTextField.frame = CGRect(
            x: (view.width - textFieldWidth)/2,
            y: emailTextField.top - textFieldHeight - 2*marginFromCenter,
            width: textFieldWidth,
            height: textFieldHeight
        )
        
        passwordTextField.frame = CGRect(
            x: (view.width - textFieldWidth)/2,
            y: view.height/2 + marginFromCenter,
            width: textFieldWidth,
            height: textFieldHeight
        )
        
        checkPasswordTextField.frame = CGRect(
            x: (view.width - textFieldWidth)/2,
            y: passwordTextField.bottom + 2*marginFromCenter,
            width: textFieldWidth,
            height: textFieldHeight
        )
        
        loadingIcon.frame = CGRect(
            x: view.width/2 - 15,
            y: checkPasswordTextField.bottom + 10,
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
            x: (view.width - 150)/2,
            y: errorLabel.bottom + 15,
            width: 150,
            height: 38
        )
    }
    
    @objc private func tappedAnywhere() {
        xynameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        checkPasswordTextField.resignFirstResponder()
    }
    
    @objc private func signUpPressed() {
        tappedAnywhere()
        
        guard let email = emailTextField.text, email != "" else {
            displayError(errorText: "Please enter an email")
            return
        }
        
        guard let xyname = xynameTextField.text, xyname != "" else {
            displayError(errorText: "Please enter a XYName")
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            displayError(errorText: "Please enter your password")
            return
        }
        
        guard let repeatPassword = checkPasswordTextField.text, repeatPassword == password else {
            displayError(errorText: "Passwords don't match")
            return
        }
        
        loadingIcon.isHidden = false
        loadingIcon.startAnimating()
        
        AuthManager.shared.signUp(xyname: xyname, email: email, password: password) { result in
            self.loadingIcon.isHidden = true
            self.loadingIcon.stopAnimating()
            
            switch result {
            case .success(let _):
                // Segue to main
                HapticsManager.shared?.vibrate(for: .success)
                
                let vc = UINavigationController(rootViewController: TabBarViewController())
                vc.modalPresentationStyle = .fullScreen
                vc.heroModalAnimationType = .pageIn(direction: .left)
                self.present(vc, animated: true)
            case .failure(let error):
                print("Error logging in: \(error)")
                
                if let signupErrorMessage = error as? AuthManager.CreateUserError {
                    self.displayError(errorText: signupErrorMessage.message)
                } else {
                    self.displayError(errorText: "Error signing up!")
                }
            }
        }
        
    }
    
    private func displayError(errorText: String) {
        errorLabel.isHidden = false
        errorLabel.text = "⚠️ " + errorText
        view.setNeedsLayout()
    }
    
    @objc private func xynameNext() {
        emailTextField.becomeFirstResponder()
    }
    
    @objc private func emailNext() {
        passwordTextField.becomeFirstResponder()
    }
    
    @objc private func passwordNext() {
        checkPasswordTextField.becomeFirstResponder()
    }
    
    @objc private func checkPasswordNext() {
        signUpPressed()
    }
}
