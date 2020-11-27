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
    

    @IBAction func signupButton(_ sender: Any)  {
        // Get data from textfields
        let usernameEmailPhoneText = usernameEmailPhoneTextField.text
        let passwordText = passwordTextField.text
        
        // Checks on login data
        
        // Send Signup to url
        let postRequest = LoginRequest()
        let message = Message(message: "username=\(usernameEmailPhoneText!)&password=\(passwordText!)")
        print(message.message)

         postRequest.getAPIRequest().save(message: message, completion: { result in
               switch result {
               case .success(let message):
                print("POST request response: \"" + message.message + "\"")
               let sessionToken = message.token ?? ""
               print(sessionToken)
               API.setSessionToken(newSessionToken: sessionToken)
             case .failure(let error):
                  print("An error occured: \(error)")
            }
         })
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
 
