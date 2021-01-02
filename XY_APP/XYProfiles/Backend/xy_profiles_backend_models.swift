//
//  xy_profile_backend_models.swift
//  XY_APP
//
//  Created by Maxime Franchot on 02/01/2021.
//

import Foundation

// MARK: - Login / Signup

struct xy_profiles_backend_models_loginRequest {
    let username: String?
    let email: String?
    let phoneNumber: String?
    let password: String?
}

struct xy_profiles_backend_models_signupRequest {
    let username: String?
    let email: String?
    let phoneNumber: String?
    let password: String?
}

// MARK: - Session Request / Response

struct xy_profiles_backend_models_beginSessionRequest {
    let auth_token: String
}

struct xy_profiles_backend_models_beginSessionResponse {
    let session_token: String
}
