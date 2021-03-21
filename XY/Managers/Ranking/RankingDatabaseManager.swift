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
    
    func getRanking(completion: @escaping(RankingModel) -> Void, onChange: @escaping([RankingCellModel]) -> Void, onMove: @escaping([RankingCellModel]) -> Void, onAdd: @escaping([RankingCellModel]) -> Void) {
        let rankingRef = Database.database().reference().child("Rankings").child("Global")
        
        rankingRef.observeSingleEvent(of: .value) { (snapshot) in
            
            // Return original ranking model
            if let values = snapshot.value as? [[String: Any]?] {
                let cells = self.buildRankingCell(from: values)
                
                let rankingModel = RankingModel(name: "Global", ranking: cells)
                
                completion(rankingModel)
            }
            
            rankingRef.observe(.childChanged) { (snapshot) in
                print("Child changed")
                
                if let value = snapshot.value as? [String: Any] {
                    let cells = self.buildRankingCell(from: [value])
                    
                    onChange(cells)
                }
            }
            
            rankingRef.observe(.childMoved) { (snapshot) in
                print("Child moved")
                
                if let values = snapshot.value as? [[String: Any]?] {
                    let cells = self.buildRankingCell(from: values)
                    
                    onMove(cells)
                }
            }
            
            rankingRef.observe(.childAdded) { (snapshot) in
                print("Child added")
                
                if let values = snapshot.value as? [[String: Any]?] {
                    let cells = self.buildRankingCell(from: values)
                    
                    onAdd(cells)
                }
            }
        }
    }
    
    private func buildRankingCell(from data: [[String: Any]?]) -> [RankingCellModel] {
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
}
