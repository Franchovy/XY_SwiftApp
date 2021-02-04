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
    
    static var onlineNowCellSize = CGSize(width: 95, height: 125)
    
    private let onlineNowLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        label.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        label.layer.shadowRadius = 2.0
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 1.0
        label.text = "Online Now"
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = XYworldVC.onlineNowCellSize
        layout.minimumInteritemSpacing = 10

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.decelerationRate = UIScrollView.DecelerationRate.fast
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.alwaysBounceHorizontal = true
        return collection
    }()
    
    private var onlineNowUsers = [ProfileViewModel]()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            OnlineNowCollectionViewCell.self,
            forCellWithReuseIdentifier: OnlineNowCollectionViewCell.identifier
        )
        
        view.addSubview(onlineNowLabel)
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
        onlineNowLabel.sizeToFit()
        onlineNowLabel.frame = CGRect(
            x: 0,
            y: 20,
            width: onlineNowLabel.width,
            height: onlineNowLabel.height
        )
        
        collectionView.frame = CGRect(
            x: 0,
            y: onlineNowLabel.bottom + 10,
            width: view.width,
            height: XYworldVC.onlineNowCellSize.height
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Subscribe to Online Now in RT DB
        DatabaseManager.shared.subscribeToOnlineNow() { ids in
            if let ids = ids {
                self.onlineNowUsers = []
                
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
            withReuseIdentifier: OnlineNowCollectionViewCell.identifier,
            for: indexPath
        ) as? OnlineNowCollectionViewCell else {
            fatalError()
        }
        
        cell.configure(with: onlineNowUsers[indexPath.row])
        
        return cell
    }
}
