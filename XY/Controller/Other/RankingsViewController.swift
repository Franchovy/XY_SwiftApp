//
//  RankingsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 11/03/2021.
//

import UIKit

class RankingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 15)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Rank"
        return label
    }()
    
    private let playerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 15)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Player"
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 15)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Level"
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RankingTableViewCell.self, forCellReuseIdentifier: RankingTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        return tableView
    }()
    
    let backgroundLayer = CAShapeLayer()
    let shadowLayer = CAShapeLayer()
    
    var cellViewModels = [RankingCellViewModel]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.layer.insertSublayer(shadowLayer, at: 0)
        view.layer.insertSublayer(backgroundLayer, at: 0)
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        
        view.addSubview(rankLabel)
        view.addSubview(playerLabel)
        view.addSubview(levelLabel)
        view.addSubview(tableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        rankLabel.sizeToFit()
        rankLabel.frame = CGRect(
            x: 33,
            y: 98,
            width: rankLabel.width,
            height: rankLabel.height
        )
        
        playerLabel.sizeToFit()
        playerLabel.frame = CGRect(
            x: (view.width - playerLabel.width)/2,
            y: 98,
            width: playerLabel.width,
            height: playerLabel.height
        )
        
        levelLabel.sizeToFit()
        levelLabel.frame = CGRect(
            x: view.width - 44.5 - levelLabel.width,
            y: 98,
            width: levelLabel.width,
            height: levelLabel.height
        )
        
        tableView.frame = CGRect(
            x: 5,
            y: rankLabel.bottom + 5,
            width: view.width - 10,
            height: view.height - (rankLabel.bottom + 5)
        )
    }
    
    public func configure(with viewModel: RankingViewModel) {
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Raleway-Bold", size: 25)
        titleLabel.text = "\(viewModel.name) Ranking"
        titleLabel.textColor = UIColor(named: "tintColor")
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        cellViewModels = viewModel.cells
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RankingTableViewCell.identifier) as! RankingTableViewCell
        
        cell.configure(with: cellViewModels[indexPath.row], for: .large)
        cell.backgroundColor = UIColor(named: "Black")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = cellViewModels[indexPath.row]
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        ProfileFirestoreManager.shared.getProfileID(forUserID: viewModel.userID) { (profileID, error) in
            if let error = error {
                print(error)
            } else if let profileID = profileID {
                ProfileManager.shared.openProfileForId(profileID)
            }
        }
    }
}
