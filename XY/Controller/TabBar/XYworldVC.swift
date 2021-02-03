//
//  FriendsViewController.swift
//  XY_APP
//
//  Created by Simone on 07/12/2020.
//

import Foundation
import UIKit

class XYworldVC: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    
    @IBOutlet var xyworldSearchBar: UISearchBar!
    @IBOutlet var xyworldTableView: UITableView!
    
    static var onlineNowCellSize = CGSize(width: 145, height: 145 * 4/3)
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = XYworldVC.onlineNowCellSize
        layout.minimumInteritemSpacing = 10

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.decelerationRate = UIScrollView.DecelerationRate.fast
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        return collection
    }()
    
    private var onlineNowUsers = [ProfileViewModel]()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            ProfileCardCollectionViewCell.self,
            forCellWithReuseIdentifier: ProfileCardCollectionViewCell.identifier
        )
        
        view.addSubview(collectionView)
        
        // Search bar
        xyworldSearchBar.delegate = self
        navigationItem.titleView = xyworldSearchBar
        xyworldSearchBar.placeholder = "Search"
        
        let textFieldInsideSearchBar = xyworldSearchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        if let textFieldInsideSearchBar = self.xyworldSearchBar.value(forKey: "searchField") as? UITextField,
           let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            
            //Magnifying glass
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .gray
        }
        
        let tappedAnywhereGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhereGesture))
        view.addGestureRecognizer(tappedAnywhereGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.frame = CGRect(
            x: 0,
            y: 20,
            width: view.width,
            height: XYworldVC.onlineNowCellSize.height
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Subscribe to Online Now in RT DB
        DatabaseManager.shared.subscribeToOnlineNow() { ids in
            if let ids = ids {
                for (userId, profileId) in ids {
                    print("User id: \(userId), profile id: \(profileId)")
                    let viewModel = ProfileViewModel(profileId: profileId, userId: userId)
                    self.onlineNowUsers.append(viewModel)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc private func tappedAnywhereGesture() {
        xyworldSearchBar.resignFirstResponder()
    }
    
}

extension XYworldVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onlineNowUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCardCollectionViewCell.identifier,
            for: indexPath
        ) as? ProfileCardCollectionViewCell else {
            fatalError()
        }
        
        cell.configure(with: onlineNowUsers[indexPath.row])
        
        return cell
    }
}
