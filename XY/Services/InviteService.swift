//
//  InviteService.swift
//  XY
//
//  Created by Maxime Franchot on 28/03/2021.
//

import Foundation

final class InviteService {
    static let shared = InviteService()
    
    func inviteEmail(email: String, completion: @escaping(Bool) -> Void) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        FirestoreReferenceManager.root.collection("Invites")
            .addDocument(data: [
                "email": email,
                "invitedBy": userId
            ]) { error in
                completion(error == nil)
            }
    }
}
