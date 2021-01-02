//
//  ProfileTests.swift
//  XY_APPTests
//
//  Created by Maxime Franchot on 28/12/2020.
//

import XCTest
@testable import XY_APP


class ProfileTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

    }

    func testEditProfileAPI() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testChangePassword() throws {
        
        Profile.shared.changePassword(oldPassword: "test", newPassword: "test")
        
        let auth = Auth()
        auth.logout(completion: { error in
            if error != nil {
                fatalError("\(error)")
            } else {
                auth.requestLogin(username: Session.shared.username, password: "test", rememberMe: false, completion: { result in
                    switch result {
                    case .success():
                        XCTAssert(true)
                    case .failure(let error):
                        fatalError("\(error)")
                    }
                    
                })
            }
        })
        
        
    }

}
