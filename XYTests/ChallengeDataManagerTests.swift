//
//  ChallengeDataManagerTests.swift
//  XYTests
//
//  Created by Maxime Franchot on 17/04/2021.
//

import XCTest
@testable import XY

class ChallengeDataManagerTests: XCTestCase {

    var challengeModel: ChallengeDataModel!
    
    override func setUpWithError() throws {
        let context = CoreDataManager.shared.mainContext
        let entity = ChallengeDataModel.entity()
        let userEntity = UserDataModel.entity()
        
        challengeModel = ChallengeDataModel(entity: entity, insertInto: context)
        
        let creatorUser = UserDataModel(entity: userEntity, insertInto: context)
        let sentToUsers = [
            UserDataModel(entity: userEntity, insertInto: context),
            UserDataModel(entity: userEntity, insertInto: context),
            UserDataModel(entity: userEntity, insertInto: context)
        ]
        creatorUser.firebaseID = "ID-X"
        sentToUsers.enumerated().forEach({ model in
            model.element.firebaseID = "ID-\(model.offset)"
            model.element.friendStatus = .none
            model.element.nickname = "nickname-\(model.offset)"
            model.element.numChallenges = 0
            model.element.numFriends = 0
        })
        
        ProfileDataManager.shared.ownProfileModel = creatorUser
        
        challengeModel.fromUser = creatorUser
        challengeModel.title = "title"
        challengeModel.challengeDescription = "description"
        challengeModel.fileUrl = Bundle.main.url(forResource: "video3", withExtension: "mov")
        challengeModel.addToSentTo(NSSet(array: sentToUsers))
        challengeModel.previewImage = UIImage(named: "challenge1")!.pngData()
        
    }

    override func tearDownWithError() throws {
        let context = CoreDataManager.shared.mainContext
        context.rollback()
    }
    
    func testUploadChallenge() throws {
        ChallengeDataManager.shared.uploadChallenge(challenge: challengeModel)
    }

}
