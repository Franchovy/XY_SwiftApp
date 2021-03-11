//
//  RankingsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 11/03/2021.
//

import UIKit

class RankingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 25)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 9)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Rank"
        return label
    }()
    
    private let playerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 9)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Player"
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 9)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Level"
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RankingTableViewCell.self, forCellReuseIdentifier: RankingTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor(named: "XYCard")
        return tableView
    }()
    
    let backgroundLayer = CAShapeLayer()
    let shadowLayer = CAShapeLayer()
    
    var cellViewModels = [RankingCellViewModel]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.layer.insertSublayer(shadowLayer, at: 0)
        view.layer.insertSublayer(backgroundLayer, at: 0)
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        view.addSubview(titleLabel)
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
        
        backgroundLayer.frame = view.bounds
        backgroundLayer.fillColor = UIColor(named: "XYCard")!.cgColor
        backgroundLayer.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: 15).cgPath
        shadowLayer.frame = view.bounds
        shadowLayer.masksToBounds = false
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.fillColor = backgroundLayer.fillColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.path = backgroundLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: 14.27,
            y: 7.75,
            width: titleLabel.width,
            height: titleLabel.height
        )
        
        rankLabel.sizeToFit()
        rankLabel.frame = CGRect(
            x: 16.66,
            y: titleLabel.bottom + 12.54,
            width: rankLabel.width,
            height: rankLabel.height
        )
        
        playerLabel.sizeToFit()
        playerLabel.frame = CGRect(
            x: rankLabel.right + 84.84,
            y: titleLabel.bottom + 12.54,
            width: playerLabel.width,
            height: playerLabel.height
        )
        
        levelLabel.sizeToFit()
        levelLabel.frame = CGRect(
            x: view.width - 37 - levelLabel.width,
            y: titleLabel.bottom + 12.54,
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
        titleLabel.text = viewModel.name
        cellViewModels = viewModel.cells
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RankingTableViewCell.identifier) as! RankingTableViewCell
        
        cell.configure(with: cellViewModels[indexPath.row], for: .small)
        
        return cell
    }

}
