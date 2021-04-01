//
//  NotificationsDataSource.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

final class NotificationsDataSource: NSObject, UICollectionViewDataSource {
    
    let fakeData: [NotificationViewModel] = {
        let size = Int.random(in: 0...40)
        var notifications = [NotificationViewModel]()
        
        for i in 0...size {
            let challengeStatusRandInt = Int.random(in: 0...3)
            let challengeImage:UIImage = { [
                UIImage(named: "challenge1")!,
                UIImage(named: "challenge2")!,
                UIImage(named: "challenge3")!,
                UIImage(named: "challenge4")!,
                UIImage(named: "challenge5")!
            ][Int.random(in: 0...4)]
            }()
            
            notifications.append(
                NotificationViewModel(
                    nickname: ["friend", "Beatrice Migliasso", "Fil", "other guy", "lady"][Int.random(in: 0...4)],
                    profileImage: [
                        UIImage(named: "friend1")!,
                        UIImage(named: "friend2")!,
                        UIImage(named: "friend3")!,
                        UIImage(named: "friend4")!,
                        UIImage(named: "friend5")!][Int.random(in: 0...4)] ,
                    notificationText: ["Added you.", "Challenged you!", "Completed your challenge.", "Declined your challenge."][challengeStatusRandInt],
                    timestampText:
                        Int.random(in: 0...1) == 1 ?
                            "\(Int.random(in: 0...59))m"
                            : "\(Int.random(in: 0...23))h",
                    type:
                        [
                            NotificationType.friendStatus(buttonStatus: Int.random(in: 0...1) == 1 ? AddFriendButton.Mode.addBack : AddFriendButton.Mode.friend),
                            NotificationType.challengeAction(image: challengeImage),
                            NotificationType.challengeStatus(image: challengeImage, status: true),
                            NotificationType.challengeStatus(image: challengeImage, status: false)
                        ][challengeStatusRandInt]
                )
            )
        }
       return notifications
    }()
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fakeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotificationsCollectionViewCell.identifier, for: indexPath) as! NotificationsCollectionViewCell
        
        cell.configure(with: fakeData[indexPath.row])
        
        return cell
    }
    
    
}
