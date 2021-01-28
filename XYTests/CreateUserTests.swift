//
//  CreateUserTests.swift
//  XY_APPTests
//
//  Created by Maxime Franchot on 07/01/2021.
//

import XCTest

import FirebaseAuth
import Firebase

@testable import XY_APP

class CreateUserTests: XCTestCase {
    
    let testUsername = "tester"
    let testEmail = "tester@testmail.com"
    var userId: String?

    override func setUpWithError() throws {
        let expectation = self.expectation(description: "Test setup: Create User")
        
        CreateXYUserService.createUser(xyname: testUsername, email: testEmail, phoneNumber: nil, password: "aaaaaaaa") { result in
            switch result {
            case .success(let userId):
                print("Successfully created Test account with Id: \(userId)")
                self.userId = userId
                expectation.fulfill()
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    override func tearDownWithError() throws {
        let expectation = self.expectation(description: "Test teardown: Delete User")
        
        // TODO: Delete "tester" profile
        // TODO: Delete "tester" user
        
        Auth.auth().currentUser!.delete() { error in
            if let error = error {
                fatalError("Error deleting account! \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
    }

    func testExample() throws {
        let expectation = self.expectation(description: "Test: Verify created User")
        
        let userDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId!)
        
        userDocument.getDocument() { snapshot, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            expectation.fulfill()
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
