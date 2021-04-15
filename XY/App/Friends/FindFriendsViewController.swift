//
//  FindFriendsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class FindFriendsViewController: UIViewController, UISearchBarDelegate {

    private let searchBar = SearchBar()
    
    private let friendsListCollectionView = FriendsListCollectionView()
    private let friendsListDataSource = FriendsListCollectionDataSource()
    
    private var tappedAnywhereGesture: UITapGestureRecognizer!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        friendsListCollectionView.dataSource = friendsListDataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "XYBackground")
        
        searchBar.delegate = self
        
        view.addSubview(friendsListCollectionView)
        view.addSubview(searchBar)
        
        friendsListDataSource.reload()
        friendsListCollectionView.reloadData()
        
        navigationItem.title = "Find Friends"
        
        tappedAnywhereGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tappedAnywhereGesture)
        tappedAnywhereGesture.isEnabled = false
    }
    
    deinit {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HapticsManager.shared.vibrateImpact(for: .soft)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchBar.frame = CGRect(
            x: 10,
            y: 5,
            width: view.width - 20,
            height: 37
        )
        
        friendsListCollectionView.frame = view.bounds.inset(by: UIEdgeInsets(top: 47, left: 0, bottom: 0, right: 0))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        friendsListDataSource.setSearchString(searchText)
        friendsListCollectionView.reloadData()
        
        HapticsManager.shared.vibrateImpact()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        HapticsManager.shared.beginImpactSession(with: .rigid)
        HapticsManager.shared.vibrateImpact(for: .soft)
        
        tappedAnywhereGesture.isEnabled = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        HapticsManager.shared.endImpactSession()
        HapticsManager.shared.vibrateImpact(for: .soft)
        
        tappedAnywhereGesture.isEnabled = false
    }
    
    @objc private func tappedAnywhere() {
        searchBar.resignFirstResponder()
    }
}
