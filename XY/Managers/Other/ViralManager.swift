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
    
    // MARK: - Public functions
    
    public func createViral(caption: String, videoUrl: URL, completion: @escaping(Result<ViralModel, Error>) -> Void) {
        // Create document
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
                    self.createViralData(caption: caption, uploadedVideoPath: videoId) { viralData, error in
                        if let error = error {
                            completion(.failure(error))
                        } else if let viralData = viralData {
                            
                            viralDocument.setData(viralData, merge: false) { (error) in
                                if let error = error {
                                    completion(.failure(error))
                                }
                            }
                            
                            let viralModel = ViralModel(from: viralData, id: viralDocument.documentID)
                            completion(.success(viralModel))
                            
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func getViral(forId viralId: String, completion: @escaping (Result<ViralModel, Error>) -> Void) {
        let document = FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.virals).document(viralId)
        
        document.getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot, let data = snapshot.data() {
                let viralModel = ViralModel.init(from: data, id: document.documentID)
                
                completion(.success(viralModel))
            }
        }
    }
    
    public func deleteViral(withId viralId: String, completion: @escaping (Error?) -> Void) {
        // Delete viral from firestore
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.virals).document(viralId).delete { (error) in
            if let error = error {
                completion(error)
            } else {
                StorageManager.shared.deleteContainer(withPath: viralId) { error in
                    if let error = error {
                        completion(error)
                    }
                }
            }
        }
    }
    
    // MARK: - Private functions
    
    private func generateVideoThumbnail(url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
        let asset = AVAsset(url: url) //2
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
        avAssetImageGenerator.appliesPreferredTrackTransform = true //4
        let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
            let thumbImage = UIImage(cgImage: cgThumbImage) //7
            completion(thumbImage) //9
        } catch {
            print(error.localizedDescription) //10
            completion(nil) //11
        }
        
    }
    
    private func createViralData(caption: String, uploadedVideoPath: String, completion: @escaping([String : Any]?, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        FirebaseDownload.getProfileId(userId: userId) { (profileId, error) in
            if let error = error {
                completion(nil, error)
            }
            if let profileId = profileId {
                let viralData: [String: Any] = [
                    FirebaseKeys.ViralKeys.videoRef: uploadedVideoPath,
                    FirebaseKeys.ViralKeys.profileId: profileId,
                    FirebaseKeys.ViralKeys.caption: caption,
                    FirebaseKeys.ViralKeys.livesLeft: XPModelManager.shared.getLivesLeftForLevel(0),
                    FirebaseKeys.ViralKeys.xp: 0,
                    FirebaseKeys.ViralKeys.level: 0
                ]
                
                completion(viralData, nil)
            }
        }
    }
}