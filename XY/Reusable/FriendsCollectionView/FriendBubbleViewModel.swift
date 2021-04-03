//
//  FriendBubbleViewModel.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

struct FriendBubbleViewModel {
    var image: UIImage
    var nickname: String
}

extension FriendBubbleViewModel {
    static func generateFakeData() -> [FriendBubbleViewModel] {
        var fakeData = [FriendBubbleViewModel]()
        for i in 0...Int.random(in: 0...30) {
            fakeData.append(
                FriendBubbleViewModel(
                    image: [UIImage(named: "friend1")!, UIImage(named: "friend2")!, UIImage(named: "friend3")!, UIImage(named: "friend4")!, UIImage(named: "friend5")!][Int.random(in: 0...4)],
                    nickname: ["Lorenzo", "Fil", "Beatrice Migliasso", "Friend #4", "Bob"][Int.random(in: 0...4)]
                )
            )
        }
        return fakeData
    }
}
