//
//  LoginViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameEmailPhoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginFailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    
    
    //MARK: - Navigator
    
    //MARK: - Dependencies
    
    //MARK: = Properties
    
    //MARK: - Buckets
    
    //MARK: - Navigation Items
    
    //MARK: - Configures
    
    //MARK: - Layout
    
    //MARK: - Interaction
    

    @IBAction func loginButton(_ sender: Any)  {
        // Get data from textfields
        let usernameEmailPhoneText = usernameEmailPhoneTextField.text
        let passwordText = passwordTextField.text
        
        // Checks on login data
        var login = Login() // Create Login Model
        login.validateLoginForm(username: usernameEmailPhoneText!, password: passwordText!, rememberMe: true)
        
        // Send login request
        var success = login.requestLogin { result in
            switch result {
            case .success(let message):
                print("Login Success: ", message)
                // Segue to home screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "HomeViewController")
                self.show(secondVC, sender: self)

            case .failure(let error):
                print("Login failure: ", error)
                self.loginFailLabel.isHidden = false
            }
        }
     }
}
 
