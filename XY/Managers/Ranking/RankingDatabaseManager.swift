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
    
    func getRank(for profileID: String, completion: @escaping(Int?) -> Void) {
        
        let rankingRef = Database.database().reference().child("Rankings").child("Global")
        
        rankingRef.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [[String: Any]?] {
                if let index = value.firstIndex(where: {$0?["profileID"] as? String == profileID}) {
                    completion(index)
                } else {
                    completion(nil)
                }
            }
        }
        
    }
    
    func getRanking(completion: @escaping(RankingModel) -> Void, onChange: @escaping(RankingCellModel) -> Void, onAdd: @escaping(RankingCellModel) -> Void) {
        let rankingRef = Database.database().reference().child("Rankings").child("Global")
        
        rankingRef.observeSingleEvent(of: .value) { (snapshot) in
            
            // Return original ranking model
            if let values = snapshot.value as? [[String: Any]?] {
                let cells = self.buildRanking(from: values)
                
                let rankingModel = RankingModel(name: "Global", ranking: cells)
                
                completion(rankingModel)
            }
            
            rankingRef.observe(.childChanged) { (snapshot) in
                if let value = snapshot.value as? [String: Any] {
                    let cell = self.buildRankingCell(from: value, rank: Int(snapshot.key)!)
                    if let cell = cell {
                        onChange(cell)
                    }
                }
            }
            
            rankingRef.observe(.childAdded) { (snapshot) in
                if let value = snapshot.value as? [String: Any] {
                    let cell = self.buildRankingCell(from: value, rank: Int(snapshot.key)!)
                    if let cell = cell {
                        onAdd(cell)
                    }
                }
            }
        }
    }
    
    private func buildRanking(from data: [[String: Any]?]) -> [RankingCellModel] {
        var rankingCells = [RankingCellModel]()
        
        for (index, value) in data.enumerated() {
            guard value != nil else {
                continue
            }
            
            let rank = index
            if let profileID = value?["profileID"] as? String,
               let score = value!["score"] as? Int {
            
                rankingCells.append(RankingCellModel(rank: rank, profileID: profileID, score: score))
            }
        }
        
        return rankingCells
    }
    
    private func buildRankingCell(from data: [String: Any], rank: Int) -> RankingCellModel? {
        
        if let profileID = data["profileID"] as? String,
           let score = data["score"] as? Int {
        
            return RankingCellModel(rank: rank, profileID: profileID, score: score)
        }
        
        return nil
    }
}