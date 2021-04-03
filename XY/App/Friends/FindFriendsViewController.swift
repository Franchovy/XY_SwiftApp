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
        
        navigationItem.title = "Find Friends"
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
    }
    
}
