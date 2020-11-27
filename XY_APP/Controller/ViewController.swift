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

class ViewController: UIViewController {
            
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
    
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        print("sent: \(sender.text)")
    }
    
    @IBAction func signupButton(_ sender: Any)  {
        // Get data from textfields
                
        // Send Signup to url
        struct Profile {
        var name : String
        var response : [String:Int]
        var message : [String : Int]
        
            
            init(profileName : String, answer : [String:Int], xymessage : [String : Int]) {
            
            self.name = profileName
            self.response = answer
            self.message = xymessage
         }
            
           // func postRequest.getAPIRequest(){
                    //print()
              // }
            
            
            
        
       //  postRequest.getAPIRequest().save(message: message, completion: { result in
            //   switch result {
            //   case .success(let message):
            //    print("POST request response: \"" + message.message + "\"")
            //   let sessionToken = message.token ?? ""
            //   print(sessionToken)
            //   API.setSessionToken(newSessionToken: sessionToken)
            // case .failure(let error):
            //      print("An error occured: \(error)")
            //   }
            // })
            // }
    
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
    }
}
