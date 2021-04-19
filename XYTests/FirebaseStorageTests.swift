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
    var videoPathString = "Tests/testVideo.mov"
    var imagePathString = "Tests/testImage.png"
    
    override func setUpWithError() throws {
        
        
        videoUrl = Bundle.main.url(forResource: "video3", withExtension: "mov")
    }

    override func tearDownWithError() throws {
        
        
    }

    func testVideoStorageTasks() throws {
        print("Begin upload video test")
        let uploadExpectation = XCTestExpectation(description: "Upload video file")
        
        // Upload
        
        FirebaseStorageManager.shared.uploadVideoToStorage(
            videoFileUrl: videoUrl,
            storagePath: videoPathString,
            onProgress: { progress in
            print("Progress uploading video: \(progress)")
            
        }, onComplete: { result in
            defer {
                uploadExpectation.fulfill()
            }
            
            switch result {
            case .success():
                break
            case .failure(let error):
                print("Finished upload task with failure")
                
                XCTFail(error.localizedDescription)
            }
        })
        
        wait(for: [uploadExpectation], timeout: 100)
        
        // Download
        
        let downloadExpectation = XCTestExpectation(description: "Download video file")

        print("Begin download video test")
        
        FirebaseStorageManager.shared.getVideoDownloadUrl(from: videoPathString) { (result) in
            defer {
                downloadExpectation.fulfill()
            }
            
            switch result {
            case .success(let url):
                print("Download link for url: \(url.absoluteString)")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [downloadExpectation], timeout: 10)
        
        // Delete
        
        FirebaseStorageManager.shared.deleteFile(with: videoPathString)
    }
    
    func testUploadImageTask() throws {
        print("Begin upload image test")
        let uploadExpectation = XCTestExpectation(description: "Upload video file")
        
        FirebaseStorageManager.shared.uploadImageToStorage(
            imageData: UIImage(named: "testImage")!.pngData()!,
            storagePath: imagePathString) { (progress) in
            print("Progress uploading image: \(progress)")
        } onComplete: { (result) in
            defer {
                uploadExpectation.fulfill()
            }
            
            switch result {
            case .success():
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [uploadExpectation], timeout: 5000)
        
        // Download
        
        print("Begin download image test")
        let downloadExpectation = XCTestExpectation(description: "Upload video file")
        
        FirebaseStorageManager.shared.downloadImage(from: imagePathString) { (progress) in
            print("Progress downloading image: \(progress)")
        } completion: { (result) in
            defer {
                downloadExpectation.fulfill()
            }
            
            switch result {
            case .success(let data):
                XCTAssertEqual(data, UIImage(named: "testImage")!.pngData()!)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [downloadExpectation], timeout: 5000)
        
        // Delete
        
        FirebaseStorageManager.shared.deleteFile(with: imagePathString)
    }
}
