//
//  LoginRequest.swift
//  XY_APP
//
//  Created by Maxime Franchot on 24/11/2020.
//

import Foundation


struct LoginRequest {
    let apiRequest: APIRequest
    
    init() {
        apiRequest = APIRequest(endpoint: "login", httpMethod: "POST")
    }
    
    func getAPIRequest() -> APIRequest {
        return apiRequest
    }
}
