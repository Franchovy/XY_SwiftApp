//
//  SignupRequest.swift
//  XY_APP
//
//  Created by Maxime Franchot on 25/11/2020.
//

import Foundation

struct SignupRequest {
    let apiRequest: APIRequest
    
    init() {
        apiRequest = APIRequest(endpoint: "register", httpMethod: "POST")
    }
    
    func getAPIRequest() -> APIRequest {
        return apiRequest
    }
}
