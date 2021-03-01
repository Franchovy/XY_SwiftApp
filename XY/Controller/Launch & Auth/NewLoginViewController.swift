//
//  NewLoginViewController.swift
//  XY
//
//  Created by Maxime Franchot on 01/03/2021.
//

import UIKit
import Firebase

class NewLoginViewController : UIViewController {
    
    private let titleHeader: UILabel = {
        return UILabel()
    }()
    
    private let identifierTextField: GradientBorderTextField = {
        let textField = GradientBorderTextField()
        textField.textColor = UIColor(named: "tintColor")?.withAlphaComponent(0.5)
        textField.font = UIFont(name: "Raleway-Heavy", size: 26)
        textField.placeholder = "XYName or email"
        textField.textAlignment = .center
        return textField
    }()
    
    private let passwordTextField: GradientBorderTextField = {
        let textField = GradientBorderTextField()
        textField.textColor = UIColor(named: "tintColor")?.withAlphaComponent(0.5)
        textField.font = UIFont(name: "Raleway-Heavy", size: 26)
        textField.placeholder = "XYName or email"
        textField.isSecureTextEntry = true
        textField.textAlignment = .center
        return textField
    }()
    
    private let errorLabel = UILabel()
    
    private let loadingIcon = UIActivityIndicatorView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "Black")
        isHeroEnabled = true
        
        view.layer.cornerRadius = 15
        
        loadingIcon.color = .white
        
        identifierTextField.setGradient(Global.xyGradient)
        identifierTextField.setBackgroundColor(color: UIColor(named:"Black")!)
        passwordTextField.setGradient(Global.xyGradient)
        passwordTextField.setBackgroundColor(color: UIColor(named:"Black")!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(identifierTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loadingIcon)
        
        let tapAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tapAnywhereGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let textFieldWidth:CGFloat = 281
        let textFieldHeight:CGFloat = 50
        let marginFromCenter:CGFloat = 12
        
        identifierTextField.frame = CGRect(
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
            y: identifierTextField.bottom + 10,
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
        
    }
    
    @objc func tappedAnywhere() {
        passwordTextField.resignFirstResponder()
        identifierTextField.resignFirstResponder()
    }
    
    func loginPressed(_ sender: UIButton) {
        tappedAnywhere()
        
        if let email = identifierTextField.text, let password = passwordTextField.text {
            
            loadingIcon.isHidden = false
            loadingIcon.startAnimating()

            AuthManager.shared.login(withEmail: email, password: password) { result in
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
                            self.displayError(errorText: "Login incorrect!")
                        } else {
                            self.displayError(errorText: "Login failed")
                        }
                    }
                }
            }
        }
    }
    
    private func displayError(errorText: String) {
        errorLabel.isHidden = false
        errorLabel.text = "⚠️ " + errorText
    }
}
