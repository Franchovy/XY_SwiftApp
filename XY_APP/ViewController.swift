//
//  ViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 17/11/2020.
//

import UIKit

let API_URL = "http://0.0.0.0:5000"
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
    
    

    @IBAction func LoginButtonPressed(_ sender: Any) {
        // Send Signup to url
        guard let url = URL(string: API_URL + "/login") else { return }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.httpMethod = "GET"
        
        do {
            URLSession.shared.dataTask(with: loginRequest) { (data, resp, err) in
                
                let message = try! LoginRequestMessage(username: "maxime", password: "secretword")
                let response = Message(message: "")
                let postRequest = try! APIRequest(apiUrl: API_URL, endpoint: "login", httpMethod: "POST") // Todo: Change this to LoginRequest
                
                postRequest.save(message, requestResponse: response, completion: { result in
                    switch result {
                    case .success(let message):
                        print("POST request response: \"" + message.message + "\"")
                        let sessionToken = message.token ?? ""
                        print(sessionToken)
                        APIRequest.setSessionToken(newSessionToken: sessionToken)
                    case .failure(let error):
                        print("An error occured: \(error)")
                    }
                })
            }.resume()
        } catch {
            print("Error bruh")
        }
    }
    
    @IBAction func verifyLoginButtonPressed(_ sender: Any) {
        guard let url = URL(string: API_URL + "/verifyLogin") else { return }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.httpMethod = "GET"
        loginRequest.setValue(APIRequest.sessionToken, forHTTPHeaderField: "session")
        
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
