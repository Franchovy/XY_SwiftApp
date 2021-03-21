//
//  RankingFirestoreManager.swift
//  XY
//
//  Created by Maxime Franchot on 03/03/2021.
//

import Foundation
import FirebaseDatabase

class RankingDatabaseManager {
    static var shared = RankingDatabaseManager()
    
    
    var handle: UInt?
    
    func getRanking(completion: @escaping(RankingModel) -> Void) {
        let rankingRef = Database.database().reference().child("Rankings").child("Global")
        
        handle = rankingRef.observe(DataEventType.value, with: { (snapshot) in
            
            if let newValues = snapshot.value as? [[String: Any]?] {
                var rankingCells = [RankingCellModel]()
                
                for (index, value) in newValues.enumerated() {
                    guard value != nil else {
                        continue
                    }
                    
                    let rank = index
                    let profileID = value!["profileID"] as! String
                    let score = value!["score"] as! Int
                    
                    rankingCells.append(RankingCellModel(rank: rank, profileID: profileID, score: score))
                }
                
                let rankingModel = RankingModel(name: "Global", ranking: rankingCells)
                print(rankingModel)
                
                completion(rankingModel)
            }
        })
    }
    
    func removeHandle() {
        guard let handle = handle else {
            return
        }
        
        let rankingRef = Database.database().reference().child("Rankings").child("Global")
        
        rankingRef.removeObserver(withHandle: handle)
        self.handle = nil
    }
}
