//
//  FlowAlgorithmManager.swift
//  XY
//
//  Created by Maxime Franchot on 14/02/2021.
//

import Foundation

final class FlowAlgorithmManager {
    static let shared = FlowAlgorithmManager()
    
    private init() {
        // Load previous flow data from userdefaults
        
    }
    
    public func getFlow(completion: @escaping([PostModel]?) -> Void) {
        let previousSwipeLeftActions = ActionManager.shared.previousActions.filter({ $0.type == .swipeLeft })
        let previousSwipeLefts = previousSwipeLeftActions.map { $0.objectId }
        
        FirebaseFunctionsManager.shared.getFlow(swipeLeftIds: previousSwipeLefts) { postModels in
            completion(postModels)
        }
    }
}
