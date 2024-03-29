//
//  NotificationsDataManager.swift
//  XY
//
//  Created by Maxime Franchot on 07/05/2021.
//

import Foundation
import CoreData

extension Notification.Name {
    static let didLoadNewNotifications = Notification.Name("didLoadNewNotifications")
}

final class NotificationsDataManager {
    static var shared = NotificationsDataManager()
    private init() { }
    
    var notifications: [NotificationDataModel] = []
    
    func loadFromStorage() {
        let mainContext = CoreDataManager.shared.mainContext
        let fetchRequest:NSFetchRequest<NotificationDataModel> = NotificationDataModel.fetchRequest()
        
        do {
            let result = try mainContext.fetch(fetchRequest)
            notifications = result
            
            // Remove malformed notification models
            notifications.filter({$0.fromUser == nil}).forEach { notificationDataModel in
                notifications.removeAll { notificationDataModel.id == $0.id }
                mainContext.delete(notificationDataModel)
            }
            
            NotificationCenter.default.post(name: .didLoadNewNotifications, object: nil)
        } catch let error {
            print("Error fetching notifications from storage: \(error.localizedDescription)")
        }
    }
    
    func fetchNotifications(completion: (() -> Void)? = nil) {
        let entity = NotificationDataModel.entity()
        let context = CoreDataManager.shared.mainContext
        
        FirebaseFirestoreManager.shared.fetchAllNotifications { (result) in
            switch result {
            case .success(let notificationModels):
                notificationModels.filter({ notificationModel in !self.notifications.contains(where: {$0.firebaseID! == notificationModel.firebaseID }) })
                    .forEach({ notificationModel in
                        
                        if notificationModel.fromUserFirebaseID == ProfileDataManager.shared.ownID {
                            return
                        }
                        
                        let model = NotificationDataModel(entity: entity, insertInto: context)
                        model.type = notificationModel.type.rawValue
                        model.timestamp = notificationModel.timestamp
                        model.firebaseID = notificationModel.firebaseID
                        
                        if notificationModel.type == .addedYou {
                            model.fromUser = FriendsDataManager.shared.getUserWithFirebaseID(notificationModel.fromUserFirebaseID)
                        } else {
                            model.fromUser = FriendsDataManager.shared.getUserWithFirebaseID(notificationModel.fromUserFirebaseID)
                            if let challengeID = notificationModel.challengeFirebaseID {
                                model.challenge = ChallengeDataManager.shared.getChallengeWithFirebaseID(challengeID)
                            }
                        }
                        
                        if model.fromUser == nil {
                            print("Error, notification model has no 'from user'!")
                            context.delete(model)
                        } else {
                            self.notifications.append(model)
                        }
                    })
                
                CoreDataManager.shared.save()
                
                NotificationCenter.default.post(name: .didLoadNewNotifications, object: nil)
                completion?()
            case .failure(let error):
                print("Error fetching notifications: \(error.localizedDescription)")
            }
        }
    }
}
