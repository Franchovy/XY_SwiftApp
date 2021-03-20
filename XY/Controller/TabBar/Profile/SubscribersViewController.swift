//
//  SubscribersViewController.swift
//  XY
//
//  Created by Maxime Franchot on 20/03/2021.
//

import UIKit

class SubscribersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        
        return searchBar
    }()

    private let control: UISegmentedControl = {
        let titles = ["Subscribers", "Subscribed"]
        let control = UISegmentedControl(items: titles)
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        control.setTitleTextAttributes(titleTextAttributes, for: .normal)
        
        control.selectedSegmentIndex = 0
        control.backgroundColor = .darkGray
        control.layer.cornerRadius = 16
        control.selectedSegmentTintColor = .white
        return control
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    private let subscribedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SubscriberCollectionViewCell.self, forCellWithReuseIdentifier: SubscriberCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    private let subscribersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SubscriberCollectionViewCell.self, forCellWithReuseIdentifier: SubscriberCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    var subscribedViewModels = [NewProfileViewModel]()
    var subscribersViewModels = [NewProfileViewModel]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        subscribedCollectionView.delegate = self
        subscribedCollectionView.dataSource = self
        
        
        subscribersCollectionView.delegate = self
        subscribersCollectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        
        view.addSubview(searchBar)
        view.addSubview(control)
        
        view.addSubview(scrollView)
        
        scrollView.backgroundColor = .red
        subscribersCollectionView.backgroundColor = .blue
        subscribedCollectionView.backgroundColor = .green
        
        scrollView.addSubview(subscribersCollectionView)
        scrollView.addSubview(subscribedCollectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchBar.frame = CGRect(
            x: 10,
            y: 10,
            width: view.width - 20,
            height: 37
        )
        
        control.sizeToFit()
        control.frame = CGRect(
            x: (view.width - control.width)/2,
            y: searchBar.bottom + 10,
            width: control.width,
            height: control.height
        )
        
        let scrollViewHeight = view.height - control.bottom + 10
        scrollView.frame = CGRect(
            x: 0,
            y: control.bottom + 10,
            width: view.width,
            height: scrollViewHeight
        )
        scrollView.contentSize = CGSize(width: view.width * 2, height: scrollViewHeight)
        
        subscribersCollectionView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: scrollViewHeight
        )
        
        subscribedCollectionView.frame = CGRect(
            x: view.width,
            y: 0,
            width: view.width,
            height: scrollViewHeight
        )
    }
    
    public func configure(userId: String) {
        RelationshipFirestoreManager.shared.getFollowersAndFollowing(userId: userId) { (pair) in
            if let pair = pair {
                for profileModel in pair.0 {
                    ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                        if let profileViewModel = profileViewModel {
                            self.subscribedViewModels.append(profileViewModel)
                            self.subscribedCollectionView.insertItems(at: [IndexPath(row: self.subscribedViewModels.count - 1, section: 0)])
                        }
                        
                        if self.subscribedViewModels.count == pair.0.count {
                            self.subscribedCollectionView.reloadData()
                        }
                    }
                }
            
                for profileModel in pair.1 {
                    ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                        if let profileViewModel = profileViewModel {
                            self.subscribersViewModels.append(profileViewModel)
                            self.subscribersCollectionView.insertItems(at: [IndexPath(row: self.subscribersViewModels.count - 1, section: 0)])
                        }
                        
                        if self.subscribersViewModels.count == pair.1.count {
                            self.subscribersCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.subscribedCollectionView {
            return subscribedViewModels.count
        } else {
            return subscribersViewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubscriberCollectionViewCell.identifier, for: indexPath) as! SubscriberCollectionViewCell
        
        if collectionView == self.subscribedCollectionView {
            cell.configure(with: subscribedViewModels[indexPath.row])
        } else {
            cell.configure(with: subscribersViewModels[indexPath.row])
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width, height: 55)
    }
}
