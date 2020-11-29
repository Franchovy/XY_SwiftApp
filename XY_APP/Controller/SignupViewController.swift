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
            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        // Checks on signup data
        if (passwordText != repeatPasswordText) {
            return
        }
        var signup = Signup()
        signup.validateSignupForm(username: usernameText!, password: passwordText!, email: emailPhoneText!, phoneNumber: "")
        
        // Send signup request
        var success = signup.requestSignup { result in
            switch result {
            case .success(let message):
                print("Signup Success: ", message)
                // Segue to home screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "InterestsPage")
                self.show(secondVC, sender: self)

            case .failure(let error):
                print("Signup failure: ", error)
                self.signupErrorLabel.isHidden = false
            }
        }
     }
}
 
