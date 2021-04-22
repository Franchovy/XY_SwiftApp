//
//  FirestoreManagerTests.swift
//  XYTests
//
//  Created by Maxime Franchot on 17/04/2021.
//

import XCTest


import FirebaseFirestore
@testable import XY

class FirestoreManagerTests: XCTestCase {

    var challengeModel: ChallengeDataModel!
    var userModels: [UserDataModel]!
    
    override func setUpWithError() throws {
        let context = CoreDataManager.shared.mainContext
        let entity = ChallengeDataModel.entity()
        
        challengeModel = ChallengeDataModel(entity: entity, insertInto: context)
        
        let userEntity = UserDataModel.entity()
        userModels = [
            UserDataModel(entity: userEntity, insertInto: context),
            UserDataModel(entity: userEntity, insertInto: context),
            UserDataModel(entity: userEntity, insertInto: context)
        ]
        
        userModels.enumerated().forEach({ $0.element.firebaseID = "ID-\($0.offset)" })
        let fromUserModel = UserDataModel(entity: userEntity, insertInto: context)
        fromUserModel.firebaseID = "ID-1"
        
        ProfileDataManager.shared.ownProfileModel = fromUserModel
        
        challengeModel.title = "title"
        challengeModel.challengeDescription = "description"
        challengeModel.firebaseID = "test"
        challengeModel.firebaseVideoID = "xxx"
        challengeModel.fromUser = fromUserModel
        challengeModel.addToSentTo(NSSet(array: userModels))
        
    }

    override func tearDownWithError() throws {
        let context = CoreDataManager.shared.mainContext
        context.rollback()
    }
    
    func testFirebaseFetchChallengeDocuments() throws {
        let expectation = XCTestExpectation()
        
        FirebaseFirestoreManager.shared.listenForNewChallenges() { result in
            defer {
                expectation.fulfill()
            }
            switch result {
            case .success(let models):
                print("Fetched challenge documents: \(models)")
                XCTAssertNotNil(models)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testCreateProfile() throws {
        let expectation = XCTestExpectation()
        
        FirebaseFirestoreManager.shared.createProfile(userDataModel: ProfileDataManager.shared.ownProfileModel) { (error) in
            defer {
                expectation.fulfill()
            }
            XCTAssertNil(error)
        }
        
        wait(for: [expectation], timeout: 10)
    }
    func testFetchProfile() throws {
        let expectation = XCTestExpectation()
        FirebaseFirestoreManager.shared.fetchProfile(for: ProfileDataManager.shared.ownID) { (result) in
            defer {
                expectation.fulfill()
            }
            switch result {
            case .success(let userModel):
                XCTAssertNotNil(userModel.nickname)
                XCTAssertEqual(userModel.numFriends, 0)
                XCTAssertEqual(userModel.numChallenges, 0)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testSetProfileNickname() throws {
        let expectation = XCTestExpectation()
        
        FirebaseFirestoreManager.shared.setProfileData(nickname: "Testing") { error in
            defer {
                expectation.fulfill()
            }
            XCTAssertNotNil(error)
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func deleteTestProfile() throws {
        let expectation = XCTestExpectation()
        
        let ownID = ProfileDataManager.shared.ownID
        assert(ownID == "ID-1")
        
        FirebaseFirestoreManager.shared.deleteOwnProfile(idForVerificationPurposes: ownID) { (error) in
            defer {
                expectation.fulfill()
            }
            XCTAssertNotNil(error)
        }
        
        wait(for: [expectation], timeout: 10)
    }
}
