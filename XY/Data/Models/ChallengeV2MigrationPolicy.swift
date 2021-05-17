//
//  ChallengeV2MigrationPolicy.swift
//  XY
//
//  Created by Maxime Franchot on 17/05/2021.
//

import CoreData

class ChallengeV2MigrationPolicy : NSEntityMigrationPolicy {
    @objc func getFileName(fileUrl:NSURL?) -> NSString? {
        
        if let fileUrlString = fileUrl?.absoluteString {
            print(fileUrlString)
            let nameStartIndex = fileUrlString.lastIndex(of: "/")!
            let fileName = fileUrlString.suffix(from: nameStartIndex).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            
            return fileName as NSString
        } else {
            return nil
        }
     }
}
