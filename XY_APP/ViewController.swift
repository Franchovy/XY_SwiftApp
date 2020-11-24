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
                
                let message = LoginRequestMessage(username: "maxime", password: "secretword")
                //let message = Message(message: "this is a message")
                
                let postRequest = APIRequest(apiUrl: API_URL, endpoint: "login")
                
                postRequest.save(message, completion: { result in
                    switch result {
                    case .success(let message):
                        print("POST request response: \"" + message.message)
                    case .failure(let error):
                        print("An error occured: \(error)")
                    }
                })
            }.resume()
        } catch {
            print("Error bruh")
        }
    }
}


class DebuggerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
     
    }
    
    @IBAction func CheckLoginButtonPressed(_ sender: Any) {
        // Check if login session is open.
        
        // Send Request to url
        guard let url = URL(string: API_URL + "/auth") else { return }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.httpMethod = "GET"
        
        do {
            URLSession.shared.dataTask(with: url) { (data, resp, err) in
                if let err = err {
                    print("Failed to get login session:", err)
                    return
                }
                
                if let data = data,
                        let urlContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue) {
                        print(urlContent)
                    
                        print("Probably has login session.")
                    } else {
                        print("Error: \(err)")
                    }
            }.resume()
        } catch {
            print("Failed to serialize data:", error)
        }
    }
    @IBAction func CheckCSRFButtonPressed(_ sender: Any) {
        // Get CSRF Token
        guard let url = URL(string: API_URL + "/csrf") else { return }
        
        var csrfRequest = URLRequest(url: url)
        csrfRequest.httpMethod = "GET"
        
        do {
            URLSession.shared.dataTask(with: csrfRequest) { (data, resp, err) in
                if let err = err {
                    print("Failed to login:", err)
                    return
                }
                print(resp)
                // Check login session authenticated.
                if let data = data,
                        let urlContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue) {
                        print(urlContent)
                    } else {
                        print("Error: \(err)")
                    }
            }.resume()
        } catch {
            print("Failed to serialize data:", error)
        }
    }
    
}
