//
//  OnlineNowView.swift
//  XY
//
//  Created by Maxime Franchot on 21/03/2021.
//

import UIKit

class OnlineNowView: UIView, UICollectionViewDataSource {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(OnlineNowCollectionViewCell.self, forCellWithReuseIdentifier: OnlineNowCollectionViewCell.identifier)
        
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()

    private var noOnlineFriendsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 18)
        label.text = Int.random(in: 0...100) == 1 ? "No Friends Online #foreverAlone" : "No Friends Online 😢"
        label.isHidden = true
        label.textColor = UIColor(named: "tintColor")
        label.alpha = 0.7
        return label
    }()
    
    
    var viewModels = [OnlineNowViewModel]()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        addSubview(collectionView)
        addSubview(noOnlineFriendsLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        
        noOnlineFriendsLabel.sizeToFit()
        noOnlineFriendsLabel.frame = CGRect(
            x: (width - noOnlineFriendsLabel.width)/2,
            y: (height - noOnlineFriendsLabel.height)/2,
            width: noOnlineFriendsLabel.width,
            height: noOnlineFriendsLabel.height
        )
    }
    
    func subscribeToOnlineNow() {
        // Subscribe to Online Now in RT DB
        DatabaseManager.shared.subscribeToOnlineNow() { ids in
            if let ids = ids {
                self.viewModels = []
                
                if ids.count > 1 {
                    self.noOnlineFriendsLabel.isHidden = true
                    for id in ids {
                        ProfileFirestoreManager.shared.getProfile(forProfileID: id.0) { (profileModel) in
                            if let profileModel = profileModel {
                                ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                                    if let profileViewModel = profileViewModel {
                                        self.viewModels.append(OnlineNowViewModel(profileViewModel: profileViewModel))
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.noOnlineFriendsLabel.isHidden = false
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnlineNowCollectionViewCell.identifier, for: indexPath) as? OnlineNowCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row].profileViewModel)
        
        return cell
    }
}
