//
//  LoginViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameEmailPhoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginFailLabel: UILabel!
    @IBOutlet weak var loginGradientView: UIView!

    
    override func viewDidLoad() {
        loginButton.layer.cornerRadius = 8
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.cornerRadius = 8
        loginGradientView.layer.cornerRadius = 20
        
        
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround() 
        // Do any additional setup after loading the view.
    }


    
    @IBAction func loginButton(_ sender: Any)  {
        // Get data from textfields
        let usernameEmailPhoneText = usernameEmailPhoneTextField.text
        let passwordText = passwordTextField.text
        
        // DEBUG - FAKE LOGIN
        if (usernameEmailPhoneText == "" && passwordText == "") {
            navigateToNextScreen()
        }
        
        // Checks on login data
        Auth.shared.requestLogin(username: usernameEmailPhoneText!, password: passwordText!, rememberMe: true, completion: { result in
            switch result {
            case .success(let message):
                print("Login Success: ", message)
                // Segue to home screen
                DispatchQueue.main.async {
                    self.navigateToNextScreen()
                }
            case .failure(let error):
                print("Login failure: ", error)
                
                DispatchQueue.main.async {
                self.loginFailLabel.isHidden = false
                }
            }
        })
     }
    
    func navigateToNextScreen() {
        if #available(iOS 13.0, *) {
            // IOS 13 or above
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "MainViewController")
            self.show(secondVC, sender: self)
        } else {
            // IOS 12
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! UITabBarController
            //self.navigationController?.pushViewController(vc, animated: true)
            self.show(vc, sender: self)
        }
    }

}
