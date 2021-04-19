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
        challengeModel.firebaseID = "xxx"
        challengeModel.firebaseVideoID = "xxx"
        challengeModel.fromUser = fromUserModel
        challengeModel.addToSentTo(NSSet(array: userModels))
        
    }

    override func tearDownWithError() throws {
        let context = CoreDataManager.shared.mainContext
        context.rollback()
    }

    func testFirebaseModelCreator() throws {
        let data = FirebaseFirestoreManager.shared.convertChallengeToDocument(model: challengeModel)
        XCTAssertNotNil(data)
        
        XCTAssert(data!["title"] as! String == "title")
        XCTAssert(data!["description"] as! String == "description")
        XCTAssertNotNil(data?["timestamp"] as? Timestamp)
        XCTAssert(data!["memberIDs"] as! [String] == ["ID-0", "ID-1", "ID-2"])
        XCTAssert(data!["creatorID"] as! String == "ID-X")
        
    }
    
    func testFirebaseFetchChallengeDocuments() throws {
        let expectation = XCTestExpectation()
        
        FirebaseFirestoreManager.shared.fetchChallengeDocumentsFromFirestore() { result in
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
        
    }
    
    func testFetchProfile() throws {
        
    }

    func testPerformanceExample() throws {
        self.measure {
            
        }
    }

}
