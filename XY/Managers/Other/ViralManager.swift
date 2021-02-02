//
//  ViralManager.swift
//  XY
//
//  Created by Maxime Franchot on 02/02/2021.
//

import Foundation
import UIKit
import AVFoundation
import Firebase

final class ViralManager {
    static let shared = ViralManager()
    private init() { }
    
    
    enum CreateViralError: Error {
        case errorGeneratingThumbnail
    }
    
    public func createViral(caption: String, videoUrl: URL, completion: @escaping(Result<ViralModel, Error>) -> Void) {
        // Create document
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let viralDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.virals).document()
        
        generateVideoThumbnail(url: videoUrl) { (thumbnail) in
            guard let thumbnail = thumbnail else {
                completion(.failure(CreateViralError.errorGeneratingThumbnail))
                return
            }
            
            StorageManager.shared.uploadVideo(from: videoUrl, withThumbnail: thumbnail, withContainer: viralDocument.documentID) { result in
                switch result {
                case .success(let videoId):
                    // upload viral document
                    self.uploadViralDocument(caption: caption, uploadedVideoPath: videoUrl) { (result) in
                        switch result {
                        case .success(let viralModel):
                            completion(.success(viralModel))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func generateVideoThumbnail(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    // MARK: - Private functions
    
    private func uploadViralDocument(caption: String, uploadedVideoPath: String, completion: @escaping(Result<ViralModel, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        FirebaseDownload.getProfileId(userId: userId) { (profileId, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let profileId = profileId {
                let viralData: [String: Any] = [
                    FirebaseKeys.ViralKeys.videoRef: uploadedVideoPath,
                    FirebaseKeys.ViralKeys.profileId: profileId,
                    FirebaseKeys.ViralKeys.caption: caption,
                    FirebaseKeys.ViralKeys.livesLeft: XPModel.LIVES[.viral]![0],
                    FirebaseKeys.ViralKeys.xp: 0,
                    FirebaseKeys.ViralKeys.level: 0
                ]
                
                let viralDocument = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.virals).document()
                viralDocument.setData(viralData) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    }
                    let viralModel = ViralModel.init(from: viralData, id: viralDocument.documentID)
                    completion(.success(viralModel))
                }
            }
        }
    }
}
