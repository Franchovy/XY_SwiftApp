//
//  ViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 17/11/2020.
//

import UIKit




struct SessionTokenResponse: Decodable {
    let url: URL
}

class SignupViewController: UIViewController {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var xynamePlaceholder: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    

        self.hideKeyboardWhenTappedAround()
        
        signupButton.layer.cornerRadius = 8
        signupButton.layer.borderWidth = 1.0
        signupButton.layer.borderColor = UIColor.white.cgColor
        usernameTextField.layer.cornerRadius = 8
        gradientView.layer.cornerRadius = 20
        
    }
    
    // UI Textfield reference outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailPhoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    // Error notification reference outlets
    @IBOutlet weak var signupErrorLabel: UILabel!
    
    @IBAction func signupButton(_ sender: Any)  {
        // Get data from textfields
        let usernameText = usernameTextField.text
        let emailPhoneText = emailPhoneTextField.text
        let passwordText = passwordTextField.text
        let repeatPasswordText = repeatPasswordTextField.text
        
        usernameTextField.endEditing(true)
        emailPhoneTextField.endEditing(true)
        passwordTextField.endEditing(true)
        repeatPasswordTextField.endEditing(true)
        
        // Checks on signup data
        if (passwordText != repeatPasswordText) {
            return
        }
        
        Auth.shared.register(username: usernameText!, password: passwordText!, email: emailPhoneText!, phoneNumber: "", completion: { result in
            switch result {
            case .success(let message):
                print("Signup Success: ", message)
                // Segue to home screen
                DispatchQueue.main.async {
                    if #available(iOS 13.0, *) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "InterestsPage")
                        self.show(secondVC, sender: self)
                    } else {
                       let storyboard = UIStoryboard(name: "Main", bundle: nil)
                       let vc = storyboard.instantiateViewController(withIdentifier: "storyboard.instantiateViewController") as! InterestsViewController
                       self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .failure(let error):
                print("Signup failure: ", error)
                DispatchQueue.main.async {
                    self.signupErrorLabel.isHidden = false
                }
            }
        })
    }
}
