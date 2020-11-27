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
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailPhoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    
    //MARK: - Navigator
    
    //MARK: - Dependencies
    
    //MARK: = Properties
    
    //MARK: - Buckets
    
    //MARK: - Navigation Items
    
    //MARK: - Configures
    
    //MARK: - Layout
    
    //MARK: - Interaction
    

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
        let success = signup.requestSignup()
        if success {
            //Signup successful
        } else {
            //Error
        }
     }
}
 
