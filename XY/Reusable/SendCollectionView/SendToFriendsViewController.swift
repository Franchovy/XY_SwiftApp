//
//  SendToFriendsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

protocol SendToFriendsViewControllerDelegate: AnyObject {
    func sendToFriendDelegate(_ sendToList: [UserViewModel])
}

class SendToFriendsViewController: UIViewController, UISearchBarDelegate, SendToFriendCellDelegate {

    private let searchBar = SearchBar()
    private let collectionView = SendCollectionView()
    private let dataSource = SendCollectionViewDataSource()
    
    var selectedFriendsToSend = [UserViewModel]()
    weak var delegate: SendToFriendsViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        dataSource.delegate = self
        collectionView.dataSource = dataSource
        searchBar.delegate = self
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        navigationItem.title = "Send Challenge"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchBar.frame = CGRect(
            x: 15,
            y: 5,
            width: view.width - 30,
            height: 37
        )
        
        collectionView.frame = CGRect(
            x: 0,
            y: searchBar.bottom + 5,
            width: view.width,
            height: view.height - (searchBar.bottom + 10)
        )
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        HapticsManager.shared.vibrateImpact(for: .light)
        
        if let searchText = searchBar.text {
            dataSource.setSearchString(searchText)
        } else {
            dataSource.setSearchString("")
        }
        collectionView.reloadData()
    }
    
    func sendToFriendCell(selectedCellWith viewModel: UserViewModel) {
        selectedFriendsToSend.append(viewModel)
        
        delegate?.sendToFriendDelegate(selectedFriendsToSend)
    }
    
    func sendToFriendCell(deselectedCellWith viewModel: UserViewModel) {
        selectedFriendsToSend.removeAll(where: {$0.nickname == viewModel.nickname})
        
        delegate?.sendToFriendDelegate(selectedFriendsToSend)
    }
}
