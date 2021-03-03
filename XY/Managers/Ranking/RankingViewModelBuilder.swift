//
//  RankingViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 03/03/2021.
//

import UIKit

fileprivate enum RankingFetchTask {
    case waiting(userID: String)
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
        // Load Tasks
        
        var tasks = [RankingFetchTask]()
        
        model.rankedUserIDs.forEach { (userID) in
            tasks.append(RankingFetchTask.waiting(userID: userID))
        }
        
        // Dispatch Profile Data Fetch tasks
        
        let dispatchGroup1 = DispatchGroup()
        
        tasks.forEach { (fetchTask) in
            dispatchGroup1.enter()
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now()+0.2) {
                // Fetch op
                print("Fetched Profile Data!")
                
                dispatchGroup1.leave()
            }
        }
        
        dispatchGroup1.notify(queue: .global(qos: .default), work: DispatchWorkItem(block: {
            callback(nil, nil)
            
            // Dispatch Profile Image Fetch tasks
            let dispatchGroup2 = DispatchGroup()
            let semaphore = DispatchSemaphore(value: 1)
            
            tasks.forEach { (fetchTask) in
                dispatchGroup2.enter()
                semaphore.wait()
                
                DispatchQueue.global(qos: .default).asyncAfter(deadline: .now()+0.7) {
                    // Fetch op
                    print("Fetched profile Image!")
                    callback(nil, nil)
                    
                    semaphore.signal()
                    dispatchGroup2.leave()
                }
            }
        }))
    }
}
