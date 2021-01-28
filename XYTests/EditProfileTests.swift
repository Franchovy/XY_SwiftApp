//
//  EditProfileTests.swift
//  XY_APPTests
//
//  Created by Maxime Franchot on 07/01/2021.
//

import XCTest

import FirebaseAuth
import Firebase

@testable import XY_APP

class EditProfileTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let expectation = self.expectation(description: "Test setup: Login")
        
        Auth.auth().signIn(withEmail: "test@gmail.com", password: "password") { result, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            
            print("Successfully logged into Test account")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    override func tearDownWithError() throws {
        
        
        
        
        try Auth.auth().signOut()
    }
    
    func getProfile() throws {
        let expectation = self.expectation(description: "Test: Get Profile")
        
        FirebaseDownload.getProfile(userId: Auth.auth().currentUser!.uid) {_, profileData, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            if let profileData = profileData {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func editProfile() throws {
        let expectation = self.expectation(description: "Test: Edit Profile")
        
        let changedData = ProfileModel(
            xyname: "test", imageId: "", website: "test.com", followers: 1, following: 1, xp: 1, level: 1, caption: "Test Caption")
        FirebaseUpload.editProfileInfo(profileData: changedData) { result in
            switch result {
            case .success():
                expectation.fulfill()
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
