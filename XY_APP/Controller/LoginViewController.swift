//
//  LoginViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit

class LoginViewController: UIViewController {
            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBOutlet weak var usernameEmailPhoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    
    
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
        login.validateLogin(username: usernameEmailPhoneText!, password: passwordText!, rememberMe: true)
        
        // Send login request
        login.requestLogin()
        //IF success -> next page
        //IF fail -> display fail
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
 
