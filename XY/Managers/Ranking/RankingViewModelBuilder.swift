//
//  RankingViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 03/03/2021.
//

import UIKit

fileprivate enum RankingFetchTask {
    case waiting(userProfileID: RankingID)
    case fetchingProfile
    case fetchingProfileImage
    case complete
    case error
}

fileprivate enum RankingFetchResult {
    case profileDataFetched(data: ProfileModel)
    case profileImageFetched(image: UIImage)
}

final class RankingViewModelBuilder {
    
    public func build(model: RankingModel, callback: @escaping(RankingViewModel?, Error?) -> Void) {
        // Dispatch Profile Data Fetch tasks
        let dispatchGroup1 = DispatchGroup()
        
        var cellViewModels = [RankingCellViewModel?](repeating: nil, count: model.rankedUserIDs.count)
        var profileImageIDs = [String?](repeating: nil, count: model.rankedUserIDs.count)
        
        model.rankedUserIDs.enumerated().forEach { (index, rankingIDs) in
            dispatchGroup1.enter()
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            dispatchGroup.enter()
            
            var name: String?
            var level: Int?
            var xp: Int?
            
            ProfileFirestoreManager.shared.getProfile(forProfileID: rankingIDs.profileID) { (profileModel) in
                defer {
                    dispatchGroup.leave()
                }
                if let profileModel = profileModel {
                    name = profileModel.nickname
                    profileImageIDs[index] = profileModel.profileImageId
                }
            }
            UserFirestoreManager.shared.getUser(with: rankingIDs.userID) { (result) in
                defer {
                    dispatchGroup.leave()
                }
                switch result {
                case .success(let userModel):
                    level = userModel.level
                    xp = userModel.xp
                case .failure(let error):
                    print(error)
                }
            }
            
            dispatchGroup.notify(queue: .global(qos: .background), work: DispatchWorkItem(block: {
                defer {
                    dispatchGroup1.leave()
                }
                
                guard let name = name, let level = level, let xp = xp else { return }
                
                cellViewModels[index] = RankingCellViewModel(
                    userID: rankingIDs.userID,
                    image: nil,
                    name: name,
                    rank: index + 1,
                    level: level,
                    xp: xp
                )
            }))
        }
        
        dispatchGroup1.notify(queue: .main, work: DispatchWorkItem(block: {
            // Initial images-not-loaded callback
            var rankingViewModel = RankingViewModel(name: model.name, cells: cellViewModels.flatMap { $0 } )
            
            callback(rankingViewModel, nil)
            
            // Dispatch Profile Image Fetch tasks
            let semaphore = DispatchSemaphore(value: 1)
            
            cellViewModels.enumerated().forEach { (index, rankingCellViewModel) in
//                semaphore.wait()

                guard let imageID = profileImageIDs[index] else {
                    print("Found Null image ID Fetching ranking images")
                    return
                }
                
                let downloadTask = StorageManager.shared.downloadImage(withImageId: imageID) { (image, error) in
                    defer {
                        semaphore.signal()
                    }
                    if let error = error {
                        print(error)
                    } else if let image = image {
                        rankingViewModel.cells[index].image = image
                        
                        DispatchQueue.main.async {
                            callback(rankingViewModel, nil)
                        }
                    }
                }
                downloadTask.observe(.progress) { (snapshot) in
//                    print("Download progress: \(snapshot.progress)")
                }
            }
        }))
    }
}
