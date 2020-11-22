//
//  ViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 17/11/2020.
//

import UIKit

let API_URL = "192.168.43.155"

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
    
    @IBAction func loginRequestButton(_ sender: Any) {
        guard let url = URL(string: API_URL + "/get") else { return }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.httpMethod = "POST"
        
        do {
            let params = ["emailaddress": "maxrofra@gmail.com", "password": "secretWord"]
            loginRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
            
            URLSession.shared.dataTask(with: url) { (data, resp, err) in
                if let err = err {
                    print("Failed to login:", err)
                    return
                }
                
                print("Probably logged in successfully")
            }.resume()
        } catch {
            print("Failed to serialize data:", error)
        }
    }
    
    @IBAction func postRequestButton(_ sender: UIButton) {
        let url = URL(string:  API_URL + "/post")!
        _ = URLRequest(url: url)
        
        
    }
}

