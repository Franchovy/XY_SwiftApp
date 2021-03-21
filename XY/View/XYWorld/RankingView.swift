//
//  RankingView.swift
//  XY
//
//  Created by Maxime Franchot on 21/03/2021.
//

import UIKit

class RankingView: UIView, UITableViewDataSource {
        
    private let title: UILabel = {
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
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 9)
        label.textColor = UIColor(named: "tintColor")
        label.text = "Score"
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RankingTableViewCell.self, forCellReuseIdentifier: RankingTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    

    let backgroundLayer = CAShapeLayer()
    let shadowLayer = CAShapeLayer()
    
    var models = [RankingCellModel]()
    var viewModel: RankingViewModel?
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        tableView.dataSource = self
        addSubview(title)
        addSubview(rankLabel)
        addSubview(playerLabel)
        addSubview(scoreLabel)
        addSubview(tableView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)
        
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        title.sizeToFit()
        title.frame = CGRect(
            x: 14.27,
            y: 7.75,
            width: title.width,
            height: title.height
        )
        
        rankLabel.sizeToFit()
        rankLabel.frame = CGRect(
            x: 16.66,
            y: title.bottom + 12.54,
            width: rankLabel.width,
            height: rankLabel.height
        )
        
        playerLabel.sizeToFit()
        playerLabel.frame = CGRect(
            x: rankLabel.right + 84.84,
            y: title.bottom + 12.54,
            width: playerLabel.width,
            height: playerLabel.height
        )
        
        scoreLabel.sizeToFit()
        scoreLabel.frame = CGRect(
            x: playerLabel.right + 100,
            y: title.bottom + 12.54,
            width: scoreLabel.width,
            height: scoreLabel.height
        )
        
        tableView.frame = CGRect(
            x: 5,
            y: rankLabel.bottom + 5,
            width: width - 10,
            height: 800
        )
    }
    
    enum RankingSize {
        case short
        case full
    }
    
    func subscribeToRanking(_ size: RankingSize) {
        RankingDatabaseManager.shared.getRanking { (rankingModel) in
            self.models = rankingModel.ranking
            
            RankingViewModelBuilder.build(
                model: rankingModel,
                count: size == .short ? 5 : rankingModel.ranking.count
            ) { (rankingViewModel, error) in
                if let rankingViewModel = rankingViewModel {
                    self.viewModel = rankingViewModel
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 0
        }
        return viewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RankingTableViewCell.identifier) as! RankingTableViewCell
        let cellData = viewModel.cells[indexPath.row]
        cell.configure(with: cellData.0, rank: indexPath.row + 1, score: cellData.1)
        return cell
    }
    
    @objc private func didTap() {
        let originalTransform = transform
        UIView.animate(withDuration: 0.15) {
            self.transform = originalTransform.scaledBy(x: 0.9, y: 0.9)
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.15) {
                    self.transform = originalTransform
                } completion: { (done) in
                    
                    guard let viewModel = self.viewModel else {
                        return
                    }
                }
            }
        }
    }
}
