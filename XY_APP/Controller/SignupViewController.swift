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
        signup.requestSignup()
     }
    
    func verifyLoginButtonPressed(_ sender: Any) {
        guard let url = URL(string: API.url + "/verifyLogin") else { return }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.httpMethod = "GET"
        loginRequest.setValue(API.getSessionToken(), forHTTPHeaderField: "session")
        
        do {
            URLSession.shared.dataTask(with: loginRequest) { (data, resp, err) in
                if ((err) != nil) {
                    print("Error validating: ", err)
                    return
                }
                let urlContent = NSString(data: data.unsafelyUnwrapped, encoding: String.Encoding.ascii.rawValue)
                 
                print(urlContent)
            }.resume()
        } catch {
            print("big fail")
        }
    }
}
 
