//
//  FirebaseStorageTests.swift
//  XYTests
//
//  Created by Maxime Franchot on 16/04/2021.
//

import XCTest
@testable import XY

class FirebaseStorageTests: XCTestCase {

    var videoUrl: URL!
    var uploadedFilePath: String?
    
    override func setUpWithError() throws {
        videoUrl = Bundle.main.url(forResource: "video3", withExtension: "mov")
    }

    override func tearDownWithError() throws {
        if let uploadedFilePath = uploadedFilePath {
            FirebaseStorageManager.shared.deleteFile(with: uploadedFilePath)
        }
    }

    func testUploadStorageTask() throws {
        print("Begin upload tast")
        let expectation = XCTestExpectation(description: "Upload video file")
        
        FirebaseStorageManager.shared.uploadVideoToStorage(videoFileUrl: videoUrl, onProgress: { progress in
            print("Progress uploading: \(progress)")
            
        }, onComplete: { result in
            defer {
                expectation.fulfill()
            }
            
            switch result {
            case .success(let path):
                print("Finished upload task with success. Filepath: \(path)")
                
                XCTAssert(path.contains("/"))
                XCTAssert(path.contains(".mov"))
                
                self.uploadedFilePath = path
            case .failure(let error):
                print("Finished upload task with failure")
                
                XCTFail(error.localizedDescription)
            }
        })
        
        wait(for: [expectation], timeout: 5000)
    }

    func testPerformanceExample() throws {
        
        self.measure {
            
        }
    }

}
