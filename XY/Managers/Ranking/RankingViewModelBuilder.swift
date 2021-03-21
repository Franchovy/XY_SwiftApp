//
//  RankingViewModelBuilder.swift
//  XY
//
//  Created by Maxime Franchot on 03/03/2021.
//

import UIKit

final class RankingViewModelBuilder {
    
    static func build(model: RankingModel, count: Int, callback: @escaping(RankingViewModel?, Error?) -> Void) {
        // Dispatch Profile Data Fetch tasks
        let dispatchGroup = DispatchGroup()
        
        var cellViewModels = [(NewProfileViewModel, Int)?](repeating: nil, count: count)
        
        model.ranking[0...count-1].forEach { (rankingCell) in
            
            var name: String?
            var level: Int?
            var xp: Int?
            
            dispatchGroup.enter()
            ProfileFirestoreManager.shared.getProfile(forProfileID: rankingCell.profileID) { (profileModel) in
                defer {
                    dispatchGroup.leave()
                }
                if let profileModel = profileModel {
                    dispatchGroup.enter()
                    ProfileViewModelBuilder.build(with: profileModel) { (newProfileViewModel) in
                        defer {
                            dispatchGroup.leave()
                        }
                        if let newProfileViewModel = newProfileViewModel {
                            print(rankingCell.rank)
                            cellViewModels[rankingCell.rank-1] = (newProfileViewModel, rankingCell.score)
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main, work: DispatchWorkItem(block: {
            // Initial images-not-loaded callback
            var rankingViewModel = RankingViewModel(name: model.name, cells: cellViewModels.flatMap { $0 } )
            
            callback(rankingViewModel, nil)
        }))
    }
}
